# Enable or Disable gp2 as default storage class for EKS 

resource "kubernetes_annotations" "default-storageclass" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }
  
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = var.aws_eks_default_storage_class_enabled
  }

  depends_on = [
    local_file.kubeconfig,
  ]
}
