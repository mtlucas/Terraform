# Cert-Manager bootstrapping used by ALB and Rancher

resource "aws_eks_fargate_profile" "cert-manager" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate-profile-cert-manager"
  pod_execution_role_arn = data.aws_iam_role.aws-eks-fargate-pod-execution-role.arn
  subnet_ids             = [for s in data.aws_subnet.private_subnets : s.id]

  selector {
    namespace = "cert-manager"
  }

  tags = {
    Name        = "fargate-profile-cert-manager"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  depends_on = [
    aws_eks_fargate_profile.default,
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  count = var.cert_manager_create_namespace ? 1 : 0

  metadata {
    name = var.cert_manager_namespace
    annotations = {
      name = var.cert_manager_namespace
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
    aws_eks_fargate_profile.cert-manager,
    aws_security_group_rule.eks-allow-all-private-subnets,
  ]
}

resource "helm_release" "cert_manager" {
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  name             = "cert-manager"
  namespace        = var.cert_manager_namespace
  version          = var.cert_manager_chart_version
  atomic           = true
  timeout          = 1200
  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }

  dynamic "set" {
    for_each = var.cert_manager_additional_set
    content {
      name  = set.value.name
      value = set.value.value
      type  = lookup(set.value, "type", null)
    }
  }

  depends_on = [
    local_file.kubeconfig,
    kubernetes_namespace.cert_manager,
    aws_eks_fargate_profile.cert-manager,
    aws_security_group_rule.eks-allow-all-private-subnets,
  ]
}

resource "time_sleep" "wait" {
  create_duration = "60s"

  depends_on = [
    helm_release.cert_manager,
  ]
}

resource "kubectl_manifest" "cluster_issuer" {
  count = var.cert_manager_cluster_issuer_create ? 1 : 0

  validate_schema = false
  yaml_body       = var.cert_manager_cluster_issuer_yaml == null ? yamlencode(local.cluster_issuer) : var.cert_manager_cluster_issuer_yaml

  depends_on = [
    helm_release.cert_manager,
    time_sleep.wait,
  ]
}

module "certificates" {
  for_each = { for k, v in var.certificates : k => v }
  source   = "./modules/_certificate"

  name                  = each.key
  namespace             = try(each.value.namespace, var.cert_manager_namespace)
  secret_name           = try(each.value.secret_name, "${each.key}-tls")
  secret_annotations    = try(each.value.secret_annotations, {})
  secret_labels         = try(each.value.secret_labels, {})
  duration              = try(each.value.duration, "2160h")
  renew_before          = try(each.value.renew_before, "360h")
  organizations         = try(each.value.organizations, [])
  is_ca                 = try(each.value.is_ca, false)
  private_key_algorithm = try(each.value.private_key_algorithm, "RSA")
  private_key_encoding  = try(each.value.private_key_encoding, "PKCS1")
  private_key_size      = try(each.value.private_key_size, 2048)
  usages                = try(each.value.usages, ["server auth", "client auth", ])
  dns_names             = each.value.dns_names
  uris                  = try(each.value.uris, [])
  ip_addresses          = try(each.value.ip_addresses, [])
  issuer_name           = try(each.value.issuer_name, var.cert_manager_cluster_issuer_name)
  issuer_kind           = try(each.value.issuer_kind, "ClusterIssuer")
  issuer_group          = try(each.value.issuer_group, "")
}

resource "kubectl_manifest" "certificates" {
  for_each = { for k, cc in module.certificates : k => cc }

  validate_schema = false
  yaml_body       = yamlencode(each.value.map)

  depends_on = [
    kubectl_manifest.cluster_issuer,
  ]
}
