# Dynamic data - assumes Resource groups, Vnet, subnets and route tables already created

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "primary" {
  name                 = var.resource_group_name
}

data "azurerm_virtual_network" "primary" {
  name                 = var.vnet_name
  resource_group_name  = data.azurerm_resource_group.primary.name
}

data "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  virtual_network_name = data.azurerm_virtual_network.primary.name
  resource_group_name  = data.azurerm_resource_group.primary.name
}

data "azurerm_subnet" "private_for_aci" {
  name                 = var.private_subnet_name_for_aci
  virtual_network_name = data.azurerm_virtual_network.primary.name
  resource_group_name  = data.azurerm_resource_group.primary.name
}

data "azurerm_key_vault" "primary" {
  name                 = var.keyvault_name
  resource_group_name  = data.azurerm_resource_group.primary.name
}

data "azurerm_key_vault_certificate_data" "wildcard_cert" {
  name                 = var.cert_name
  key_vault_id         = data.azurerm_key_vault.primary.id
}

data "azurerm_key_vault_secret" "ca_cert" {
  name                 = var.ca_cert_name
  key_vault_id         = data.azurerm_key_vault.primary.id
}

data "azurerm_user_assigned_identity" "aks_aci_identity" {
  name                 = "aciconnectorlinux-${azurerm_kubernetes_cluster.k8s.name}"
  resource_group_name  = azurerm_kubernetes_cluster.k8s.node_resource_group
}

data "azurerm_lb" "aks_nodepool_lb" {
  name                = "kubernetes-internal"
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group

  depends_on = [
    helm_release.ingress
  ]
}
