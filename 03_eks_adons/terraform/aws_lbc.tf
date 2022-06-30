resource "helm_release" "loadbalancer_controller" {
  depends_on = [aws_iam_role.lbc_iam_role]
  name       = "aws-load-balancer-controller"
  repository = var.chart_repo
  chart      = var.chart_name
  namespace  = "kube-system"
  dynamic "set" {
    for_each = var.helm_chart_extra_set_configs
    content {
      name  = format("env.%s", set.value["name"])
      value = set.value["value"]
    }
  }

  values = [
    yamlencode(
      {
        image = {
          repository = var.aws_ecr_repo
          tag        = var.aws_ecr_repo_tag
        }
        serviceAccount = {
          create = var.create_service_account
          name   = "${var.aws_load_balancer_service_account_name}-${data.aws_region.current.name}-${var.environment_id}"
        }
        vpcId       = "${data.terraform_remote_state.eks.outputs.vpc_id}"
        region      = "${data.aws_region.current.name}"
        clusterName = "${data.terraform_remote_state.eks.outputs.cluster_id}"
      }
    )
  ]

  #   # Value changes based on your Region (Below is for us-east-1)
  #   set {
  #     name = "image.repository"
  #     value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller" 
  #     # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  #   }       

  #   set {
  #     name  = "serviceAccount.create"
  #     value = "true"
  #   }

  #   set {
  #     name  = "serviceAccount.name"
  #     value = "aws-load-balancer-controller"
  #   }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lbc_iam_role.arn
  }

  #   set {
  #     name  = "vpcId"
  #     value = "${data.terraform_remote_state.eks.outputs.vpc_id}"
  #   }  

  #   set {
  #     name  = "region"
  #     value = "${var.aws_region}"
  #   }    

  #   set {
  #     name  = "clusterName"
  #     value = "${data.terraform_remote_state.eks.outputs.cluster_id}"
  #   }    

}