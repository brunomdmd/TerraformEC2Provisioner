output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.vpc_default.id
}

output "subnet_public_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.subnet_public.id
}

output "subnet_private_id" {
  description = "ID da subnet privada"
  value       = aws_subnet.subnet_private.id
}

output "aws_vpc_cidr_block" {
  description = "CIDR block da VPC"
  value       = aws_vpc.vpc_default.cidr_block
}
