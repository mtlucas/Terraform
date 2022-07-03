
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aws-eks-cluster-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-cluster-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.aws-eks-cluster-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-cluster-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
  role       = aws_iam_role.aws-eks-cluster-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-cluster-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterNLBPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterNLBPolicy.arn
  role       = aws_iam_role.aws-eks-cluster-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-cluster-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.aws-eks-fargate-pod-execution-role.name

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_iam_role.aws-eks-fargate-pod-execution-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.aws-eks-node-instance-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-node-instance-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws-eks-node-instance-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-node-instance-role]
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.aws-eks-node-instance-role.name

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_iam_role.aws-eks-node-instance-role]
}

/*
resource "aws_iam_role_policy_attachment" "AWSServiceRoleForAmazonEKSNodegroup" {
  policy_arn = "arn:aws:iam::aws:policy/AWSServiceRoleForAmazonEKSNodegroup"
  role       = aws_iam_role.AWSServiceRoleForAmazonEKSNodegroup.name

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_iam_role.AWSServiceRoleForAmazonEKSNodegroup]
}
*/
