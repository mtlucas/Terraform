##########################################################
# Developed by: Michael Lucas (mike@lucasnet.org)        #
##########################################################

##########################################################
# Main.tf for RockyLinux 9 minimal build-out             #
#                                                        #
# This will deploy a minimal RockyLinux 9 machine from   #
# vSphere template.                                      #
##########################################################

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
    host     = self.default_ip_address
  }

  # Do customizations:  Set hostname, add to Domain, enable kerberos auth, enable DynDNS, and upgrade all packages
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "hostnamectl set-hostname ${self.name}.${var.vm_domain}",
      "echo 'H4sIAAAAAAAAA62Ty2rDMBBF9/mKG7xoC6H+jkIXXTSLgmBQ7YktsCUzkhNa8vEd2X1k4SxcMkLS6HGPrgQqitvEpsCVoN/mYoKW9wLXQSUMcNZCRKon0jzXtaBSxSaD5uQug+gfoHIyYiYhUZm7yRGtBJWqBQwZOhslznrN7ulh7dXWxgR6CyOsMNgnFucbOJ8CLCJXo3Cd1+w27xI8vezwHBrn8ep63mEfWbzteQa1NuKd2cOHlHW+/puKSodiU8uay5EFtu6ddzGJTUG2l4723o6pDeI+M6aqOEacXNcpCoex6z7U4pFjco39OUh4CJIH32csvJEdBgmDONWgsye97yFIxX12Zhv2leP4uPhGt/oimy+0v1wPbQMAAA==' | base64 -d | gunzip > /etc/motd",
      "echo 'H4sIAAAAAAAAA5WTW0vDMBTH3/spjnOwDWwyqTiY+DDwceCDDz4YTC+227BpRlsG4vG729yaVafooZSTc/vlT5LzM5ruKpomzTYI1veru9vxNEtaoPtaZrSUyUty2MyCfb2r2gImbB5FT5c30UI85mUmRQ6tXLJqcqIAOAdjxnF/ZTbsCnyCEzfgWhCd70J9Egj3Rk5jEQD1QDz6KLiQdllPtQlAj0WV121ot4V4tE/8O7b7XYSdsfnVQqOePVoVT1UyHpCBuU7U6uOuQi1M5X/I2AuknHkuc/IHWAKxF4z9Dn/WqvYVEuMYebrbhKk9ME0iKjSzigdQZOC12rvwC9QeOwIzjj5I65qVXjNwlfSLTNuL4EeBZn8nzoUKBVUui7zNthCGmSxlzdNSZq8NyKJw9SMHiMTDW9PmAtbdm4HVYbN0N8ZMVBrG7+qFffSIUfAJU0/uOn8DAAA=' | base64 -d | gunzip > /etc/profile.d/lucasnet.sh",
      "nmcli con mod ens192 ipv4.dhcp-hostname ${self.name}.${var.vm_domain}",
      "update-crypto-policies --set LEGACY",
      "yum install neofetch samba-common-tools realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation authselect-compat nfs-utils iscsi-initiator-utils -y",
      "echo '${var.vsphere_virtual_domain_admin_password}' | realm join ${var.vm_domain} -U ${var.vsphere_virtual_domain_admin_user}",
      "authconfig --enablesssd --enablesssdauth --enablemkhomedir --update",
      "printf '\ndyndns_update = true\ndyndns_refresh_interval = 43200\ndyndns_update_ptr = true\ndyndns_ttl = 3600\n' >> /etc/sssd/sssd.conf",
      "printf 'Subsystem       powershell      /usr/bin/pwsh -sshs -NoLogo\n' >> /etc/ssh/sshd_config",
      "systemctl restart sssd",
      "systemctl disable firewalld",
      "sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config",
      "setenforce 0",
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
