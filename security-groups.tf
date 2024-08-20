resource "aws_security_group" "endpoints" {
  name        = "endpoints_sg"
  description = "Security group for VPC endpoints."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "endpoints_sg"
  })
}

resource "aws_security_group" "instances" {
  name        = "instances_sg"
  description = "Security group for EC2 instances."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "instances_sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "endpoints_egress" {
  security_group_id = aws_security_group.endpoints.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "instances_egress_all_ipv4" {
  security_group_id = aws_security_group.instances.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "instances_egress_all_ipv6" {
  security_group_id = aws_security_group.instances.id

  cidr_ipv6   = "::/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_ingress" {
  security_group_id = aws_security_group.endpoints.id

  referenced_security_group_id = aws_security_group.instances.id
  ip_protocol                  = -1
}

