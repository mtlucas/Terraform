# Variables, types and their descriptions

variable "vm_base_name" {
    type    = string
}

variable "vm_domain" {
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

variable "vm_root_user" {
  description = "root username for Base image (VM template)"
  type        = string
  default     = "root"
}

variable "vm_root_pass" {
  description = "root password for Base image (VM template)"
  type        = string
}

variable "vsphere_user" {
  description = "vsphere login account. defaults to admin account"
  type        = string
}

variable "vsphere_password" {
  description = "vsphere account password. empty by default."
  type        = string
}

variable "vsphere_server" {
  description = "vsphere server, defaults to localhost"
  type        = string
}

variable "vsphere_datacenter" {
  description = "vsphere datacenter the virtual machine will be deployed to."
  type        = string
}

variable "vsphere_host" {
  description = "vsphere resource pool the virtual machine will be deployed to."
  type        = string
}

variable "vsphere_datastore" {
  description = "vsphere datastore the virtual machine will be deployed to."
  type        = string
}

variable "vsphere_network" {
  description = "vsphere network the virtual machine will be connected to."
  type        = string
}

variable "vsphere_compute_cluster_name" {
  description = "vsphere cluster name"
  type        = string
}

variable "vsphere_virtual_machine_dns_server_list" {
  description = "DNS servers in list"
  type        = list
  default     = ["8.8.8.8"]
}

variable "vsphere_virtual_machine_ipv4_gateway" {
  description = "Default gateway address"
  type        = string
  default     = "192.168.0.1"
}

variable "vsphere_virtual_machine_folder" {
  description = "vsphere virtual machine folder for VMs"
  type        = string
  default     = "Discovered virtual machine"
}

variable "vsphere_storage_policy" {
  description = "vsphere storage policy to use"
  type        = string
  default     = "Management Storage Policy - Single Node"
}

variable dns_server {
  description = "Windows DNS zone name to create cluster name A record"
  type        = string
}

variable dns_admin_username {
  description = "Windows AD service account that can update DNS"
  type        = string
}

variable dns_admin_password {
  description = "Windows AD service account password"
  type        = string
}

variable rke2_version {
  description = "RKE2 release version, visit https://github.com/rancher/rke2/releases"
  type        = string
}

variable "cert_manager_version" {
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  type        = string
  default     = "1.7.3"
}

variable "rancher_version" {
  description = "Rancher server version (format v0.0.0)"
  type        = string
  default     = "2.6.6"
}

variable "rancher_password" {
  description = "Rancher password"
  type        = string
}

