terraform {
  required_version = "1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }


  backend "s3" {
    key            = "eks_cluster.tfstate"
    dynamodb_table = "terraform-state-locking"
  }
}

locals {
  owner          = var.owner_id
  environment_id = var.environment_id
  name           = "${var.owner_id}-${var.environment_id}"
  common_tags = {
    owner            = local.owner
    environment      = local.environment_id
    LastModifiedTime = timestamp()
    LastModifiedBy   = data.aws_caller_identity.current.arn
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  # token = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.id]
    command     = "aws"
  }
}