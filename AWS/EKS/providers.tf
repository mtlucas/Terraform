# Provider configuration

# Must have awscli installed (choco install awscli -y)
provider "aws" {
 region = "us-east-2"
}

# Must have kubectl installed (choco install kubernetes-cli -y)
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false
}

# Must have kubectl installed (choco install kubernetes-cli -y)
provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# Must have helm installed (choco install kubernetes-helm -y)
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Configure the Windows DNS Provider
provider "dns" {
  update {
    server     = "dc-1.lucasnet.int"
    gssapi {
      realm    = upper(var.dns_zone_name)
      username = var.dns_admin_username
      password = var.dns_admin_password
    }
  }
}

# This provider is not used, and is for potential future
provider "rancher2" {
  api_url   = "https://${var.name}.${var.dns_zone_name}"
  insecure  = true
}
