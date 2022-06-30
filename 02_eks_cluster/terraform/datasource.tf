data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

#Use this data source to lookup information about the current AWS partition in which Terraform is working
data "aws_partition" "current" {}
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}