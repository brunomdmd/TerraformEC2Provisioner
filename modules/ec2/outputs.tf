output "public_ip" {
  description = "IPs públicos das instâncias EC2"
  value       = aws_instance.ec2[*].public_ip
}

output "instance_ids" {
  description = "IDs das instâncias EC2"
  value       = aws_instance.ec2[*].id
}
