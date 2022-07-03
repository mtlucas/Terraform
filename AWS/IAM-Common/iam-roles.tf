
resource "aws_iam_role" "aws-eks-cluster-role" {
  name                  = "aws-eks-cluster-role"
  description           = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "AWSServiceRoleForAmazonEKSNodegroup" {
  name                  = "AWSServiceRoleForAmazonEKSNodegroup"
  description           = "This policy allows Amazon EKS to create and manage Nodegroups"
  path                  = "/aws-service-role/eks-nodegroup.amazonaws.com/"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-nodegroup.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "aws-eks-node-instance-role" {
  name                  = "aws-eks-node-instance-role"
  description           = "This policy allows Amazon EKS to create and manage Nodegroups"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "aws-eks-fargate-pod-execution-role" {
  name                  = "aws-eks-fargate-pod-execution-role"
  description           = "This policy allows Amazon EKS to create and manage Fargate pods"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  lifecycle {
    prevent_destroy = true
  }
}

