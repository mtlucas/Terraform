# User defined variable values - Auto-imported
#   Create env variables for passwords using automation:
#   ex. --> set TF_VAR_vm_root_pass=<PASSWORD>

# RKE2 cluster_name == vm_base_name + "." + vm_domain
vm_base_name                            = "rke"  # Use lowercase machine names, names will tack on a dash and incremental number
vm_domain                               = "lucasnet.int"
vm_username                             = "devops"  # Username to add to VMs using root passwd, not working
vm_count                                = 3  # This will add a dash ("-") and incremental counter to machine name
vm_cpus                                 = 2  # Total number of vCPUs, use even number
vm_cores                                = 2  # Number of Cores per socket
vm_memory                               = 4  # In Gigabytes
vm_subnet                               = "192.168.0.0"
vm_subnet_cidr                          = 24  # Subnet Mask (cidr number)
# Static IP configuration is not working yet due to limited Cloud-init functionaily in ROS2 (Elemental)
vm_static_ip_start_addr                 = 60  # Last octet static ip start number that increments by one, ex. 192.168.0.60
#vm_root_pass                            = "CHANGE_ME"  # Automation should include this var
vm_template_current                     = "LINUX_BASE"
org_name                                = "Lucasnet"
vsphere_user                            = "vsphere_sa@lucasnet.int"
#vsphere_password                        = "CHANGE_ME"  # Automation should include this var
vsphere_server                          = "vcenter-1.lucasnet.int"
vsphere_datacenter                      = "HomeLab"
vsphere_compute_cluster_name            = "ClusterOne"
vsphere_host                            = "esxi-1.lucasnet.int"
vsphere_datastore                       = "datastore-1-1"
vsphere_network                         = "VM Network"
vsphere_virtual_machine_ipv4_gateway    = "192.168.0.1"
vsphere_virtual_machine_dns_server_list = ["192.168.0.50", "192.168.0.51"]
dns_server                              = "dc-1.lucasnet.int"
dns_admin_username                      = "dns_sa@lucasnet.int"
#dns_admin_password                      = "CHANGE_ME"  # Automation should include this var
rancher_create                          = true
rancher_version                         = "2.6.6"
cert_manager_version                    = "1.9.1"
rke2_version                            = "v1.23.9+rke2r1"
