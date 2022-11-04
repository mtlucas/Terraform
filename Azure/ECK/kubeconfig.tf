# Kubeconfig file - based on cluster name

resource "local_sensitive_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.k8s.kube_config_raw
  filename = pathexpand("~/.kube/${var.cluster_name}-config")

  depends_on = [
    azurerm_kubernetes_cluster.k8s,
  ]
}
