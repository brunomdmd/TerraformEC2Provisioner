variable "ami_id" {
  type        = string
}

variable "instance_count" {
  type        = number
}

variable "instance_type" {
  type        = string
}

variable "key_name" {
  type        = string
}

variable "subnet_id" {
  type        = string
}

variable "security_group_id" {
  type        = list(string)
}

variable "environment" {
  type        = string
}