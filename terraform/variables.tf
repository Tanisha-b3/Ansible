

variable "rg_name" {
  type        = string
  default     = "assignment34-rg"
  description = "Resource group name"
}

variable "location" {
  type        = string
  default     = "eastus"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your public SSH key (e.g. ~/.ssh/id_ed25519.pub)"
  default     = "~/ansible-onboarding/.ssh/id_rsa"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1ms"
}
