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
#   https://github.com/rancher/os2  (depracated)

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
    # *** Linux Customizations do not work without Perl or Cloud-init installed ***
    # Nodes will use DHCP for IP address assignment, and later a DNS record will be created
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
      # Configure cluster node with Hostname, .bashrc, linked dir, and rke2 config file
      "hostnamectl set-hostname ${self.name}.${var.vm_domain}",
      "printf '#!/bin/bash\nalias l=\"ls -la\"\nexport KUBECONFIG=/etc/rancher/rke2/rke2.yaml\n' > ~/.bashrc",
      # Make and Link /opt dirs to /usr/local/opt to support auto ROS2 partitioning scheme in order not to comsume root partition disk space
      "mkdir -p /usr/local/opt/cni /usr/local/opt/rke2 /usr/local/opt/rancher-system-agent",
      "ln -s /usr/local/opt/cni /opt && ln -s /usr/local/opt/rke2 /opt && ln -s /usr/local/opt/rancher-system-agent /opt",
      # Create and configure RKE2 /etc/rancher/rke2/config.yaml file - Always use first node name for additional nodes
      count.index > 0 ?  # If additional node, add "server" metadata to config file
        "printf 'server: https://${var.vm_base_name}-1.${var.vm_domain}:9345\ntoken: ${random_uuid.rke2_token.result}\nwrite-kubeconfig-mode: \"0644\"\ntls-san:\n  - \"${local.rke2_cluster_fqdn}\"\n  - \"${self.name}.${var.vm_domain}\"\nnode-label:\n  - \"nodetype=master\"\ncluster-domain: \"${local.rke2_cluster_fqdn}\"\n' > /etc/rancher/rke2/config.yaml" :
        "printf 'token: ${random_uuid.rke2_token.result}\nwrite-kubeconfig-mode: \"0644\"\ntls-san:\n  - \"${local.rke2_cluster_fqdn}\"\n  - \"${self.name}.${var.vm_domain}\"\nnode-label:\n  - \"nodetype=master\"\ncluster-domain: \"${local.rke2_cluster_fqdn}\"\n' > /etc/rancher/rke2/config.yaml",
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
