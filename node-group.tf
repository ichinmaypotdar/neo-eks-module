resource "aws_iam_role" "eks-worker-node-role" {
  name = "${local.name_prefix}-${var.project}-eks-worker-node-role"

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
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-SSM-Managed-Instance-core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks-worker-node-role.name
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${local.name_prefix}-${var.project}-eks-node-group"
  node_role_arn   = aws_iam_role.eks-worker-node-role.arn
  subnet_ids = var.private_subnets
  instance_types = var.node_group_instance_type

  scaling_config {
    desired_size = var.desired_count
    max_size     = var.max_count
    min_size     = var.min_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-worker-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-worker-node-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-worker-node-SSM-Managed-Instance-core,
  ]
}
