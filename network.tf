// VPC
resource "aws_vpc" "express-ecs-staging-vpc" {
  cidr_block = "10.5.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "express-ecs-staging-vpc"
  }
}

// Public Subnet
resource "aws_subnet" "express-ecs-staging-public-subnet" {
  vpc_id = aws_vpc.express-ecs-staging-vpc.id
  cidr_block = "10.5.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "express-ecs-staging-public-subnet-a"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "express-ecs-staging-igw" {
  vpc_id = aws_vpc.express-ecs-staging-vpc.id

  tags = {
    Name = "express-ecs-staging-igw"
  }
}

// Route Table
resource "aws_route_table" "express-ecs-staging-public-route-table" {
  vpc_id = aws_vpc.express-ecs-staging-vpc.id

  tags = {
    Name = "express-ecs-staging-public-route-table"
  }
}

// Route
resource "aws_route" "express-ecs-staging-route" {
  route_table_id = aws_route_table.express-ecs-staging-public-route-table.id
  gateway_id = aws_internet_gateway.express-ecs-staging-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// Association between public subnet and route table
resource "aws_route_table_association" "express-ecs-staging-association" {
  subnet_id = aws_subnet.express-ecs-staging-public-subnet.id
  route_table_id = aws_route_table.express-ecs-staging-public-route-table.id
}
