data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-${data.aws_caller_identity.current.account_id}"
    key    = "env:/dev/eks_cluster.tfstate"
    region = var.aws_region
  }
}

terraform {
  required_version = "1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.12.1"
    }
    helm = {
      source = "hashicorp/helm"
      #version = "2.5.1"
      version = "~> 2.5"
    }
    http = {
      source = "hashicorp/http"
      #version = "2.1.0"
      version = "~> 2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }
  backend "s3" {
    key            = "eks_adons.tfstate"
    dynamodb_table = "terraform-state-locking"
  }
}

locals {
  owner          = var.owner_id
  environment_id = var.environment_id
  name           = "${var.owner_id}-${var.environment_id}"
  common_tags = {
    owners           = local.owner
    environment      = local.environment_id
    LastModifiedTime = timestamp()
    LastModifiedBy   = data.aws_caller_identity.current.arn
  }
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
provider "http" {
  # Configuration options
}