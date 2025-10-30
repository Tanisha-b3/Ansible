# locals.tf - USE THIS VERSION
locals {
  env_config = {
    dev = {
      location      = "centralindia"
      vm_size       = "Standard_D2ads_v6"
      db_sku_name   = "B_Standard_B2ms"
      #allowed_ip    = "192.168.1.7/32"
      allowed_ip    = "49.43.2.209/32"  # ← Replace with YOUR actual dev IP
      name_prefix   = "dev-epicbook"
      tags = {
        Environment = "Development"
        Project     = "EpicBook"
      }
    }
    prod = {
      location      = "centralindia"
      vm_size       = "Standard_D2ads_v6"
      db_sku_name   = "B_Standard_B2ms"
      #allowed_ip    = "192.168.1.7/32"
      allowed_ip    = "49.43.2.209/32"  # ← Replace with YOUR actual prod IP
      name_prefix   = "prod-epicbook"
      tags = {
        Environment = "Production"
        Project     = "EpicBook"
      }
    }
  }

  workspace_config = local.env_config[terraform.workspace]

  # Dynamic naming
  resource_names = {
    vnet          = "${local.workspace_config.name_prefix}-vnet"
    public_subnet = "${local.workspace_config.name_prefix}-public-subnet"
    mysql_subnet  = "${local.workspace_config.name_prefix}-mysql-subnet"
    public_nsg    = "${local.workspace_config.name_prefix}-public-nsg"
    private_nsg   = "${local.workspace_config.name_prefix}-private-nsg"
    #mysql_server  = "${local.workspace_config.name_prefix}-mysql"
    mysql_server  = "${local.workspace_config.name_prefix}-mysql-${random_id.suffix.hex}"  # ← Add random suffix
    vm            = "${local.workspace_config.name_prefix}-vm"
  }
}
