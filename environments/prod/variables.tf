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

variable "os_type" {
  description = "Escolha o SO das instâncias: AMAZON_LINUX_2023, UBUNTU_22_04, UBUNTU_24_04, WINDOWS_2019, WINDOWS_2022"
  type        = string
  validation {
    condition = contains([
      "AMAZON_LINUX_2023",
      "UBUNTU_24_04",
      "UBUNTU_22_04",
      "WINDOWS_2022",
      "WINDOWS_2019"
    ], var.os_type)
    error_message = "Os valores aceitos são: AMAZON_LINUX_2023, UBUNTU_22_04, UBUNTU_24_04, WINDOWS_2019, WINDOWS_2022"  
  }
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
