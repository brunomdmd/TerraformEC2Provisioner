output "private_subnet_private_ip" {
  description = "IPs privados das instâncias na subnet privada"
  value       = module.ec2_private.private_ip
}

output "private_subnet_public_ip" {
  description = "IPs públicos das instâncias na subnet privada"
  value       = module.ec2_private.public_ip
}

output "private_subnet_instance_name" {
  description = "Nomes das instâncias na subnet privada"
  value       = module.ec2_private.instance_name
}

output "private_subnet_instance_ids" {
  description = "IDs das instâncias na subnet privada"
  value       = module.ec2_private.instance_ids
}

output "public_subnet_private_ip" {
  description = "IPs privados das instâncias na subnet pública"
  value       = module.ec2_public.private_ip
}

output "public_subnet_public_ip" {
  description = "IPs públicos das instâncias na subnet pública"
  value       = module.ec2_public.public_ip
}

output "public_subnet_instance_name" {
  description = "Nomes das instâncias na subnet pública"
  value       = module.ec2_public.instance_name
}

output "public_subnet_instance_ids" {
  description = "IDs das instâncias na subnet pública"
  value       = module.ec2_public.instance_ids
}
