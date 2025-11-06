variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "mysql_server_name" {
  type = string
}

variable "mysql_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "db_admin_username" {
  type      = string
  sensitive = true
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}

variable "db_sku_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "backend_ip" {
  type = string
}