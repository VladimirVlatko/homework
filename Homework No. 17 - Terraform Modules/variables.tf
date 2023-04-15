variable "my_name" { 
  type = string 
  description = "First name of the student" 
}

variable "location" {
  type        = string
  description = "The location where all resources will be placed."
}

variable "environment" {
  type        = string
  description = "The environment"
}

variable "my_public_ip" {
    type = string 
}

variable "my_password" {
    type = string 
}

variable "vms_subnet_id" {
  type = string
  default = ""
}