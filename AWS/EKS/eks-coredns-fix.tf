# A kubernetes job to fix coredns to use Fargate pods
# This is not working due to bitnami/kubectl container not having aws tools installed.
# This was moved to local-exec Provisioner for "aws_eks_fargate_profile.kube-system" resource.
# FOR REFERENCE ONLY.

resource "kubernetes_config_map" "kube-config" {
  count = var.coredns_fix_via_job ? 1 : 0

  metadata {
    name      = "kube-config"
    namespace = var.coredns_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    "config" = "${file("~/.kube/${var.name}-config")}"
  }
  depends_on = [
    local_file.kubeconfig,
  ]
}

resource "kubernetes_service_account" "core_dns_fixer" {
  count = var.coredns_fix_via_job ? 1 : 0

  metadata {
    name      = "core-dns-fixer"
    namespace = var.coredns_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  depends_on = [
    local_file.kubeconfig,
  ]
}

resource "kubernetes_role" "core_dns_fixer" {
  count = var.coredns_fix_via_job ? 1 : 0

  metadata {
    name      = "core-dns-fixer"
    namespace = var.coredns_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = ["coredns"]
    verbs          = ["get", "patch"]
  }
  depends_on = [
    local_file.kubeconfig,
  ]
}

resource "kubernetes_role_binding" "core_dns_fixer" {
  count = var.coredns_fix_via_job ? 1 : 0

  metadata {
    name      = "core-dns-fixer"
    namespace = var.coredns_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.core_dns_fixer[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.core_dns_fixer[0].metadata[0].name
    namespace = var.coredns_namespace
  }
  depends_on = [
    kubernetes_role.core_dns_fixer,
    kubernetes_service_account.core_dns_fixer,
  ]
}

# This resource does not work because it expects aws client to be installed in bitnami/kubectl pod.
resource "kubernetes_job_v1" "patch_core_dns" {
  count = var.coredns_fix_via_job ? 1 : 0

  metadata {
    name      = "patch-core-dns"
    namespace = var.coredns_namespace
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account.core_dns_fixer[0].metadata[0].name
        container {
          name    = "patch-core-dns"
          image   = "bitnami/kubectl:latest"
          command = ["/bin/sh", "-c", "compute_type=$(kubectl get deployments.app/coredns -n kube-system -o jsonpath='{.spec.template.metadata.annotations.eks\\.amazonaws\\.com/compute-type}'); [ ! -z \"$compute_type\" ] && kubectl patch deployments.app/coredns -n kube-system --type json -p='[{\"op\":\"remove\", \"path\": \"/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type\"}]' && kubectl rollout restart deployments.app/coredns -n kube-system"]
          volume_mount {
            mount_path = "/.kube/config"
            name       = "kube-config"
            sub_path   = "config"
          }
        }
        volume {
          name = "kube-config"
          config_map {
            name = "kube-config"
          }
        }
        restart_policy = "Never"
      }
    }
    ttl_seconds_after_finished = 10
  }
  wait_for_completion = true

  timeouts {
    create = "5m"
  }
  depends_on = [
    aws_eks_fargate_profile.kube-system,
    kubernetes_role_binding.core_dns_fixer,
    kubernetes_config_map.kube-config,
  ]
}
