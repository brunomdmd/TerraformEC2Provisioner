variable "block_cidr" {
  type        = string
}

variable "public_subnet_cidr" {
  type        = string
}

variable "private_subnet_cidr" {
  type        = string
}

variable "az" {
  default     = "us-east-1b"
  type        = string
}

variable "environment" {
  default     = "Staging"
  type        = string
}
