# Build-out EKS cluster with Fargate

resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = data.aws_iam_role.aws-eks-cluster-role.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  vpc_config {
    endpoint_private_access = "true"
    endpoint_public_access  = "false"
    subnet_ids              = [for s in data.aws_subnet.private_subnets : s.id]
  }

  timeouts {
    delete = "30m"
  }

  tags = {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  # Allow the cluster to use AWS IAM service accounts, must have EKSCTL installed (choco install eksctl -y)
  #provisioner "local-exec" {
  #  command = <<-EOT
  #    eksctl create iamserviceaccount --cluster=${var.name} --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --region ${data.aws_region.current.name} --approve
  #  EOT
  #}
  depends_on = [
    aws_cloudwatch_log_group.eks_cluster,
  ]
}

resource "aws_iam_openid_connect_provider" "eks-openid" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.openid_thumbprint_hash
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.name}-openid-connect-provider"
    Environment = var.environment
    ManagedBy   = "terraform"
  }  
  depends_on = [
    aws_eks_cluster.main,
  ]
}

# EKS Node group creation depends on var.node_group_create variable value
resource "aws_eks_node_group" "main" {
  count = var.node_group_create ? 1 : 0

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "nodegroup-${var.name}-t2-micro"
  node_role_arn   = data.aws_iam_role.aws-eks-node-instance-role.arn
  subnet_ids      = [for s in data.aws_subnet.private_subnets : s.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types  = ["t2.micro"]

  tags = {
    Name        = "nodegroup-${var.name}-t2-micro"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.main,
  ]
}

resource "aws_eks_fargate_profile" "kube-system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate-profile-kube-system"
  pod_execution_role_arn = data.aws_iam_role.aws-eks-fargate-pod-execution-role.arn
  subnet_ids             = [for s in data.aws_subnet.private_subnets : s.id]

  selector {
    namespace = "kube-system"
  }

  tags = {
    Name        = "fargate-profile-kube-system"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  # Patch coredns with Fargate fix and restart pods
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${data.external.env-vars.result["USERPROFILE"]}\\.kube\\eks-1-config"
    }
    command = <<-EOT
      & kubectl patch deployment coredns -n kube-system --type json -p="[{'op': 'remove', 'path': '/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type'}]"
      & kubectl rollout restart -n kube-system deployment coredns
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  lifecycle {
    ignore_changes = [
      
    ]
  }
  depends_on = [
    local_file.kubeconfig,
  ]
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate-profile-default"
  pod_execution_role_arn = data.aws_iam_role.aws-eks-fargate-pod-execution-role.arn
  subnet_ids             = [for s in data.aws_subnet.private_subnets : s.id]

  selector {
    namespace = "default"
  }

  tags = {
    Name        = "fargate-profile-default"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  depends_on = [
    aws_eks_fargate_profile.kube-system,
  ]
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 30

  tags = {
    Name        = "eks-cloudwatch-log-group-${var.name}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
