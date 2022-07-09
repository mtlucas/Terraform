# Assign Identities and Roles for AKS cluster

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-keyvault"
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  location            = data.azurerm_resource_group.primary.location

  # This assigns identity to VM ScaleSet and name cannot be queried using terraform (yet)
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "~\\.kube\\${var.cluster_name}-config"
    }
    command = <<-EOT
      $vmss = (az vmss list --resource-group ${azurerm_kubernetes_cluster.k8s.node_resource_group} --query "[].name") | ConvertFrom-Json; foreach ($ss in $vmss) {az vmss identity assign -g ${azurerm_kubernetes_cluster.k8s.node_resource_group} -n $ss --identities ${azurerm_user_assigned_identity.aks_identity.id}};
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "azurerm_role_assignment" "private-dns-contributor" {
  role_definition_name = "Private DNS Zone Contributor"
  scope                = azurerm_private_dns_zone.k8s.id
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

# https://github.com/Azure/AKS/issues/1557
resource "azurerm_role_assignment" "vm-contributor" {
  role_definition_name = "Virtual Machine Contributor"
  scope                = azurerm_kubernetes_cluster.k8s.id
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

resource "azurerm_role_assignment" "network-contributor" {
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_virtual_network.primary.id
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

# Needed for ACI Connector
resource "azurerm_role_assignment" "aks-aci-vnet-assignment" {
  role_definition_name = "Contributor"
  scope                = data.azurerm_virtual_network.primary.id
  principal_id         = data.azurerm_user_assigned_identity.aks_aci_identity.principal_id

  depends_on = [
    azurerm_kubernetes_cluster.k8s,
  ]
}

# Needed for Azure Container Registry
resource "azurerm_role_assignment" "acr-image-puller" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

# Needed for Azure Key Vault secret and cert access
resource "azurerm_key_vault_access_policy" "aks_cluster" {
  key_vault_id = data.azurerm_key_vault.primary.id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = azurerm_user_assigned_identity.aks_identity.principal_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]

  certificate_permissions = [
    "Get",
  ]
}
