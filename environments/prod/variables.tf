variable "ami_id" {
  description = "ID da AMI a usar nas instâncias PROD (ex: ami-0abcdef1234567890). Consulte https://us-east-1.console.aws.amazon.com/ec2/home#AMICatalog"
  type        = string
  validation {
    condition     = can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "O ami_id deve estar no formato ami-xxxxxxxxxxxxxxxxx."
  }
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "PROD"
}

variable "myip" {
  description = "Seu IP público em formato CIDR para acesso SSH e portas k8s (ex: 1.2.3.4/32)"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Número de instâncias EC2 no ambiente PROD"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Tipo da instância EC2 para PROD (deve ser x86_64 para a AMI)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome do par de chaves SSH"
  type        = string
  default     = "TERRAFORM-KEY"
}
