terraform {
  required_version = "1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.12.1"
    }
  }
   

  backend "s3" {
    key            = "ecr.tfstate"
    dynamodb_table = "terraform-state-locking"
  }
}

locals {
  owner = var.owner_id
  environment_id = var.environment_id
  common_tags = {
    owner = local.owner
    environment = local.environment_id
    LastModifiedTime = timestamp()
    LastModifiedBy   = data.aws_caller_identity.current.arn
  }
} 

provider "aws" {
  # Configuration options
    region = var.aws_region
}
