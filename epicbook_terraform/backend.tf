terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate2-rg"
    storage_account_name = "epicbooktfstate10"
    container_name       = "tfstate"
    key                  = "epicbook.terraform.tfstate"
  }
}
