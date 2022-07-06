resource "null_resource" "kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --kubeconfig eks_example_config.yml --region ${local.region} --name ${local.name}"
    interpreter = ["/bin/zsh", "-c"]
  }
}

resource "kubernetes_service_account" "aws_lb_controller" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }
  depends_on = [module.vpc ,module.eks]
}

resource "helm_release" "cert_manager" {
  name              = "cert-manager"
  repository        = "https://charts.jetstack.io"
  chart             = "cert-manager"
  namespace         = "cert-manager"
  create_namespace  = "true"
  force_update      = "true"
  dependency_update = "true"
  version           = "v1.4.0"

  set {
    name  = "webhook.securePort"
    value = "10260"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [module.vpc ,module.eks, module.eks_managed_node_group]
}

resource "helm_release" "aws_lb_controller" {
  name              = "aws-load-balancer-controller"
  repository        = "https://aws.github.io/eks-charts"
  chart             = "aws-load-balancer-controller"
  namespace         = "kube-system"
  force_update      = "true"
  dependency_update = "true"
  # version           = "2.2.1"

  set {
    name  = "clusterName"
    value = local.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "replicaCount"
    value = "1"
  }
  set {
    name  = "region"
    value = local.region
  }
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
  depends_on = [module.vpc, module.eks, module.eks_managed_node_group, kubernetes_service_account.aws_lb_controller, helm_release.cert_manager]
}