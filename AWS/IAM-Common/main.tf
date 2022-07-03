# main.tf

terraform {

    required_version = "> 1.2"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 4.18.0"
        }
        local = {
            version = "~> 1.4"
        }
        external = {
            version = "~> 1.2"
        }
        template = {
            version = "~> 2.1"
        }
    }
    # Optional attributes and the defaults function are
    # both experimental, so we must opt in to the experiment.
    #experiments = [module_variable_optional_attrs]
}

# Sub modules
