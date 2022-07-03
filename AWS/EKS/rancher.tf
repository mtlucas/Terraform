# Rancher bootstrapping into Fargate using helm (Only enable if needed)
# - Rancher install takes over 30 minutes as it restarts "rancher" pod many times
#   due to timeouts because of Fargate spinup time ( >= 60s).

resource "aws_eks_fargate_profile" "rancher" {
  count = var.rancher_create ? 1 : 0

  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate-profile-${var.rancher_primary_namespace}"
  pod_execution_role_arn = data.aws_iam_role.aws-eks-fargate-pod-execution-role.arn
  subnet_ids             = [for s in data.aws_subnet.private_subnets : s.id]

  dynamic "selector" {
    for_each    = toset(local.rancher_namespaces)
    content {
      namespace = selector.value
    }
  }

  tags = {
    Name        = "fargate-profile-${var.rancher_primary_namespace}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  depends_on = [
    aws_eks_fargate_profile.cert-manager,
  ]
}

resource "kubernetes_namespace" "rancher" {
  count = var.rancher_create ? 1 : 0

  metadata {
    name = var.rancher_primary_namespace

    annotations = {
      name = var.rancher_primary_namespace
    }
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["field.cattle.io/projectId"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
      metadata[0].annotations["management.cattle.io/no-default-sa-token"],
      metadata[0].labels["field.cattle.io/projectId"]
    ]
  }
  depends_on = [
    local_file.kubeconfig,
    aws_eks_fargate_profile.rancher,
    aws_security_group_rule.eks-allow-all-private-subnets,
  ]
}

# This ingress creates ALB used by Helm created ingress
resource "kubernetes_ingress_v1" "rancher" {
  count = var.rancher_create ? 1 : 0

  wait_for_load_balancer = true

  metadata {
    name      = "rancher-ingress"
    namespace = var.rancher_primary_namespace
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internal"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/subnets"          = join(", ", [for s in data.aws_subnet.private_subnets : s.id])
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "alb.ingress.kubernetes.io/certificate-arn"  = data.aws_acm_certificate.issued.arn
      "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS-1-2-2017-01"
      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      "meta.helm.sh/release-name"                  = "rancher"
      "meta.helm.sh/release-namespace"             = kubernetes_namespace.rancher[0].metadata[0].name
    }
    labels = {
        "app"                                      = "rancher"
        "service"                                  = "rancher"
        "dependent-release"                        = helm_release.aws-load-balancer-controller.name
        "app.kubernetes.io/managed-by"             = "Helm"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
                name = "rancher"
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
      metadata[0].annotations["cert-manager.io/issuer"],
      metadata[0].annotations["cert-manager.io/issuer-kind"],
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
      metadata[0].labels["chart"],
      metadata[0].labels["heritage"],
      metadata[0].labels["release"],
    ]
    replace_triggered_by = [
      helm_release.aws-load-balancer-controller,
    ]
  }
  depends_on = [
    kubernetes_namespace.rancher,
    time_sleep.wait-for-alb,
  ]
}

resource "helm_release" "rancher" {
  count = var.rancher_create ? 1 : 0

  chart            = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  name             = "rancher"
  namespace        = var.rancher_primary_namespace
  version          = var.rancher_version
  atomic           = true
  timeout          = 1800
  create_namespace = false

  set {
    name  = "hostname"
    value = kubernetes_ingress_v1.rancher[0].status[0].load_balancer[0].ingress[0].hostname
  }
  set {
    name  = "replicas"
    value = var.rancher_replicas
  }
  set {
    name  = "bootstrapPassword"
    value = var.rancher_bootstrap_password
  }

  depends_on = [
    local_file.kubeconfig,
    helm_release.cert_manager,
    kubernetes_ingress_v1.rancher,
    aws_security_group_rule.eks-allow-all-private-subnets,
  ]
}
