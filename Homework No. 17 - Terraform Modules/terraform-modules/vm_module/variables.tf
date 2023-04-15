variable "base_name" { 
  type = string 
  description = "base name" 
}

variable "vms_subnet_id" {
  description = "ID of the subnet to deploy the VM into"
  type        = string
}

variable "my_public_ip" {
  description = "Public IP address of your computer/network"
  type        = string
}

variable "my_password" {
  description = "The password"
  type        = string
}

variable "location" {
  type        = string
  description = "The location where all resources will be placed."
}

