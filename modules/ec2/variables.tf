variable "ami_id" {
  description = "ID da AMI para as instâncias EC2"
  type        = string
}

variable "instance_count" {
  description = "Número de instâncias EC2 a criar"
  type        = number
  validation {
    condition     = var.instance_count > 0
    error_message = "O número de instâncias deve ser maior que 0."
  }
}

variable "instance_type" {
  description = "Tipo da instância EC2 (ex: t2.micro, t3.small)"
  type        = string
}

variable "key_name" {
  description = "Nome do par de chaves SSH para acesso às instâncias"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde as instâncias serão criadas"
  type        = string
}

variable "security_group_id" {
  description = "Lista de IDs de security groups a associar às instâncias"
  type        = list(string)
}

variable "environment" {
  description = "Nome do ambiente (ex: DEV, PROD)"
  type        = string
}

variable "os_type" {
  description = "Nome do SO (Usado para nome da instância)"
  type        = string
  validation {
    condition = contains([
      "AMAZON_LINUX_2023",
      "UBUNTU_24_04",
      "UBUNTU_22_04",
      "WINDOWS_2022",
      "WINDOWS_2019"
    ], var.os_type)
    error_message = ""  
  }
}