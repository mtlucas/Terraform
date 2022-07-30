# Outputs

output "vm_name" {
   value = "${vsphere_virtual_machine.cloned_virtual_machine.*.name}"
}

output "vm_ip_address" {
   value = "${vsphere_virtual_machine.cloned_virtual_machine.*.default_ip_address}"
}

output "vm_moref" {
   value = "${vsphere_virtual_machine.cloned_virtual_machine.*.moid}"
}
