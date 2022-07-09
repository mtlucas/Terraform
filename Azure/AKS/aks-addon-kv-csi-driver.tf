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
    azurerm_user_assigned_identity.aks_identity,
    azurerm_role_assignment.aks-aci-vnet-assignment,
    azurerm_role_assignment.private-dns-contributor,
    azurerm_role_assignment.network-contributor,
    azurerm_role_assignment.acr-image-puller,
    azurerm_role_assignment.vm-contributor,
  ]
}

# CSI driver installed via kubectl using template, since kubernetes_manifest does not work properly
data "template_file" "secret-provider-class" {
  template = file("${path.module}/templates/SecretProviderClass.tpl")
  vars = {
    nginx_ingress_secret_name  = var.nginx_ingress_secret_name
    nginx_ingress_secret_class = var.nginx_ingress_secret_class
    nginx_ingress_namespace    = var.nginx_ingress_namespace
    cert_name                  = var.cert_name
    keyvault_name              = var.keyvault_name
    client_id                  = azurerm_user_assigned_identity.aks_identity.client_id
  }
}

# This CSI driver should be created in Ingress namespace
resource "kubectl_manifest" "secret-provider-class" {
  yaml_body  = data.template_file.secret-provider-class.rendered

  depends_on = [
    helm_release.kv_csi,
    kubernetes_namespace.ingress-basic,
  ]
}
