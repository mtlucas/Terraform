# Install Nginx ingress using helm, will create Basic Load balancer in Azure (free)

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
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.nginx_ingress_lb_ip
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }
  set {
    name  = "syncSecret.enabled"
    value = true
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
    value = "azure-ingress-tls"
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
    kubectl_manifest.secret-provider-class,
  ]
}
