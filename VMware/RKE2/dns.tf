# Get IP address and create DNS record - based on VM creation

resource "dns_a_record_set" "rke2_node_dns_records" {

  for_each  = { for item in vsphere_virtual_machine.cluster_node: item.name => item }

  zone      = lower("${var.vm_domain}.")
  name      = each.key
  addresses = [each.value["default_ip_address"]]
  ttl       = 300
}

# Add cluster DNS entry if not using load balancer
resource "dns_cname_record" "rke2_cluster_cname_record" {

  zone      = lower("${var.vm_domain}.")
  name      = var.vm_base_name
  cname     = "${var.vm_base_name}-1.${var.vm_domain}."  # Use first node for CNAME record
  ttl       = 300
}
