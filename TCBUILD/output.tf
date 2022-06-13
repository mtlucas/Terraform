# Outputs

output "vm_name" {
   value = "${vsphere_virtual_machine.cloned_virtual_machine_win_build_agent.*.name}"
}

output "vm_ip_address" {
   value = "${vsphere_virtual_machine.cloned_virtual_machine_win_build_agent.*.default_ip_address}"
}

output "vm_moref" {
   value = "${vsphere_virtual_machine.cloned_virtual_machine_win_build_agent.*.moid}"
}
