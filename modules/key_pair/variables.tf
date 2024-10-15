variable "key_name" {
  default = "staging-key.pub"
  type        = string
}

variable "key_path" {
  default = "../../environments/prod/staging-key.pub"
  type        = string
}
