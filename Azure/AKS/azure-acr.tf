# Azure Container Registry - This is intended to be shared across clusters

resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = data.azurerm_resource_group.primary.name
  location            = data.azurerm_resource_group.primary.location
  sku                 = "Basic"
  admin_enabled       = false
}
