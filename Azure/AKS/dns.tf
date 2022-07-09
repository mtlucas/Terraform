# Get data for Load balancer IP address and create DNS record

resource "dns_a_record_set" "aks_cluster_a_record" {
  zone = "${var.dns_zone_name}."
  name = azurerm_kubernetes_cluster.k8s.name
  addresses = [
    data.azurerm_lb.aks_nodepool_lb.frontend_ip_configuration[0].private_ip_address,
  ]
  ttl = 300
}
