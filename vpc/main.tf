# VPC *******************************************
resource "aws_vpc" "midterm_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.midterm_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_A
  map_public_ip_on_launch = true

  tags = {
    Name = "App-Inet"
  }
}

resource "aws_subnet" "private_subnet_A" {
  vpc_id                  = aws_vpc.midterm_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zone_A
  map_public_ip_on_launch = false

  tags = {
    Name = "App-DB A"
  }
}

resource "aws_subnet" "private_subnet_B" {
  vpc_id                  = aws_vpc.midterm_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.availability_zone_B
  map_public_ip_on_launch = false

  tags = {
    Name = "App-DB B"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_A.id,
    aws_subnet.private_subnet_B.id
  ]

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.midterm_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.midterm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.midterm_vpc.id

    tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc_A" {
  subnet_id      = aws_subnet.private_subnet_A.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_B" {
  subnet_id      = aws_subnet.private_subnet_B.id
  route_table_id = aws_route_table.private_rt.id
}