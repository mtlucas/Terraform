# AWS Network resources, VPC, Subnets, Security groups, etc.

resource "aws_security_group_rule" "eks-allow-all-private-subnets" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["192.168.0.0/24", "10.0.0.0/16"]
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
