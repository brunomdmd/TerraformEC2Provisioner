output "private_ip" {
  description = "IPs privados das instâncias EC2"
  value       = module.ec2.private_ip
}

output "public_ip" {
  description = "IPs públicos das instâncias EC2"
  value       = module.ec2.public_ip
}

output "instance_name" {
  description = "Nomes das instâncias EC2"
  value       = module.ec2.instance_name
}

output "instance_ids" {
  description = "IDs das instâncias EC2"
  value       = module.ec2.instance_ids
}
