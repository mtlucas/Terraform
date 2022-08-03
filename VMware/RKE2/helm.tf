# Helm resources

# Install cert-manager helm chart
resource "helm_release" "cert_manager" {

  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  version          = var.cert_manager_version
  atomic           = true
  timeout          = 1200
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    vsphere_virtual_machine.cluster_node,
  ]
}

# Install Rancher helm chart
resource "helm_release" "rancher_server" {

  name             = "rancher"
  chart            = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  namespace        = "cattle-system"
  version          = var.rancher_version
  atomic           = true
  timeout          = 2400
  create_namespace = true

  set {
    name  = "hostname"
    value = local.rke2_cluster_fqdn
  }
  set {
    name  = "replicas"
    value = "1"
  }
  set {
    name  = "bootstrapPassword"
    value = "admin" # TODO: change this once the terraform provider has been updated with the new pw bootstrap logic
  }

  depends_on = [
    helm_release.cert_manager,
    null_resource.install_rke2_additional_node,
  ]
}
