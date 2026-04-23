output "security_group_id" {
  description = "ID do security group criado"
  value       = aws_security_group.sg_default.id
}
