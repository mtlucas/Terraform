# Variables - Some are Constants and should not be changed

variable "cluster_name" {
  description = "Name of AKS Cluster - used to create names of other resources and DNS records"
  type        = string
}

variable "cluster_identity_type" {
  description = "Type of identity management for AKS Cluster"
  type        = string
  default     = "SystemAssigned"
}

variable "environment" {
  description = "Name of Development Lifecycle environment"
  type        = string
}

variable location {
  description = "Azure Region display name"
  type        = string
  default     = "Central US"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS Cluster"
  type        = string
}

variable resource_group_name {
  description = "Existing Resource group name to create AKS cluster and other resources"
  type        = string
}

variable resource_group_name_vnet {
  description = "Existing Resource group name where VNETs reside"
  type        = string
}

variable resource_group_name_kvt {
  description = "Existing Resource group name where Key Vault resides"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
  default     = "centralus"
}

variable "resource_group_name_prefix" {
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription"
  type        = string
  default     = "rg-"
}

variable "vnet_name" {
  description = "Existing Vnet name"
  type        = string
}

variable "peer_vnet_name" {
  description = "Peered Vnet name"
  type        = string
}

variable "private_subnet_name" {
  description = "Existing private subnet name"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes to start with"
  type        = number
  default     = 2
}

variable "nodepool_vm_size" {
  description = "Size of VM for worker nodes (must be 2 vCPU or greater)"
  type        = string
  default     = "Standard_B2s"
}

variable "ssh_public_key" {
  description = "SSH Public key file location"
  type        = string
  default     = "~/.ssh/azure-eck-id.pub"
}

variable container_registry_name {
  description = "Azure Container Registry name"
  type        = string
}

variable keyvault_name {
  description = "Azure Key Vault name where certificates are stored"
  type        = string
}

variable csi_driver_chart_version {
  description = "CSI Driver chart version"
  type        = string
}

variable log_analytics_workspace_name {
  description = "Log analytics workspace name"
  type        = string
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
  description = "Log analytics Pricing sku"
  type        = string
  default     = "PerGB2018"
}

variable "network_docker_bridge_cidr" {
  description = "CNI Docker bridge cidr"
  type        = string
  default     = "172.17.0.1/16"
}

variable "network_service_cidr" {
  description = "CNI service cidr"
  type        = string
  default     = "10.43.0.0/24"
}

variable "network_dns_service_ip" {
  description = "CNI DNS service IP"
  type        = string
  default     = "10.43.0.10"
}

variable "nginx_ingress_create" {
  description = "Create ingress or not"
  type        = bool
  default     = true
}

variable "nginx_ingress_version" {
  description = "Nginx-ingress helm chart version"
  type        = string
}

variable "nginx_ingress_secret_name" {
  description = "Nginx-ingress secret name - used for Keyvault access"
  type        = string
  default     = "ingress-tls-csi"
}

variable "nginx_ingress_secret_class" {
  description = "Nginx-ingress secret provider class name - used for Keyvault access"
  type        = string
  default     = "azure-ingress-tls"
}

variable "nginx_ingress_namespace" {
  description = "Nginx-ingress namespace"
  type        = string
  default     = "ingress-basic"
}

variable "nginx_ingress_lb_static_ip" {
  description = "Nginx-ingress Load Balancer static IP address - leave empty string for Dynamic IP address"
  type        = string
  default     = ""
}

variable "cert_name" {
  description = "Nginx-ingress TLS certificate name"
  type        = string
  default     = ""
}

variable "ca_cert_name" {
  description = "Nginx-ingress CA certificate name"
  type        = string
  default     = ""
}
