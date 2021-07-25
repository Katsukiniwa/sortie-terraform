// VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.5.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "express-ecs-staging-vpc"
  }
}

// Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "express-ecs-staging-public-subnet-a"
  }
}

// Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.64.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

// Elastic IP
resource "aws_eip" "nat-gateway" {
  vpc = true
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
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "express-ecs-staging-public-route-table"
  }
}

// Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "express-ecs-staging-private-route-table"
  }
}

// Route
resource "aws_route" "public-route" {
  route_table_id = aws_route_table.public-route-table.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// Association between public subnet and public route table
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

// Association between private subnet and private route table
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}
