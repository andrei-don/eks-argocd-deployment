
resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.id
  }

  set {
    name  = "image.tag"
    value = "v2.8.2"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  depends_on = [
    aws_eks_node_group.private-nodes,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach,
    kubernetes_service_account.aws_load_balancer_controller
  ]
}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  namespace        = "argo"
  create_namespace = true

  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.4.4"
  values     = [file("${path.module}/argo_values.yaml")]
  depends_on = [
    aws_eks_node_group.private-nodes,
    helm_release.aws-load-balancer-controller
  ]
}

resource "helm_release" "argo_ingress" {
  name             = "argo-ingress"
  namespace        = "argo"
  create_namespace = true
  chart            = "${path.module}/helm/argo-ingress"

  set {
    name  = "certArn"
    value = aws_acm_certificate.main.arn
  }
  set {
    name  = "namespace"
    value = "argo"
  }
  depends_on = [
    aws_eks_node_group.private-nodes,
  helm_release.argo_cd]
}