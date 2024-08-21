
resource "aws_eks_cluster" "eks" {
  name     = "${local.tags["project_name"]}-cluster"
  role_arn = aws_iam_role.eks.arn
  vpc_config {
    subnet_ids              = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks.id]
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks]

  tags = merge(local.tags,
    {
      Name = "${local.tags["project_name"]}-cluster"
  })
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.tags["project_name"]}-cluster-workers"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = aws_subnet.private[*].id

  capacity_type  = "SPOT"
  instance_types = ["t2.small"]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = merge(local.tags,
    {
      Name = "${local.tags["project_name"]}-cluster-workers"
  })

}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.ec2_role.arn
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.ec2_role.arn
  access_scope {
    type = "cluster"
  }
}