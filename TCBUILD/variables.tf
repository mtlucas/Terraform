# Variables and data used

variable "win_build_agent_vm_start_num" {
    type    = number
    default = 1
}

variable "win_build_agent_vm_end_num" {
    type    = number
    default = 1
}

variable "win_build_agent_vm_upgrade_slider_num" {
    type    = number
	default = 0
}

variable "win_build_agent_vm_template_current" {
    type    = string
	default = "TCBUILD-BASE_CURRENT"
}

variable "win_build_agent_vm_template_previous" {
    type    = string
	default = "TCBUILD-BASE_PREVIOUS"
}

# vsphere login account. defaults to admin account
variable "vsphere_user" {
    type    = string
	default = "test_user"
}

# vsphere account password. empty by default.
variable "vsphere_password" {
    type    = string
	default = "test_pass"
}

# vsphere server, defaults to localhost
variable "vsphere_server" {
    type    = string
	default = "localhost"
}

# vsphere datacenter the virtual machine will be deployed to.
variable "vsphere_datacenter" {
    type    = string
	default = "test_datacenter1"
}

# vsphere resource pool the virtual machine will be deployed to.
variable "vsphere_host" {
    type    = string
	default = "test_host1"
}

# vsphere datastore the virtual machine will be deployed to.
variable "vsphere_datastore" {
    type    = string
	default = "test_datastore"
}

# vsphere network the virtual machine will be connected to.
variable "vsphere_network" {
    type    = string
	default = "test_network"
}

# the name of the vsphere virtual machine that is created. empty by default.
#variable "vsphere_virtual_machine_name" {}

variable "vsphere_compute_cluster_name" {
	type    = string
	default = "test_cluster"
}

variable "vsphere_virtual_machine_dns_server_list" {
    type    = list
	default = ["1.1.1.1"]
}

variable "vsphere_virtual_machine_ipv4_gateway" {
    type    = string
	default = "1.1.1.1"
}

variable "vsphere_virtual_machine_domain" {
    type    = string
	default = "test_domain"
}

variable "vsphere_virtual_domain_admin_user" {
    type    = string
	default = "test_domain_admin_user"
}

variable "vsphere_virtual_domain_admin_password" {
    type    = string
	default = "test_domain_admin_pass"
}

variable "vsphere_virtual_admin_user" {
    type    = string
	default = "test_machine_admin_user"
}

variable "vsphere_virtual_admin_password" {
    type    = string
	default = "test_machine_admin_pass"
}

variable "vsphere_virtual_machine_folder" {
    type    = string
	default = "test_vm_folder"
}

variable "vsphere_storage_policy" {
    type    = string
	default = "test_storage_policy"
}

variable "custom_command_list" {
    type    = list
	default = ["\\test.cmd"]
}

# vSphere data collection
data "vsphere_datacenter" "dc" {
	name          = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
	name          = var.vsphere_datastore
	datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
	name          = var.vsphere_host
	datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
	name          = var.vsphere_network
	datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
	name          = var.vsphere_compute_cluster_name
	datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_current" {
	name          = var.win_build_agent_vm_template_current
	datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_previous" {
	name          = var.win_build_agent_vm_template_previous
	datacenter_id = data.vsphere_datacenter.dc.id
}

# This map variable was converted to local and built dynamically
# Boolean --> True = Current template, False = Previous template
#variable "win_build_agent_vm_template_upgrade_map" {
#    type = map(string = bool)
#}
locals {
    win_build_agent_vm_template_upgrade_map = {
        for i in range(var.win_build_agent_vm_start_num, var.win_build_agent_vm_end_num + 1) : format("TCBUILD%02d", i) =>
            (i <= var.win_build_agent_vm_upgrade_slider_num ? true : false)
    }
}
