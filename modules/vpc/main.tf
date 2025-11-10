resource "aws_vpc" "my_app_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "my_app_vpc"
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_app_vpc.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_app_vpc.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_2"
  }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_app_vpc.id
  cidr_block        = var.private_subnet_1_cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet_1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_app_vpc.id
  cidr_block        = var.private_subnet_2_cidr_block
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_subnet_2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_app_vpc.id
  tags = {
    Name = "my_app_igw"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "my_app_nat_eip"
  }
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "my_app_nat_gw"
  }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}
resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "public_instance_sg" {
  name        = "public_instance_sg"
  description = "Security group for instances in public subnet"
  vpc_id      = aws_vpc.my_app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_sg"
  description = "Security group for instances in private subnet"
  vpc_id      = aws_vpc.my_app_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_instance_sg.id]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.internal_alb_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
