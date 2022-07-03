# Local Variables

locals {
  # Cert Manager
  cluster_issuer = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cert_manager_cluster_issuer_name
    }
    spec = {
      acme = {
        server         = var.cert_manager_cluster_issuer_server
        preferredChain = "ISRG Root X1"
        email = var.cert_manager_cluster_issuer_email
        privateKeySecretRef = {
          name = var.cert_manager_cluster_issuer_private_key_secret_name
        }
        # Enable the HTTP-01 challenge provider
        solvers = var.cert_manager_solvers
      }
    }
  }

  # Rancher namespaces for Fargate profile
  rancher_namespaces = [
    "${var.rancher_primary_namespace}",
    "cattle-fleet-system",
    "cattle-fleet-local-system",
    "fleet-default",
    "fleet-local"
  ]
}

