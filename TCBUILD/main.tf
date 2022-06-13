# Main.tf

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

  backend "s3" {
    key      = "terraform.tfstate"
    bucket   = "terraform"
    endpoint = "https://dev-k8s-m1.dev.rph.int/s3/"
    
    access_key="AKIAIOSFODNN7EXAMPLE"
    secret_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

    region = "main"
    encrypt = false
    force_path_style = true
    skip_region_validation = true
    skip_metadata_api_check = true
    skip_credentials_validation = true
  }
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  #experiments = [module_variable_optional_attrs]
}

resource "vsphere_virtual_machine" "cloned_virtual_machine_win_build_agent" {

  for_each = local.win_build_agent_vm_template_upgrade_map

  name                 = each.key
  resource_pool_id     = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id         = data.vsphere_datastore.datastore.id
  folder               = var.vsphere_virtual_machine_folder

  num_cpus             = (each.value ? data.vsphere_virtual_machine.template_current.num_cpus : data.vsphere_virtual_machine.template_previous.num_cpus)
  num_cores_per_socket = (each.value ? data.vsphere_virtual_machine.template_current.num_cores_per_socket : data.vsphere_virtual_machine.template_previous.num_cores_per_socket)
  cpu_hot_add_enabled  = true
  memory               = (each.value ? data.vsphere_virtual_machine.template_current.memory : data.vsphere_virtual_machine.template_previous.memory)
  guest_id             = (each.value ? data.vsphere_virtual_machine.template_current.guest_id : data.vsphere_virtual_machine.template_previous.guest_id)
  firmware             = (each.value ? data.vsphere_virtual_machine.template_current.firmware : data.vsphere_virtual_machine.template_previous.firmware)
  scsi_type            = (each.value ? data.vsphere_virtual_machine.template_current.scsi_type : data.vsphere_virtual_machine.template_previous.scsi_type)

  network_interface {
    network_id         = data.vsphere_network.network.id
    adapter_type       = (each.value ? data.vsphere_virtual_machine.template_current.network_interface_types[0] : data.vsphere_virtual_machine.template_previous.network_interface_types[0])
  }

  disk {
    label              = "disk0"
    size               = (each.value ? data.vsphere_virtual_machine.template_current.disks.0.size : data.vsphere_virtual_machine.template_previous.disks.0.size)
    eagerly_scrub      = (each.value ? data.vsphere_virtual_machine.template_current.disks.0.eagerly_scrub : data.vsphere_virtual_machine.template_previous.disks.0.eagerly_scrub)
    thin_provisioned   = (each.value ? data.vsphere_virtual_machine.template_current.disks.0.thin_provisioned : data.vsphere_virtual_machine.template_previous.disks.0.thin_provisioned)
  }

  clone {
    template_uuid      = (each.value ? data.vsphere_virtual_machine.template_current.id : data.vsphere_virtual_machine.template_previous.id)
	  customize {
      windows_options {
        computer_name         = each.key
		    join_domain           = var.vsphere_virtual_machine_domain
        domain_admin_user     = var.vsphere_virtual_domain_admin_user
        domain_admin_password = var.vsphere_virtual_domain_admin_password
		    full_name             = var.vsphere_virtual_admin_user
        admin_password        = var.vsphere_virtual_admin_password
		    auto_logon            = true
		    time_zone             = "20"
		    run_once_command_list = var.custom_command_list
      }
	    network_interface {
		    #dns_server_list = var.vsphere_virtual_machine_dns_server_list
		    #dns_domain = var.vsphere_virtual_machine_domain
        #ipv4_gateway    = var.vsphere_virtual_machine_ipv4_gateway
	    }
    }
  }
}
