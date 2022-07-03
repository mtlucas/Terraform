# ALB required IAM roles and policy attachments
# Requires applying IAM-Common terraform code first!

resource "aws_iam_role" "aws-eks-loadbalancer-role" {
  name                  = "aws-eks-loadbalancer-role-for-${var.name}"
  description           = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."
  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:${var.alb_service_account_name}",
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
ROLE
  depends_on = [
    aws_iam_openid_connect_provider.eks-openid,
  ]
}

resource "aws_iam_role_policy_attachment" "ALBIngressControllerIAMPolicy" {
  policy_arn = data.aws_iam_policy.ALBIngressControllerIAMPolicy.arn
  role       = aws_iam_role.aws-eks-loadbalancer-role.name

  depends_on = [
    aws_iam_role.aws-eks-loadbalancer-role,
  ]
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerIAMPolicy" {
  policy_arn = data.aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  role       = aws_iam_role.aws-eks-loadbalancer-role.name

  depends_on = [
    aws_iam_role.aws-eks-loadbalancer-role,
  ]
}
