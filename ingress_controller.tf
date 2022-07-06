resource "aws_security_group_rule" "ingress_access" {
  description              = "Allow ingress communication with cluster"
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  security_group_id        = module.eks_managed_node_group.security_group_id
  source_security_group_id = module.eks.cluster_security_group_id
}

resource "helm_release" "ingress_controller" {
  name              = "ingress-nginx-controller"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  namespace         = "ingress-nginx"
  create_namespace  = "true"
  dependency_update = "true"
  force_update      = "true"
  recreate_pods     = "true"
  reset_values      = "true"
  version           = "4.0.17"

  values = [yamlencode(
    {
      "nodeSelector" : {
        "eks.amazonaws.com/nodegroup" : "${trim(trim(module.eks_managed_node_group.node_group_id, local.name), ":")}"
      },
      "controller" : {
        "image" : {
          "allowPrivilegeEscalation" : "false"
        },
        "metrics" : {
          "enabled" : "true",
          "service" : {
            "annotations" : {
              "prometheus.io/port" : "10254",
              "prometheus.io/scrape" : "true"
            }
          }
        },
        "podAnnotations" : {
          "prometheus.io/port" : "10254",
          "prometheus.io/scrape" : "true"
        },
        "service" : {
          "annotations" : {
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "tcp",
            "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true",
            "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing",
            "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb-ip"
          }
        }
      }
    }
  )]

  depends_on = [module.vpc ,module.eks, module.eks_managed_node_group, kubernetes_service_account.aws_lb_controller, helm_release.cert_manager, helm_release.aws_lb_controller]
}