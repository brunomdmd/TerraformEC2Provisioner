variable "ami_id" {
  default     = "ami-06b21ccaeff8cd686"
  type        = string
}

variable "instance_count" {
  default     = "5"
  type        = number
}

variable "instance_type" {
  default     = "t2.nano"
  type        = string
}

variable "key_name" {
  default     = "prod-key.pub"
  type        = string
}

variable "subnet_id" {
  default     = "subnet00"
  type        = string
}

variable "security_group_id" {
  default     = ["sg00"]
  type        = list(string)
}

variable "environment" {
  default     = "Staging"
  type        = string
}