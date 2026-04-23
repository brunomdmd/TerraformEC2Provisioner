variable "block_cidr" {
  description = "CIDR block da VPC (ex: 10.0.0.0/16)"
  type        = string
  validation {
    condition     = can(cidrhost(var.block_cidr, 0))
    error_message = "O valor de block_cidr deve ser um CIDR válido."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block da subnet pública"
  type        = string
  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "O valor de public_subnet_cidr deve ser um CIDR válido."
  }
}

variable "private_subnet_cidr" {
  description = "CIDR block da subnet privada"
  type        = string
  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "O valor de private_subnet_cidr deve ser um CIDR válido."
  }
}

variable "az" {
  description = "Availability Zone para as subnets (ex: us-east-1a)"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: QA, PROD)"
  type        = string
}
