variable "environment" {
  description = "Nome do ambiente (ex: DEV, PROD)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o security group será criado"
  type        = string
}

variable "cidr_ipv4" {
  description = "CIDR block da VPC para tráfego interno"
  type        = string
}

variable "myip" {
  description = "Seu IP público em formato CIDR para acesso SSH e portas k8s (ex: 1.2.3.4/32)"
  type        = string
  sensitive   = true
  validation {
    condition     = can(cidrhost(var.myip, 0))
    error_message = "O valor de myip deve ser um CIDR válido (ex: 1.2.3.4/32)."
  }
}
