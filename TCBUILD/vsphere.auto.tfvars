
win_build_agent_vm_start_num            = 10  # Build agent starting number, ex. TCBUILD10
win_build_agent_vm_end_num              = 65  # Build agent ending number
win_build_agent_vm_upgrade_slider_num   = 20  # Build agents > this number will use previous template, <= will use current (newest) template
win_build_agent_vm_template_current     = "TCBUILD-BASE-3_12"
win_build_agent_vm_template_previous    = "TCBUILD-BASE-3_11"

vsphere_user                            = "octopus_terraform_sa@hpl.com"
vsphere_password                        = "vsphere_password_CHANGEME"  # Automation will update this
vsphere_server                          = "vcenter1.hpl.com"
vsphere_datacenter                      = "Fitchburg Datacenter"
vsphere_datastore                       = "ESX_PURE_NP_iSCSI3"
vsphere_compute_cluster_name            = "Enterprise"
vsphere_storage_policy                  = "Keep existing VM storage policies"
vsphere_host                            = "esx-ent-13.hpl.com"
vsphere_network                         = "VLAN 628 - CorpDev"
vsphere_virtual_domain_admin_user       = "dev\\octopus_sa"
vsphere_virtual_domain_admin_password   = "domain_admin_password_CHANGEME"  # Automation will update this
vsphere_virtual_machine_dns_server_list = ["10.126.28.10", "10.198.34.3"]
vsphere_virtual_machine_ipv4_gateway    = "10.126.28.1"
vsphere_virtual_admin_user              = "Adminstrator"
vsphere_virtual_admin_password          = "admin_password_CHANGEME"  # Automation will update this
vsphere_virtual_machine_domain          = "dev.rph.int"
vsphere_virtual_machine_folder          = "Do Not Backup"
custom_command_list = [
    "DIR C:\\",
    "PING 8.8.8.8"
    ]
