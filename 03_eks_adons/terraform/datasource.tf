data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}
