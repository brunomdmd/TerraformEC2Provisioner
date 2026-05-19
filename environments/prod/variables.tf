variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "PROD"
}

variable "service" {
  description = "Nome do Serviço/Projeto"
  type        = string
  default     = "Serviço XPT"
}

variable "myip" {
  description = "Seu IP público em formato CIDR para acesso SSH e portas k8s (ex: 1.2.3.4/32)"
  type        = string
  sensitive   = true
  default     = "177.37.170.17/32"  
}

variable "os_type" {
  description = "Escolha o SO das instâncias: AMAZON_LINUX_2023, UBUNTU_22_04, UBUNTU_24_04, WINDOWS_2019, WINDOWS_2022"
  type        = string
  default     = "AMAZON_LINUX_2023"
  }

variable "private_instance_count" {
  description = "Número de instâncias EC2 na subnet privada"
  type        = number
  default     = 1
}

variable "public_instance_count" {
  description = "Número de instâncias EC2 na subnet pública"
  type        = number
  default     = 0
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
