# Get IP address and create DNS record - based on VM creation

resource "windns" "rke2_node_dns_records" {

  for_each  = { for item in vsphere_virtual_machine.cluster_node: item.name => item }

  zone_name     = lower("${var.vm_domain}.")
  record_name   = each.key
  ipv4address   = each.value["default_ip_address"]
  record_type   = "A"
}

# Add cluster DNS entry if not using load balancer
resource "windns" "rke2_cluster_cname_record" {

  zone_name     = lower("${var.vm_domain}.")
  record_name   = lower(var.vm_base_name)
  hostnamealias = "${lower(var.vm_base_name)}-1.${lower(var.vm_domain)}."  # Use first node for CNAME record
  record_type   = "CNAME"
}
