# Outputs

output "vm_base_name" {
   value = "${vsphere_virtual_machine.cluster_node.*.name}"
}

output "vm_ip_address" {
   value = "${vsphere_virtual_machine.cluster_node.*.default_ip_address}"
}

output "vm_full_info" {
    value = "${vsphere_virtual_machine.cluster_node.*}"
}
