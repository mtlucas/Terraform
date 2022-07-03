# Dynamic data - assumes EKS and ALB roles and policies already exist
# Requires applying IAM-Common terraform code first!

data "aws_vpc" "main" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Tier = "Public"
  }
}

data "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.id
}

data "aws_iam_openid_connect_provider" "main" {
  arn = aws_iam_openid_connect_provider.eks-openid.arn
}

##########################################################
# Apply these IAM Policies and Roles using EKS-IAM code  #
##########################################################
data "aws_iam_role" "aws-eks-node-instance-role" {
  name = "aws-eks-node-instance-role"
}

data "aws_iam_role" "aws-eks-fargate-pod-execution-role" {
  name = "aws-eks-fargate-pod-execution-role"
}

data "aws_iam_role" "aws-eks-cluster-role" {
  name = "aws-eks-cluster-role"
}

data "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
}

data "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name = "ALBIngressControllerIAMPolicy"
}

data "aws_acm_certificate" "issued" {
  domain   = var.ingress_cert_name
  statuses = ["ISSUED"]
}

data "external" "env-vars" {
  program = ["powershell", "${path.module}/scripts/env-vars.ps1"]
}

# Generate new thumbprint -- PROBLEM as it does every execution
# This has been converted to STATIC data as it remains the same for each Region until 2034
#data "external" "thumbprint" {
#  program =    ["${path.module}/scripts/oidc_thumbprint.sh", data.aws_region.current.name]
#  depends_on = [aws_eks_cluster.main]
#}
