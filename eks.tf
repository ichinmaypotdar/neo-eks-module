resource "aws_iam_role" "eks-cluster-role" {
  name = "${local.name_prefix}-${var.project}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_security_group" "eks-cluster-security-group" {
  name        = "${local.name_prefix}-${var.project}-eks-cluster-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 # ingress {
  #  from_port   = 22
   # to_port     = 22
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #} 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    #security_groups = [var.vpn_securitygroup]
    cidr_blocks = [var.vpn_securitygroup]                    #only for v4 eks cluster
    description = "Access from vpn"
  }   

}


resource "aws_eks_cluster" "eks-cluster" {
  name  = "${local.name_prefix}-${var.project}-eks-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster-security-group.id]
    subnet_ids = var.eks_cluster_subnets
    endpoint_public_access = var.eks_public_access
    endpoint_private_access = var.eks_private_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
  ]
}

data "tls_certificate" "eks-cluster-thumbprint" {
  url = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks-cluster-oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster-thumbprint.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
}