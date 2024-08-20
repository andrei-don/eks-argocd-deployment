# Adding SSM endpoints to access instances via SSM

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = [aws_subnet.private[0].id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  subnet_ids          = [aws_subnet.private[0].id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = [aws_subnet.private[0].id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
}