resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  tags = merge(local.tags,
  {
    Name = "${local.tags["project_name"]}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags,
  {
    Name = "${local.tags["project_name"]}-igw"
  })
}


resource "aws_eip" "nat" {

  tags = merge(local.tags,
  {
     Name = "${local.tags["project_name"]}-nat-ip"
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.tags,
  {
     Name = "${local.tags["project_name"]}-nat"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags,
  {
     Name = "${local.tags["project_name"]}-private-rt"
  })
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags,
  {
     Name = "${local.tags["project_name"]}-public-rt"
  })
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_subnet" "public" {
  count = var.public_subnet_count
  availability_zone = data.aws_availability_zones.main.names[count.index]
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block, var.newbits, count.index + var.newbits/2)
  tags = merge(local.tags,
  {
    Name = "${local.tags["project_name"]}-public-${data.aws_availability_zones.main.names[count.index]}"
    "kubernetes.io/role/elb" = "1"
  })

  lifecycle {
    precondition {
      condition = local.az_number >= var.public_subnet_count
      error_message = "The current number of AZs is ${local.az_number} for region ${var.region}. Your number of desired subnets is bigger than that."
    }
  }

}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[count.index].id
}

resource "aws_subnet" "private" {
  count = var.private_subnet_count
  availability_zone = data.aws_availability_zones.main.names[count.index]
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block, var.newbits, count.index)
  tags = merge(local.tags,
  {
    Name = "${local.tags["project_name"]}-private-${data.aws_availability_zones.main.names[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  })
  lifecycle {
    precondition {
      condition = local.az_number >= var.private_subnet_count
      error_message = "The current number of AZs is ${local.az_number} for region ${var.region}. Your number of desired subnets is bigger than that."
    }
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private[count.index].id
}