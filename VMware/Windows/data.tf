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
	name          = var.vm_template_current
	datacenter_id = data.vsphere_datacenter.dc.id
}
