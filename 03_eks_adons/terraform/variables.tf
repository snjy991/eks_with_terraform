#Generice variables
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "environment_id" {
  description = "Environment id"
  type        = string
  default     = "dev"
}

variable "owner_id" {
  description = "org id"
  type        = string
  default     = "sanjay"
}

#Generic Variable ends
variable "aws_load_balancer_service_account_name" {
  description = "service account name for aws load balancer controller"
  type        = string
  default     = "aws-load-balancer-controller"
}