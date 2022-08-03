# Backend state storage - if required

#   backend "s3" {
#     key      = "terraform.tfstate"
#     bucket   = "terraform"
#     endpoint = "https://dev-k8s-m1.dev.rph.int/s3/"
    
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
