##########################################################
# Developed by: Michael Lucas (mike@lucasnet.org)        #
##########################################################

##########################################################
# Main.tf for RKE2 cluster buildout using RancherOS2     #
#                                                        #
# This will deploy a RKE2 cluster based solely of        #
# controle-plane (master) nodes.  These nodes are        #
# schedulable.  For HA scenarios, you should use an odd  #
# number of nodes.  In addition to VM creation, it will  #
# add DNS entries to Windows host.  The latest version   #
# Rancher is also installed.                             #
#                                                        #
#  Requirements to execute:                              #
#  - vSphere account with correct permissions            #
#  - RKE2 Kubernetes valid release version               #
#  - Execute terraform on Windows machine only           #
#  - Access to Windows DNS server and service account    #
##########################################################

# References:
#   https://github.com/rancher/elemental
#   https://github.com/rancher/os2  (deprecated)

# Execute terraform syntax:  'terraform apply -var dns_admin_password="<password>" -auto-approve'

# Create cluster nodes and basic configuration
resource "vsphere_virtual_machine" "cluster_node" {

  count                = var.vm_count

  name                 = lower("${var.vm_base_name}-${count.index + 1}")
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
    # *** vSphere Linux Customizations do not work without Perl or Cloud-init installed ***
    # RancherOS2 cloud-init only reads on inital install, and will not work for templates/clones
    # customize {
    #   linux_options {
    #     host_name      = lower("${var.vm_base_name}-${count.index + 1}")
    #     domain         = var.vm_domain
    #   }
    #   network_interface {
    #     ipv4_address   = "${cidrhost("${var.vm_subnet}/${var.vm_subnet_cidr}", (count.index + var.vm_static_ip_start_addr))}"
    #     ipv4_netmask   = var.vm_subnet_cidr
    #   }
    #   dns_server_list  = var.vsphere_virtual_machine_dns_server_list
    #   dns_suffix_list  = [var.vm_domain]
    #   ipv4_gateway     = var.vsphere_virtual_machine_ipv4_gateway
    # }
  }

  # Setting guestinfo for Cloud-init metadata and userdata - RancherOS2 does not fully support this yet :(
  # The following is for Static IP assignment -- We will default to using DHCP and ignore this for now
  extra_config = {
    "guestinfo.metadata" = base64gzip(templatefile("${path.module}/templates/metadata.tpl",
      {
        hostname    = lower("${var.vm_base_name}-${count.index + 1}")
        ip_address  = "${cidrhost("${var.vm_subnet}/${var.vm_subnet_cidr}", (count.index + var.vm_static_ip_start_addr))}/${var.vm_subnet_cidr}"
        gateway     = var.vsphere_virtual_machine_ipv4_gateway
        nameservers = var.vsphere_virtual_machine_dns_server_list
        domain      = var.vm_domain
      }
    ))
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata" = base64gzip(templatefile("${path.module}/templates/userdata.tpl", 
      {
        hostname    = lower("${var.vm_base_name}-${count.index + 1}")
        username    = var.vm_username
        password    = bcrypt(var.vm_root_pass)  # User password same as root
        ip_address  = "${cidrhost("${var.vm_subnet}/${var.vm_subnet_cidr}", (count.index + var.vm_static_ip_start_addr))}/${var.vm_subnet_cidr}"
        gateway     = var.vsphere_virtual_machine_ipv4_gateway
        nameservers = var.vsphere_virtual_machine_dns_server_list
        domain      = var.vm_domain
      }
    ))
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

  tags = [        
    "${vsphere_tag.tag-environment-dev.id}",
    "${vsphere_tag.tag-application-k8s.id}"   
  ]

  connection {
    type     = "ssh"
    user     = var.vm_root_user
    password = var.vm_root_pass
    host     = self.default_ip_address
  }

  # Do customizations:  Set hostname, configure and install RKE2 server nodes
  # FUTURE NFS mount:  "mount -t nfs truenas-1.lucasnet.int:/mnt/pool-1/nfs /usr/local/mnt"
  provisioner "remote-exec" {
    inline = [
      # Configure cluster node with hostname, .bashrc, motd, and rke2 config file
      "printf '#!/bin/bash\nalias l=\"ls -la\"\n' > /root/.bashrc",
      "echo 'H4sIAAAAAAAAA3VQuw7DMAjc/RVsaaWG/Eg/AdXZoi7x0vE+vuZhk6FFlnUccJx4tuN4nwe1kz6NmQvVSh4Oxq8R9GjIQmU2toNJEdcMLiCCTeDyNhqUQZmyUSBAWWtGbAMu6/FTt3+PtcdiQq8U1s6bVnZFMpph5vfOa2L1f7qY/rYqKSzDfa8z7ekXc7FZ1R0rO1iiy7ktDmc6rNQ9DOusUFqN+7tk3BckDuyMAT2zXGh0GoWYAKVA0KWUL6jAVQoUAgAA' | base64 -d | gunzip > /etc/motd",
      "hostnamectl set-hostname ${self.name}.${var.vm_domain}",
      # Create and configure RKE2 /etc/rancher/rke2/config.yaml file - Always use cluster name in case load balancer is added
      count.index > 0 ?  # If additional node, add "server" metadata to config file
        "printf 'server: https://${var.vm_base_name}.${var.vm_domain}:9345\ntoken: ${random_uuid.rke2_token.result}\nwrite-kubeconfig-mode: \"0644\"\ntls-san:\n  - \"${local.rke2_cluster_fqdn}\"\n  - \"${self.name}.${var.vm_domain}\"\nnode-label:\n  - \"nodetype=master\"\ncluster-domain: \"${local.rke2_cluster_fqdn}\"\n' > /etc/rancher/rke2/config.yaml" :
        "printf 'token: ${random_uuid.rke2_token.result}\nwrite-kubeconfig-mode: \"0644\"\ntls-san:\n  - \"${local.rke2_cluster_fqdn}\"\n  - \"${self.name}.${var.vm_domain}\"\nnode-label:\n  - \"nodetype=master\"\ncluster-domain: \"${local.rke2_cluster_fqdn}\"\n' > /etc/rancher/rke2/config.yaml",
    ]
  }

  lifecycle {
    ignore_changes = [
      tags,
      num_cpus,
      memory,
      extra_config,
    ]
  }
}
