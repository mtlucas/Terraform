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

  count                = var.vm_count

  name                 = lower("${var.vm_name}-${count.index + 1}")
  resource_pool_id     = data.vsphere_host.host.resource_pool_id
  datastore_id         = data.vsphere_datastore.datastore.id
  folder               = var.vsphere_virtual_machine_folder

  num_cpus             = var.vm_cpus
  num_cores_per_socket = var.vm_cores
  cpu_hot_add_enabled  = true
  memory               = var.vm_memory * 1024
  guest_id             = data.vsphere_virtual_machine.template_current.guest_id
  firmware             = data.vsphere_virtual_machine.template_current.firmware
  scsi_type            = data.vsphere_virtual_machine.template_current.scsi_type

  network_interface {
    network_id         = data.vsphere_network.network.id
    adapter_type       = data.vsphere_virtual_machine.template_current.network_interface_types[0]
    use_static_mac     = false
  }

  disk {
    label              = "disk0"
    size               = data.vsphere_virtual_machine.template_current.disks.0.size
    eagerly_scrub      = data.vsphere_virtual_machine.template_current.disks.0.eagerly_scrub
    thin_provisioned   = data.vsphere_virtual_machine.template_current.disks.0.thin_provisioned
  }

  clone {
    template_uuid      = data.vsphere_virtual_machine.template_current.id
    # *** Linux Customizations do not work without Perl or Cloud-init installed ***
	# customize {
    #   linux_options {
    #     host_name      = var.vm_name
    #     domain         = var.vm_domain
    #   }
    #   network_interface {
    #     # Uses DHCP by default
    #     #ipv4_address    = var.ipv4_addresses[count.index]
    #     #ipv4_netmask    = var.ipv4_netmasks[count.index]
    #     #dns_server_list = var.vsphere_virtual_machine_dns_server_list
    #     #dns_domain      = var.vsphere_virtual_machine_domain
    #   }
    #   #ipv4_gateway      = var.vsphere_virtual_machine_ipv4_gateway
    #   timeout = 10
    # }
  }

  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_pass
    host     = vsphere_virtual_machine.cloned_virtual_machine[count.index].default_ip_address
  }

  # Do customizations:  Set hostname, add to Domain, enable kerberos auth, enable DynDNS, and upgrade all packages
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "hostnamectl set-hostname ${vsphere_virtual_machine.cloned_virtual_machine[count.index].name}.${var.vm_domain}",
      "nmcli con mod ens192 ipv4.dhcp-hostname ${vsphere_virtual_machine.cloned_virtual_machine[count.index].name}.${var.vm_domain}",
      "update-crypto-policies --set DEFAULT:AD-SUPPORT",
      "yum install samba-common-tools realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation authselect-compat -y",
      "echo '${var.vsphere_virtual_domain_admin_password}' | realm join ${var.vm_domain} -U ${var.vsphere_virtual_domain_admin_user}",
      "authconfig --enablesssd --enablesssdauth --enablemkhomedir --update",
      "printf '\ndyndns_update = true\ndyndns_refresh_interval = 43200\ndyndns_update_ptr = true\ndyndns_ttl = 3600\n' >> /etc/sssd/sssd.conf",
      "systemctl restart sssd",
      "sudo yum upgrade -y",
    ]
  }

  lifecycle {
    ignore_changes = [
      tags,
      num_cpus,
      memory,
    ]
  }
}
