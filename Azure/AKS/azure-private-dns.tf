# Add Private DNS zone with following uri syntax

# This is intended to be shared across resource group clusters
resource "azurerm_private_dns_zone" "k8s" {
  name                  = "privatelink.${var.resource_group_location}.azmk8s.io"
  resource_group_name   = data.azurerm_resource_group.primary.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_link" {
  name                  = "${var.cluster_name}-dns-link"
  resource_group_name   = data.azurerm_resource_group.primary.name
  private_dns_zone_name = azurerm_private_dns_zone.k8s.name
  virtual_network_id    = data.azurerm_virtual_network.primary.id
}
