variable "db_admin_username" {
  description = "MySQL administrator username"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
}

variable "epicbook_repo_url" {
  description = "GitHub repository URL for EpicBook"
  type        = string
  default     = "https://github.com/your-username/epicbook.git"
}

variable "epicbook_branch" {
  description = "Git branch to deploy"
  type        = string
  default     = "main"
}
