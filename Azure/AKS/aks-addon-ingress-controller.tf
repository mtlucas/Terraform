# Install Nginx ingress using helm, will create basic Load balancer in Azure (free)

resource "kubernetes_namespace" "ingress-basic" {
  metadata {
    name        = var.nginx_ingress_namespace
    annotations = {
      name = var.nginx_ingress_namespace
    }
  }
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
    kubernetes_secret_v1.ingress-tls,
    kubectl_manifest.secret-provider-class,
  ]
}
