variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "DEV"
}

variable "myip" {
  description = "Seu IP público em formato CIDR para acesso SSH e portas k8s (ex: 1.2.3.4/32)"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Número de instâncias EC2 no ambiente DEV"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Tipo da instância EC2 para QA (deve ser x86_64 para a AMI al2023)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome do par de chaves SSH"
  type        = string
  default     = "TERRAFORM-KEY"
}
