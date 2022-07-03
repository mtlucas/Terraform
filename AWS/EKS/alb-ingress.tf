# Create Roles and ServiceAccount for ALB ingress controller

resource "kubernetes_cluster_role" "ingress" {
  metadata {
    name = var.alb_service_account_name
    labels = {
      "app.kubernetes.io/name"       = var.alb_service_account_name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
    verbs      = ["create", "get", "list", "update", "watch", "patch"]
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["nodes", "pods", "secrets", "services", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
  depends_on = [
    local_file.kubeconfig,
    aws_iam_role_policy_attachment.ALBIngressControllerIAMPolicy,
    aws_iam_role_policy_attachment.AWSLoadBalancerControllerIAMPolicy,
  ]
}

resource "kubernetes_service_account" "ingress" {
  automount_service_account_token = true
  
  metadata {
    name      = var.alb_service_account_name
    namespace = var.alb_namespace
    labels    = {
      "app.kubernetes.io/name"       = var.alb_service_account_name
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws-eks-loadbalancer-role.arn
    }
  }
  depends_on = [
    local_file.kubeconfig,
    aws_iam_role_policy_attachment.ALBIngressControllerIAMPolicy,
    aws_iam_role_policy_attachment.AWSLoadBalancerControllerIAMPolicy,
  ]
}

resource "kubernetes_cluster_role_binding" "ingress" {
  metadata {
    name = var.alb_service_account_name
    labels = {
      "app.kubernetes.io/name"       = var.alb_service_account_name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.ingress.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ingress.metadata[0].name
    namespace = kubernetes_service_account.ingress.metadata[0].namespace
  }
}
