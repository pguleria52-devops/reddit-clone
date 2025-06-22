resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags= {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.private_subnet, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "{$var.cluster_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.public_subnet)
  cidr_block = element(var.public_subnet, count.index)
  availability_zone = element(var.public_subnet, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "{$var.cluster_name}-public-subnet-${count.index +1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_eip" "elastic_ip" {
  count = length(var.public_subnet)
  domain = "vpc"
  tags = {
    Name = "${var.cluster_name}-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = length(var.public_subnet) 
  subnet_id = aws_subnet.public[count.index].id
  allocation_id = aws_eip.elastic_ip[count.index].id

  tags = {
    Name = "${var.cluster_name}-nat-gateway-{count.index+1}"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public-association" {
  count = length(var.public_subnet)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-route.id
  
}

resource "aws_route_table" "private-route" {
  count = length(var.private_subnet)  
  vpc_id = aws_vpc.vpc.id
  route  {
    cidr_block = "0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-route-table-${count.index +1}"
  }
}

resource "aws_route_table_association" "private-association" {
  count = length(var.private_subnet)
  route_table_id = aws_route_table.private-route[count.index].id
  subnet_id = aws_subnet.private[count.index].id
}