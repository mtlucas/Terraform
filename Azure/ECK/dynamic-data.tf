# Dynamic data - assumes Resource groups, Vnet, subnets and route tables already created

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "primary" {
  name                 = var.resource_group_name
}

data "azurerm_resource_group" "vnet" {
  name                 = var.resource_group_name_vnet
}

data "azurerm_resource_group" "kvt" {
  name                 = var.resource_group_name_kvt
}

data "azurerm_virtual_network" "primary" {
  name                 = var.vnet_name
  resource_group_name  = data.azurerm_resource_group.vnet.name
}

data "azurerm_virtual_network" "peer" {
  name                 = var.peer_vnet_name
  resource_group_name  = data.azurerm_resource_group.vnet.name
}

data "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  virtual_network_name = data.azurerm_virtual_network.primary.name
  resource_group_name  = data.azurerm_resource_group.vnet.name
}

data "azurerm_key_vault" "primary" {
  name                 = var.keyvault_name
  resource_group_name  = data.azurerm_resource_group.kvt.name
}
