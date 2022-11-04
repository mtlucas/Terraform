# Add Private DNS zone with following uri syntax

# This is intended to be shared across resource group clusters
resource "azurerm_private_dns_zone" "k8s" {
  name                  = "privatelink.${var.resource_group_location}.azmk8s.io"
  resource_group_name   = data.azurerm_resource_group.vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_link_primary" {
  name                  = "${var.vnet_name}-dns-link"
  resource_group_name   = data.azurerm_resource_group.vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.k8s.name
  virtual_network_id    = data.azurerm_virtual_network.primary.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_link_peer" {
  name                  = "${var.peer_vnet_name}-dns-link"
  resource_group_name   = data.azurerm_resource_group.vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.k8s.name
  virtual_network_id    = data.azurerm_virtual_network.peer.id
}
