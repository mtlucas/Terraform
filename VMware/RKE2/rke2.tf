# RKE2 cluster installs

resource "null_resource" "install_rke2_initial_node" {

  triggers = {
    node_id = "${vsphere_virtual_machine.cluster_node[0].id}"
  }

  count      = 1  # Initial node only [0]

  connection {
    type     = "ssh"
    user     = var.vm_root_user
    password = var.vm_root_pass
    host     = vsphere_virtual_machine.cluster_node[0].default_ip_address  # Install initial cluster node on first node [0]
  }

  provisioner "remote-exec" {
    # Bootstrap RKE2 install script for initial server node - Assumes config file already exists
    inline = concat(
      local.rke2_install_script,
      ["kubectl wait node/${vsphere_virtual_machine.cluster_node[0].name}.${var.vm_domain} --for=condition=ready --timeout=120s"]
    )
  }

  depends_on = [
    dns_a_record_set.rke2_node_dns_records,
  ]
}

resource "null_resource" "install_rke2_additional_node" {

  triggers = {
    node_id = "${vsphere_virtual_machine.cluster_node[0].id}"
  }

  count      = var.vm_count - 1  # Number of additional nodes (below code adds 1 to count.index)

  connection {
    type     = "ssh"
    user     = var.vm_root_user
    password = var.vm_root_pass
    host     = vsphere_virtual_machine.cluster_node[count.index + 1].default_ip_address  # Install initial cluster node on first node [0]
  }

  provisioner "remote-exec" {
    # Bootstrap RKE2 install script for additional server nodes - Assumes config file already exists
    inline = concat(
      local.rke2_install_script,
      ["kubectl wait node/${vsphere_virtual_machine.cluster_node[count.index + 1].name}.${var.vm_domain} --for=condition=ready --timeout=120s"]
    )
  }

  # Need DNS record for initial cluster node before attempting install on additional nodes
  depends_on = [
    null_resource.install_rke2_initial_node,
    dns_a_record_set.rke2_node_dns_records,
  ]
}

# Save kubeconfig file for interacting with the RKE cluster on your local machine
resource "local_file" "retrieve_kubeconfig" {
  filename = format("%s/%s", path.root, "kube_config_${var.vm_base_name}.yaml")
  content  = replace(data.remote_file.retrieve_kubeconfig.content, "127.0.0.1", local.rke2_cluster_fqdn)
}
