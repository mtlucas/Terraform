# OPTIONAL:  Install Kubernetes dashboard without authentication - DO NOT INSTALL IF PUBLIC!!!

# Set these extra arguments for helm chart
locals {
  dashboard_settings = {
    extraArgs = [
      "--enable-skip-login",
      "--enable-insecure-login",
      "--system-banner=\"Welcome to Lucasnet k8s!\""
    ]
  }
}

resource "helm_release" "kubernetes_dashboard" {
  count = var.kubernetes_dashboard_create ? 1 : 0

  name             = "kubernetes-dashboard"
  chart            = "kubernetes-dashboard"
  version          = var.kubernetes_dashboard_chart_version
  repository       = "https://kubernetes.github.io/dashboard/"
  namespace        = "kubernetes-dashboard"
  max_history      = 4
  atomic           = true
  reuse_values     = false
  timeout          = 900
  create_namespace = true
  values           = [yamlencode(local.dashboard_settings)]

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

# This grants cluster-admin access to Dashboard, exposing k8s admin access to anyone with browser access.  I warned you!
resource "kubernetes_cluster_role_binding_v1" "kubernetes_dashboard" {
  count = var.kubernetes_dashboard_create ? 1 : 0

  metadata {
    name = "kubernetes-dashboard"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
  }

  depends_on = [
    helm_release.kubernetes_dashboard,
  ]
}

resource "kubernetes_ingress_v1" "kubernetes-dashboard" {
  count = var.kubernetes_dashboard_create ? 1 : 0

  wait_for_load_balancer = true

  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target"   = "/$2"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
    labels = {
        app                            = "kubernetes-dashboard"
        "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
        hosts       = ["${azurerm_kubernetes_cluster.k8s.name}.${var.dns_zone_name}"]
        secret_name = var.nginx_ingress_secret_name
        }
    rule {
      host = "${azurerm_kubernetes_cluster.k8s.name}.${var.dns_zone_name}"
      http {
        path {
          path = "/dashboard(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
                name = "kubernetes-dashboard"
                port {
                  number = 443
                }
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
    ]
    replace_triggered_by = [
      helm_release.kubernetes_dashboard,
    ]
  }

  depends_on = [
    kubernetes_cluster_role_binding_v1.kubernetes_dashboard,
  ]
}
