resource "aws_vpc" "vpc_default" {
    cidr_block = var.block_cidr

    tags = {
        Name = "VPC-${var.environment}"
        Ambiente = var.environment
    }
}

resource "aws_subnet" "subnet_public" {
    vpc_id     = aws_vpc.vpc_default.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.az 
    tags = {
        Name = "SUBNET_PUBL-${var.environment}"
        Ambiente = var.environment
    }   
}

resource "aws_subnet" "subnet_private" {
    vpc_id     = aws_vpc.vpc_default.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.az    
    tags = {
        Name = "SUBNET_PRIV-${var.environment}"
        Ambiente = var.environment
    }  
}

resource "aws_internet_gateway" "igw" {
    vpc_id     = aws_vpc.vpc_default.id
    tags = {
        Name = "IGW-${var.environment}"
        Ambiente = var.environment
    } 
}

resource "aws_route_table" "route_table_public" {
    vpc_id     = aws_vpc.vpc_default.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "RT-PUBLIC-${var.environment}"
        Ambiente = var.environment
    }     
}

resource "aws_route_table_association" "route_table_assosc_public" {
    subnet_id      = aws_subnet.subnet_public.id
    route_table_id = aws_route_table.route_table_public.id
}


resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.subnet_public.id
        tags = {
            Name = "NGW-${var.environment}"
            Ambiente = var.environment
        } 
}

resource "aws_route_table" "route_table_private" {
    vpc_id     = aws_vpc.vpc_default.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ngw.id
    }    
    tags = {
        Name = "RT-PRIVATE-${var.environment}"
        Ambiente = var.environment
    }         
}

resource "aws_route_table_association" "route_table_assosc_private" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.route_table_private.id
}