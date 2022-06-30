
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

variable "repo_name" {
  description = "ecr repo name"
  type        = string
  default     = "pyapp"

}