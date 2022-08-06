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
    windns = {
      source  = "portofportland/windns"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "1.2.0"
    }
    remote = {
      source  = "tenstad/remote"
    }
  }
#   backend "s3" {
#     key      = "terraform.tfstate"
#     bucket   = "terraform"
#     endpoint = "https://s3.amazonaws.com/"
    
#     access_key="AKIAIOSFODNN7EXAMPLE"
#     secret_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

#     region = "main"
#     encrypt = false
#     force_path_style = true
#     skip_region_validation = true
#     skip_metadata_api_check = true
#     skip_credentials_validation = true
#   }
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  #experiments = [module_variable_optional_attrs]
}

# VMware Provider
provider "vsphere" {
    user                 = var.vsphere_user
    password             = var.vsphere_password
    vsphere_server       = var.vsphere_server
    allow_unverified_ssl = true
}

# *** Configure the Windows DNS Provider using WinRM ***
# In order to use this provider, you need the following enabled:
# - WinRM HTTPS on the DNS server:
#     "winrm quickconfig -transport:https"
#     "winrm get winrm/config"
# - Firewall Rule allowing port 5986 on DNS server:
#     "$FirewallParam = @{ DisplayName = 'Windows Remote Management (HTTPS-In)'; Direction = 'Inbound'; LocalPort = 5986; Protocol = 'TCP'; Action = 'Allow'; Program = 'System' }; New-NetFirewallRule @FirewallParam"
# - Allow ServiceAccount user to WinRM by adding to proper group on DNS Server:
#     "net localgroup "Remote Management Users" /add dns_sa"
# - WinRM TrustedHosts enabled on client where running terraform:
#     "Set-Item WSMan:localhost\client\trustedhosts -value *"
provider "windns" {
  server   = var.dns_server
  username = var.dns_admin_username
  password = var.dns_admin_password
  usessl   = true
}

# Configure the DNS Provider - Not used in favor of Windows DNS provider above
# provider "dns" {
#   update {
#     server     = "dc-1.lucasnet.int"
#     gssapi {
#       realm    = upper(var.dns_zone_name)
#       username = var.dns_admin_username
#       password = var.dns_admin_password
#     }
#   }
# }

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
