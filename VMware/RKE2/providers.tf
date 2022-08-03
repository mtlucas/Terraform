terraform {

  required_version = ">= 0.14"

  required_providers {
    vsphere   = {
      source  = "hashicorp/vsphere"
    }
    random    = {
      source  = "hashicorp/random"
      version = "3.1.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "1.2.0"
    }
    remote = {
      source  = "tenstad/remote"
    }
  }
}

# VMware Provider
provider "vsphere" {
    user                 = var.vsphere_user
    password             = var.vsphere_password
    vsphere_server       = var.vsphere_server
    allow_unverified_ssl = true
}

# Configure the Windows DNS Provider
provider "dns" {
  update {
    server     = var.dns_server
    timeout    = 2
    retries    = 3
    gssapi {
      realm    = upper(var.vm_domain)
      username = var.dns_admin_username
      password = var.dns_admin_password
    }
  }
}

provider "remote" {
  max_sessions = 2
}

provider "helm" {
  kubernetes {
    config_path = local_file.retrieve_kubeconfig.filename
  }
}

# Rancher2 bootstrapping provider
provider "rancher2" {

  alias = "bootstrap"

  api_url   = "https://${dns_cname_record.rke2_cluster_cname_record.cname}"
  insecure  = true
  bootstrap = true
}

# Rancher2 administration provider
provider "rancher2" {

  alias = "admin"

  api_url   = "https://${dns_cname_record.rke2_cluster_cname_record.cname}"
  insecure  = true
  token_key = rancher2_bootstrap.admin.token
  timeout   = "300s"
}
