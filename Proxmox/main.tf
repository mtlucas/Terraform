# main.tf

terraform {

    required_version = ">= 0.14"

    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.8.0"
        }
        random = {
            source = "hashicorp/random"
            version = "3.1.3"
        }
    }
    # Optional attributes and the defaults function are
    # both experimental, so we must opt in to the experiment.
    experiments = [module_variable_optional_attrs]
}

# Sub modules
module "Windows" {
    source      = "./modules/windows"
    win2022_vms = var.win2022_vms
    random_num  = random_integer.unique_id.result
}

module "Linux" {
    source      = "./modules/linux"
    rl_vms      = var.rl_vms
    random_num  = random_integer.unique_id.result
}
