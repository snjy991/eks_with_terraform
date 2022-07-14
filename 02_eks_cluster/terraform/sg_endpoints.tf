resource "aws_security_group" "endpint_sg" {
  name        = "${local.name}-eks-endpointsg"
  description = "Security group to govern who can access the endpoints"
  vpc_id      =module.vpc.vpc_id
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }
  tags = local.common_tags
}