
resource "aws_eks_cluster" "eks" {
  name     = "${local.tags["project_name"]}-cluster"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids              = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
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
    desired_size = 1
    max_size     = 2
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
