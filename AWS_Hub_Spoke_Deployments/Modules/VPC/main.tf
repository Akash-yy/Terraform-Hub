resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

# Private
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[0]

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

# Public
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id     = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${count.index}"
  }
}

# TGW
resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnets)

  vpc_id     = aws_vpc.this.id
  cidr_block = var.tgw_subnets[count.index]
  availability_zone = var.azs[0]

  tags = {
    Name = "${var.name}-tgw-${count.index}"
  }
}

### Route tables
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  count  = length(aws_subnet.public) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}
