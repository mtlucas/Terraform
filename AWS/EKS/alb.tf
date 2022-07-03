# Create Application Loadbalacer (ALB) on Fargate using Helm

resource "kubernetes_namespace" "alb" {
  count = var.alb_create_namespace ? 1 : 0

  metadata {
    annotations = {
      name = var.alb_namespace
    }
    name = var.alb_namespace
  }
  depends_on = [
    local_file.kubeconfig,
    aws_security_group_rule.eks-allow-all-private-subnets,
  ]
}

resource "helm_release" "aws-load-balancer-controller" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  name       = "aws-load-balancer-controller"
  namespace  = var.alb_namespace
  version    = var.alb_chart_version
  atomic     = true
  timeout    = 1200

  dynamic "set" {
    for_each = {
      "clusterName"           = aws_eks_cluster.main.name
      "serviceAccount.create" = false
      "serviceAccount.name"   = var.alb_service_account_name
      "region"                = data.aws_region.current.name
      "vpcId"                 = data.aws_vpc.main.id
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  depends_on = [
    local_file.kubeconfig,
    kubernetes_cluster_role_binding.ingress,
    aws_eks_fargate_profile.kube-system,
    aws_security_group_rule.eks-allow-all-private-subnets,
    helm_release.cert_manager,
  ]
}

resource "time_sleep" "wait-for-alb" {
  create_duration = "60s"

  depends_on = [
    helm_release.aws-load-balancer-controller,
  ]
}
