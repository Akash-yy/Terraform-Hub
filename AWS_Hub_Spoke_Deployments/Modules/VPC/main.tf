resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_hostnames = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnets)

  vpc_id     = aws_vpc.this.id
  cidr_block = var.tgw_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-tgw-${count.index}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
