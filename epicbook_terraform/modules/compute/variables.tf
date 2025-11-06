variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "public_nsg_id" {
  type = string
}

variable "mysql_host" {
  type = string
}

variable "mysql_username" {
  type      = string
  sensitive = true
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

variable "epicbook_repo_url" {
  type = string
}

variable "epicbook_branch" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ssh_private_key_path" {
 type=string
 default ="~/ansible-onboarding/.ssh/id_rsa.pub"
}
