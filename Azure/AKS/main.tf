##########################################################
# Developed by: Michael Lucas (mike@lucasnet.org)        #
##########################################################

##########################################################
# Main.tf for AKS private (internal) cluster buildout    #
#                                                        #
# This will deploy a AKS cluster with ACI enabled and    #
# Basic Loadbalancer. Option to install k8s Dashboard.   #
# Also included:                                         #
#  - ACR Container registry                              #
#  - Private DNS zone and link to AKS                    #
#  - Kubernetes roles to allow listing all namespaces    #
#  - Azure Log Analytics                                 #
#  - CSI driver allowing integration with Azure KeyVault #
#  Requirements to execute:                              #
#  - Logged into Azure with correct tenant               #
#  - Kubernetes version 1.22 or greater                  #
#  - Execute terraform on Windows machine only           #
#  - Access to Windows DNS server and service account    #
##########################################################

# Execute terraform syntax:  'terraform apply -var dns_admin_password="<password>" -auto-approve'

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.5"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.12.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}


##########################################################
# Main private AKS Cluster build-out                     #
##########################################################
resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = var.cluster_name
  location                = data.azurerm_resource_group.primary.location
  kubernetes_version      = var.kubernetes_version
  resource_group_name     = data.azurerm_resource_group.primary.name
  dns_prefix              = var.cluster_name
  private_cluster_enabled = true
  node_resource_group     = "${data.azurerm_resource_group.primary.name}-${var.cluster_name}-nodepool"

  # Can only restrict IP ranges on Public cluster
  #api_server_authorized_ip_ranges = ["10.10.0.0/16", "192.168.0.0/24"]

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.nodepool_vm_size
    vnet_subnet_id  = data.azurerm_subnet.private.id
  }

  identity {
    type                       = var.cluster_identity_type
  }

  aci_connector_linux {
    subnet_name = data.azurerm_subnet.private_for_aci.name
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
  }

  # Auto-Application Gateway creation does not have fine-grained settings to add certs and is expensive to run
  # ingress_application_gateway {
  #   gateway_name = "${var.cluster_name}-agw"
  #   subnet_id    = data.azurerm_subnet.private.id
  # }

  # key_vault_secrets_provider {
  #   secret_rotation_enabled = false
  # }

  network_profile {
    load_balancer_sku  = "Standard"
    network_plugin     = "azure"
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }

  tags = {
    ClusterName = var.cluster_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      api_server_authorized_ip_ranges,
      enable_pod_security_policy,
      local_account_disabled,
    ]
  }
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.private_dns_vnet_link,
  ]
}
