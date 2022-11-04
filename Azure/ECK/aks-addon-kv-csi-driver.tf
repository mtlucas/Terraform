# Azure KeyVault SecretStore CSI driver helm chart

locals {
  kv_csi_settings = {
    linux = {
      enabled = true
      resources = {
        requests = {
          cpu    = "100m"
          memory = "100Mi"
        }
        limits = {
          cpu    = "100m"
          memory = "100Mi"
        }
      }
    }
    secrets-store-csi-driver = {
      install = true
      linux = {
        enabled = true
      }
      logLevel = {
        debug = true
      }
    }
  }
}

resource "helm_release" "kv_csi" {
  name         = "csi-secrets-store-provider-azure"
  chart        = "csi-secrets-store-provider-azure"
  version      = var.csi_driver_chart_version
  repository   = "https://azure.github.io/secrets-store-csi-driver-provider-azure/charts"
  namespace    = "kube-system"
  max_history  = 4
  atomic       = true
  reuse_values = false
  timeout      = 1800
  values       = [yamlencode(local.kv_csi_settings)]

  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_user_assigned_identity.kvt_identity,
    azurerm_role_assignment.private-dns-contributor,
    azurerm_role_assignment.network-contributor,
    azurerm_role_assignment.acr-image-puller,
    azurerm_role_assignment.vm-contributor,
  ]
}
