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
}

resource "vsphere_virtual_machine" "cloned_virtual_machine" {

  count                  = var.vm_count

  name                   = "${var.vm_name}-${count.index + 1}"
  resource_pool_id       = data.vsphere_host.host.resource_pool_id
  datastore_id           = data.vsphere_datastore.datastore.id
  folder                 = var.vsphere_virtual_machine_folder

  num_cpus               = var.vm_cpus
  num_cores_per_socket   = var.vm_cores
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  memory                 = var.vm_memory * 1024
  guest_id               = data.vsphere_virtual_machine.template_current.guest_id
  firmware               = data.vsphere_virtual_machine.template_current.firmware
  scsi_type              = data.vsphere_virtual_machine.template_current.scsi_type

  network_interface {
    network_id           = data.vsphere_network.network.id
    adapter_type         = data.vsphere_virtual_machine.template_current.network_interface_types[0]
    use_static_mac       = false
  }

  disk {
    label                = "disk0"
    size                 = data.vsphere_virtual_machine.template_current.disks.0.size
    eagerly_scrub        = data.vsphere_virtual_machine.template_current.disks.0.eagerly_scrub
    thin_provisioned     = data.vsphere_virtual_machine.template_current.disks.0.thin_provisioned
  }

  clone {
    template_uuid        = data.vsphere_virtual_machine.template_current.id
	customize {
      windows_options {
        computer_name         = "${var.vm_name}-${count.index + 1}"
        join_domain           = var.vsphere_virtual_machine_domain
        organization_name     = var.org_name
        domain_admin_user     = var.vsphere_virtual_domain_admin_user
        domain_admin_password = var.vsphere_virtual_domain_admin_password
        full_name             = var.vsphere_virtual_admin_user
        admin_password        = var.vsphere_virtual_admin_password
        auto_logon            = true
        time_zone             = "20"  # US Central
        run_once_command_list = var.custom_command_list
      }
      network_interface {
        # Uses DHCP by default
        #ipv4_address    = var.ipv4_addresses[count.index]
        #ipv4_netmask    = var.ipv4_netmasks[count.index]
        #dns_server_list = var.vsphere_virtual_machine_dns_server_list
        #dns_domain      = var.vsphere_virtual_machine_domain
      }
      #ipv4_gateway      = var.vsphere_virtual_machine_ipv4_gateway
      timeout = 10
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      num_cpus,
      memory,
    ]
  }
}
