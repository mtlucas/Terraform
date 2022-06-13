
terraform {

    required_version = ">= 0.14"
    
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.8.0"
        }
    }
    # Optional attributes and the defaults function are
    # both experimental, so we must opt in to the experiment.
    experiments = [module_variable_optional_attrs]
}
