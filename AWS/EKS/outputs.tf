# Outputs

output "aws_eks_cluster_main_id" {
  value = "${aws_eks_cluster.main.id}"
}

output "aws_eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "aws_eks_cluster_security_group" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "kubernetes_ingress_whoami_url" {
  value = var.whoami_create ? kubernetes_ingress_v1.whoami[0].status[0].load_balancer[0].ingress[0].hostname : "NOT CREATED"
}

output "kubernetes_ingress_rancher_url" {
  value = var.rancher_create ? kubernetes_ingress_v1.rancher[0].status[0].load_balancer[0].ingress[0].hostname : "NOT CREATED"
}

output "certificates" {
  value = module.certificates
}

output "env-vars" {
  value = data.external.env-vars.result
}
