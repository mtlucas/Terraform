# VMware Provider

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

provider "vsphere" {
    user                 = var.vsphere_user
    password             = var.vsphere_password
    vsphere_server       = var.vsphere_server
    allow_unverified_ssl = true
}
