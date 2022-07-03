# Whoami deployment, service and ingress

resource "kubernetes_deployment" "whoami" {
  count = var.whoami_create ? 1 : 0

  metadata {
    name      = "whoami-deployment"
    namespace = "default"
    labels    = {
      app                            = "whoami"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "whoami"
      }
    }

    template {
      metadata {
        labels = {
          app                            = "whoami"
          "app.kubernetes.io/managed-by" = "terraform"
        }
      }

      spec {
        container {
          image = "traefik/whoami"
          name  = "whoami"

          port {
            container_port = 80
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
    ]
  }
  depends_on = [
    aws_eks_fargate_profile.default,
    aws_security_group_rule.eks-allow-all-private-subnets,
  ]
}

resource "kubernetes_service" "whoami" {
  count = var.whoami_create ? 1 : 0

  wait_for_load_balancer = false

  metadata {
    name      = "whoami"
    namespace = "default"
    labels    = {
      app                            = "whoami"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    selector = {
      app = "whoami"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
    ]
  }
  depends_on = [
    kubernetes_deployment.whoami,
  ]
}

resource "kubernetes_ingress_v1" "whoami" {
  count = var.whoami_create ? 1 : 0

  wait_for_load_balancer = true

  metadata {
    name      = "whoami-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internal"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/subnets"     = join(", ", [for s in data.aws_subnet.private_subnets : s.id])
    }
    labels = {
        app                            = "whoami"
        service                        = kubernetes_service.whoami[0].metadata[0].name
        dependent-release              = helm_release.aws-load-balancer-controller.name
        "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
                name = kubernetes_service.whoami[0].metadata[0].name
                port {
                  number = kubernetes_service.whoami[0].spec[0].port[0].port
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
      helm_release.aws-load-balancer-controller,
    ]
  }
  depends_on = [
    kubernetes_service.whoami,
    time_sleep.wait-for-alb,
  ]
}
