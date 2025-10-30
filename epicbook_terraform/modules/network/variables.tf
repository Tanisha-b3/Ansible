variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "public_subnet_name" {
  type = string
}

variable "mysql_subnet_name" {
  type = string
}

variable "public_nsg_name" {
  type = string
}

variable "private_nsg_name" {
  type = string
}

variable "allowed_ip" {
  type = string
}

variable "tags" {
  type = map(string)
}
