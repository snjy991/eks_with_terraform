resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "${local.name}-${data.aws_region.current.name}-AWSLoadBalancerControllerIAMPolicy-${var.environment_id}"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy = data.http.lbc_iam_policy.body
}

resource "aws_iam_role" "lbc_iam_role" {
  name = "${local.name}-${data.aws_region.current.name}-${var.environment_id}-lbc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:${var.aws_load_balancer_service_account_name}-${data.aws_region.current.name}-${var.environment_id}"
          }
        }        
      },
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn 
  role       = aws_iam_role.lbc_iam_role.name
}