provider "azurerm" {
  features {}
}

# Random suffix for global uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# Network Module
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location           = local.workspace_config.location
  vnet_name          = local.resource_names.vnet
  public_subnet_name = local.resource_names.public_subnet
  mysql_subnet_name  = local.resource_names.mysql_subnet
  public_nsg_name    = local.resource_names.public_nsg
  private_nsg_name   = local.resource_names.private_nsg
  allowed_ip         = local.workspace_config.allowed_ip
  tags               = local.workspace_config.tags
}

# Database Module
module "database" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.main.name
  location           = local.workspace_config.location
  mysql_server_name  = local.resource_names.mysql_server
  mysql_subnet_id    = module.network.mysql_subnet_id
  private_dns_zone_id = module.network.private_dns_zone_id
  db_admin_username  = var.db_admin_username
  db_admin_password  = var.db_admin_password
  db_sku_name        = local.workspace_config.db_sku_name
  tags               = local.workspace_config.tags

  # ADD THIS LINE to ensure network is ready before database
  depends_on = [module.network]
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.main.name
  location           = local.workspace_config.location
  vm_name            = local.resource_names.vm
  vm_size            = local.workspace_config.vm_size
  public_subnet_id   = module.network.public_subnet_id
  public_nsg_id      = module.network.public_nsg_id
  mysql_host         = module.database.mysql_fqdn
  mysql_username     = var.db_admin_username
  mysql_password     = var.db_admin_password
  epicbook_repo_url  = var.epicbook_repo_url
  epicbook_branch    = var.epicbook_branch
  tags               = local.workspace_config.tags
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.workspace_config.name_prefix}-rg-${random_id.suffix.hex}"
  location = local.workspace_config.location
  tags     = local.workspace_config.tags
}
