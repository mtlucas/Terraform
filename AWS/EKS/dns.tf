# Get data for Load balancer IP address and create DNS record - based on Whoami ingress

resource "dns_cname_record" "eks_cluster_cname_record" {
  count = var.whoami_create ? 1 : 0

  zone = lower("${var.dns_zone_name}.")
  name = aws_eks_cluster.main.name
  cname = "${kubernetes_ingress_v1.whoami[0].status[0].load_balancer[0].ingress[0].hostname}."
  ttl = 300
}
