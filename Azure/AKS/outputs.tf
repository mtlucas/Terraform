# Outputs

output "cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "cluster_username" {
    value = azurerm_kubernetes_cluster.k8s.kube_config[0].username
}

output "cluster_password" {
    value = azurerm_kubernetes_cluster.k8s.kube_config[0].password
}

output "cluster_aks_id" {
  value = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.k8s.kube_config_raw
    sensitive = true
}

output "host" {
    value = azurerm_kubernetes_cluster.k8s.kube_config[0].host
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.k8s.soa_record[0].fqdn
}
