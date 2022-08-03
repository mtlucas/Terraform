# Local variables and random variables

resource "random_uuid" "rke2_token" {}  # Random server token for joining nodes into cluster

locals {
  rke2_cluster_fqdn   = "${var.vm_base_name}.${var.vm_domain}"
  rke2_install_script = [
    "source ~/.bashrc",
    "if [ ! -f /etc/rancher/rke2/rke2.yaml ]; then curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server INSTALL_RKE2_VERSION=\"${var.rke2_version}\" sh -; fi",
    "systemctl enable rke2-server.service && systemctl start rke2-server.service",
    "while true; do timeout 1 bash -c 'nc -z localhost 9345'; if [ \"$?\" == 0 ]; then break; fi; echo 'RKE2 node is not ready yet...'; sleep 10; done",
  ]
}
