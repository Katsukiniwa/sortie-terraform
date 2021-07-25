// VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.5.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "express-ecs-staging-vpc"
  }
}

// Public Subnet A
resource "aws_subnet" "public-a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "express-ecs-staging-public-a"
  }
}

// Public Subnet C
resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "express-ecs-staging-public-c"
  }
}

// Private Subnet a
resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.68.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "express-ecs-staging-private-a"
  }
}

// Private Subnet c
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.69.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "express-ecs-staging-private-c"
  }
}

// Elastic IP
resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
}

// NAT Gateway
resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public-a.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_c.id
  depends_on = [aws_internet_gateway.igw]
}

// Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "express-ecs-staging-igw"
  }
}

// Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "express-ecs-staging-public-route-table"
  }
}

// Private Route Table
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "express-ecs-staging-private-route-table-a"
  }
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "express-ecs-staging-private-route-table-c"
  }
}

// Public Route
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// Private Route
resource "aws_route" "private_route_0" {
  route_table_id = aws_route_table.private_0.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_route_1" {
  route_table_id = aws_route_table.private_1.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

// Association between public subnet a and public route table
resource "aws_route_table_association" "public-a" {
  subnet_id = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

// Association between public subnet c and public route table
resource "aws_route_table_association" "public-c" {
  subnet_id = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

// Association between private subnet and private route table
resource "aws_route_table_association" "private_0" {
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

// Security Group
resource "aws_security_group" "security_group" {
  name = "express-ecs-staging-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.security_group.id
}
