# Install Nginx ingress using helm, will create basic Load balancer in Azure (free)

resource "kubernetes_namespace" "ingress-basic" {
  count = var.nginx_ingress_create ? 1 : 0

  metadata {
    name        = var.nginx_ingress_namespace
    annotations = {
      name = var.nginx_ingress_namespace
    }
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_user_assigned_identity.kvt_identity,
    azurerm_role_assignment.private-dns-contributor,
    azurerm_role_assignment.network-contributor,
    azurerm_role_assignment.acr-image-puller,
    azurerm_role_assignment.vm-contributor,
  ]
}

# Import Certificate/Key from Azure Key Vault and save as Kubernetes secret
# -- It should be noted this is a workaround for the failing SecretProviderClass sync feature
# resource "kubernetes_secret_v1" "ingress-tls" {
#   count = var.nginx_ingress_create ? 1 : 0

#   metadata {
#     name      = var.nginx_ingress_secret_name
#     namespace = var.nginx_ingress_namespace
#   }

#   type = "kubernetes.io/tls"

#   data = {
#     "ca.crt"  = base64decode(data.azurerm_key_vault_secret.ca_cert.value)
#     "tls.crt" = data.azurerm_key_vault_certificate_data.wildcard_cert.pem
#     "tls.key" = data.azurerm_key_vault_certificate_data.wildcard_cert.key
#   }

#   depends_on = [
#     kubernetes_namespace.ingress-basic,
#   ]
# }

resource "helm_release" "ingress" {
  count = var.nginx_ingress_create ? 1 : 0

  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  name             = "ingress-nginx"
  namespace        = var.nginx_ingress_namespace
  version          = var.nginx_ingress_version
  atomic           = true
  timeout          = 1800
  create_namespace = false

  set {
    name  = "controller.replicaCount"
    value = 1
  }
  # If you need a static IP for load balancer, set the "nginx_ingress_lb_static_ip" variable to valid value
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.nginx_ingress_lb_static_ip
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }
  # This sync feature does not appear to be working properly, even when enabled.
  set {
    name  = "syncSecret.enabled"
    value = false
  }
  # Manually added secret via "kubernetes_secret_v1.ingress-tls" resource
  set {
    name  = "controller.defaultTLS.secret"
    value = "${var.nginx_ingress_namespace}/${var.nginx_ingress_secret_name}"
  }
  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "${var.nginx_ingress_namespace}/${var.nginx_ingress_secret_name}"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
  set {
    name  = "defaultBackend.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
  set {
    name  = "controller.extraVolumes[0].name"
    value = "secrets-store-inline"
  }
  set {
    name  = "controller.extraVolumes[0].csi.driver"
    value = "secrets-store.csi.k8s.io"
  }
  set {
    name  = "controller.extraVolumes[0].csi.readOnly"
    value = true
  }
  set {
    name  = "controller.extraVolumes[0].csi.volumeAttributes.secretProviderClass"
    value = var.nginx_ingress_secret_class
  }
  set {
    name  = "controller.extraVolumeMounts[0].name"
    value = "secrets-store-inline"
  }
  set {
    name  = "controller.extraVolumeMounts[0].mountPath"
    value = "/mnt/secrets-store"
  }
  set {
    name  = "controller.extraVolumeMounts[0].readOnly"
    value = true
  }

  depends_on = [
    #kubernetes_secret_v1.ingress-tls,
    kubectl_manifest.secret-provider-class,
  ]
}

# Ingress TLS cert installed via kubectl using template, since kubernetes_manifest does not work properly
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

# This Ingress TLS cert should be created in Ingress-basic namespace
resource "kubectl_manifest" "secret-provider-class" {
  count = var.nginx_ingress_create ? 1 : 0

  yaml_body  = data.template_file.secret-provider-class.rendered

  depends_on = [
    helm_release.kv_csi,
    kubernetes_namespace.ingress-basic,
  ]
}
