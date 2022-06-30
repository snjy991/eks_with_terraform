variable "chart_repo" {
  description = "Helm chart repository for aws load balancer controller"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "chart_name" {
  description = "Helm chart name for aws load balancer controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "chart_version" {
  description = "Helm chart version for aws load balancer controller"
  type        = string
  default     = "1.4.2"
}

variable "helm_chart_extra_set_configs" {
  type    = list(any)
  default = []
}

variable "aws_ecr_repo" {
  description = "ECR repo url for aws load balancer images it changes based on region"
  type        = string
  default     = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"

}

variable "aws_ecr_repo_tag" {
  description = "aws load balancer controller image tag"
  type        = string
  default     = "v2.4.2"
}

variable "create_service_account" {
  description = "flag for creating service account for aws load balancer controller"
  type        = bool
  default     = true

}
