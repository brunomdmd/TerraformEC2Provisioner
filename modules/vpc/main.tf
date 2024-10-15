resource "aws_vpc" "main" {
    cidr_block = var.block_cidr

    tags = {
        Name = "VPC-${var.environment}"
        Ambiente = var.environment
    }
}

resource "aws_subnet" "subnet_public" {
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.az 
    tags = {
        Name = "SUBNET_PUBL-${var.environment}"
        Ambiente = var.environment
    }   
}

resource "aws_subnet" "subnet_private" {
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.az    
    tags = {
        Name = "SUBNET_PRIV-${var.environment}"
        Ambiente = var.environment
    }  
}

resource "aws_internet_gateway" "igw" {
    vpc_id     = aws_vpc.main.id
    tags = {
        Name = "IGW-${var.environment}"
        Ambiente = var.environment
    } 
}

resource "aws_route_table" "route_table" {
    vpc_id     = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_table.id
}