variable "environment" {
  default     = "Staging"
  type        = string
}

variable "my_ip" {
  type        = list(string)
}

variable "vpc_id" {
  type        = string
}
