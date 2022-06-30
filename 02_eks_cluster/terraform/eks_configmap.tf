locals {
  configmap_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks_nodegroup_role.name}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    #federated access of eks cluster to sso
    {
      rolearn= "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSReservedSSO_AdministratorAccess_c8d9d0016663dee4"
      username= "{{SessionName}}"
      groups= ["system:masters"]
    }
  ]
  # configmap_users = [
  #   # {
  #   #   userarn  = "arn:aws:iam::256271462265:user/sanjay"
  #   #   username = "sanjay"
  #   #   groups   = ["system:masters"]
  #   # },
  #   {
  #     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/azuredevops"
  #     username = "azuredevops"
  #     groups   = ["system:masters"]
  #   },    
  # ]
}

resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [aws_eks_cluster.eks_cluster  ]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(local.configmap_roles)
    # mapUsers = yamlencode(local.configmap_users)
  }  
}