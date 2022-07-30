vm_name                                 = "ADFS"
vm_count                                = 1  # This will add a dash ("-") and count to machine name
vm_cpus                                 = 2
vm_cores                                = 2  # Number of Cores per socket
vm_memory                               = 2  # In Gigabytes
vm_template_current                     = "WIN_BASE"
vm_template_previous                    = "WIN_BASE_old"
org_name                                = "Lucasnet"

vsphere_user                            = "vsphere_sa@lucasnet.int"
#vsphere_password                        = "CHANGE_ME"  # Automation should include this var
vsphere_server                          = "vcenter-1.lucasnet.int"
vsphere_datacenter                      = "HomeLab"
vsphere_datastore                       = "datastore-2-1"
vsphere_compute_cluster_name            = "ClusterOne"  # Not using Cluster at the moment
vsphere_host                            = "esxi-2.lucasnet.int"
vsphere_network                         = "VM Network"
vsphere_virtual_domain_admin_user       = "Mike"
#vsphere_virtual_domain_admin_password   = "CHANGE_ME"  # Automation should include this var
vsphere_virtual_machine_dns_server_list = ["192.168.0.50", "192.168.0.51"]
vsphere_virtual_machine_ipv4_gateway    = "192.168.0.1"
vsphere_virtual_admin_user              = "Adminstrator"
#vsphere_virtual_admin_password          = "CHANGE_ME"  # Automation should include this var
vsphere_virtual_machine_domain          = "lucasnet.int"
vsphere_virtual_machine_folder          = "Discovered virtual machine"
custom_command_list = [
    "DIR C:\\",
    "PING 8.8.8.8"
    ]
