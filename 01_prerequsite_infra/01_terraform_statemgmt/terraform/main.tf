terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.12.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}

provider "aws" {
  region = "us-west-1"
  alias  = "us-west"
}
########## Data Source Start##############
data "aws_caller_identity" "current" {}
########## Data Source Ends##############

locals {
  owner = "account-mgmt"
  common_tags = {
    owner            = local.owner
    LastModifiedTime = timestamp()
    LastModifiedBy   = data.aws_caller_identity.current.arn
  }
}

resource "aws_kms_key" "terraform_state_management_bucket_key" {
  description = "KMS key used for terraform state management bucket"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "kms:*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": "${var.aws_org_id}"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket" "terraform_state_management_bucket" {
  bucket = "terraform-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObjectVersionTorrent",
                "s3:GetObjectTagging",
                "s3:GetObjectAcl",
                "s3:AbortMultipartUpload",
                "s3:GetObjectTorrent",
                "s3:RestoreObject",
                "s3:GetObjectVersion",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject",
                "s3:PutObjectVersionAcl",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetObjectVersionAcl",
                "s3:ListMultipartUploadParts",
                "s3:GetObjectVersionTorrent"
            ],
            "Resource": [
                "arn:aws:s3:::terraform-${data.aws_caller_identity.current.account_id}",
                "arn:aws:s3:::terraform-${data.aws_caller_identity.current.account_id}/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": "${var.aws_org_id}"
                }
            }
        }
    ]
}
POLICY
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state_management_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  replication_configuration {
    role = aws_iam_role.statemgmt_replication.arn

    rules {
      id     = "replicate-to-eu-central"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.destination_bucket.arn
        storage_class = "STANDARD"
      }
    }
  }

  lifecycle_rule {
    id      = "ObjExpiry"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
}

resource "aws_iam_role" "statemgmt_replication" {
  name = "${local.owner}-statemgmt-Replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication_policy" {
  name = "${local.owner}-statemgmt-Replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.terraform_state_management_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.terraform_state_management_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination_bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.statemgmt_replication.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket" "destination_bucket" {
  bucket   = "terraform-${data.aws_caller_identity.current.account_id}-us-west-1"
  provider = "aws.us-west"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_state_locking_lock_id" {
  name           = "terraform-state-locking"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}