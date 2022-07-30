# Variables and data used

variable "vm_name" {
    type    = string
}

variable "vm_count" {
    type    = number
}

variable "vm_cpus" {
    type    = number
}

variable "vm_cores" {
    type    = number
}

variable "vm_memory" {
    type    = number
}

variable "org_name" {
    type    = string
}

variable "vm_template_current" {
    type    = string
}

# vsphere login account. defaults to admin account
variable "vsphere_user" {
    type    = string
}

# vsphere account password. empty by default.
variable "vsphere_password" {
    type    = string
}

# vsphere server, defaults to localhost
variable "vsphere_server" {
    type    = string
}

# vsphere datacenter the virtual machine will be deployed to.
variable "vsphere_datacenter" {
    type    = string
}

# vsphere resource pool the virtual machine will be deployed to.
variable "vsphere_host" {
    type    = string
}

# vsphere datastore the virtual machine will be deployed to.
variable "vsphere_datastore" {
    type    = string
}

# vsphere network the virtual machine will be connected to.
variable "vsphere_network" {
    type    = string
}

variable "vsphere_compute_cluster_name" {
	type    = string
}

variable "vsphere_virtual_machine_dns_server_list" {
    type    = list
	default = ["8.8.8.8"]
}

variable "vsphere_virtual_machine_ipv4_gateway" {
    type    = string
	default = "192.168.0.1"
}

variable "vsphere_virtual_machine_domain" {
    type    = string
}

# Domain account needed to add computer to Domain
variable "vsphere_virtual_domain_admin_user" {
    type    = string
}

variable "vsphere_virtual_domain_admin_password" {
    type    = string
}

# Template local Admin account
variable "vsphere_virtual_admin_user" {
    type    = string
}

variable "vsphere_virtual_admin_password" {
    type    = string
}

variable "vsphere_virtual_machine_folder" {
    type    = string
}

variable "vsphere_storage_policy" {
    type    = string
    default = "Management Storage Policy - Single Node"
}

variable "custom_command_list" {
    type    = list
	default = ["ping 8.8.8.8"]
}
