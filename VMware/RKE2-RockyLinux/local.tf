# Local variables and random variables

resource "random_uuid" "rke2_token" {}  # Random server token for joining nodes into cluster

locals {
  rke2_cluster_fqdn   = "${lower(var.vm_base_name)}.${lower(var.vm_domain)}"
  rke2_install_script = [
    # If no existing KUBECONFIG file exists, assume RKE2 is not installed and execute it with custom verion (variables)
    "if [ ! -f /etc/rancher/rke2/rke2.yaml ]; then curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server INSTALL_RKE2_VERSION=\"${var.rke2_version}\" sh -; fi",
    # Start rke2-server service and then wait for port 9345 to come alive
    "systemctl enable rke2-server.service && systemctl start rke2-server.service",
    # Add KUBECONFIG env variable pointing to new RKE2 config
    "if [ -f /etc/rancher/rke2/rke2.yaml ]; then printf 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml\n' >> ~/.bashrc; source ~/.bashrc; fi",
    "while true; do timeout 1 bash -c 'nc -z localhost 9345'; if [ \"$?\" == 0 ]; then break; fi; echo 'RKE2 node is not ready yet...'; sleep 10; done",
  ]
}
