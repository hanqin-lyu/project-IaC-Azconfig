module "avm-res-network-networksecuritygroup" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  location            = var.location
  name                = "${var.project_name}-${var.environment}-nsg"
  resource_group_name = var.resource_group_name

  security_rules = {
    AllowSSHAll = {
      name                       = "AllowSSHAll"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*" # For Azure policy test only, the ports shouldn't open to everyone.
      destination_address_prefix = "*"
    }
  }
}

module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.19.0"

  name          = "vnet-${var.project_name}-${var.environment}"
  location      = var.location
  parent_id     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  address_space = ["10.0.0.0/16"]
  subnets = {
    subnet-default = {
      name           = "subnet-default"
      address_prefix = "10.0.1.0/24"
      network_security_group = {
        id = module.avm-res-network-networksecuritygroup.resource_id
      }
      service_endpoints_with_location = [
        { service = "Microsoft.Sql" },
        { service = "Microsoft.KeyVault" },
        { service = "Microsoft.CognitiveServices" },
        { service = "Microsoft.Storage" }
      ]
    }
  }
}

module "avm-res-keyvault-vault" {
  source                     = "Azure/avm-res-keyvault-vault/azurerm"
  version                    = "0.10.2"
  location                   = var.location
  name                       = "kv-${var.project_name}-${var.environment}-01"
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}
module "avm-res-sql-server" {
  source  = "Azure/avm-res-sql-server/azurerm"
  version = "0.2.1"

  location                     = var.location
  name                         = "${var.project_name}-${var.environment}-sql"
  resource_group_name          = var.resource_group_name
  server_version               = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_username

  databases = {
    "db-project-IaC" = {
      name     = "db-project-IaC"
      sku_name = "S0"
    }
  }
}

module "avm-res-cognitiveservices-account" {
  source  = "Azure/avm-res-cognitiveservices-account/azurerm"
  version = "0.11.1"

  kind      = "AIServices"
  location  = var.location
  name      = "ai-${var.project_name}-${var.environment}"
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  sku_name  = "S0"
}

module "avm-res-storage-storageaccount" {
  source    = "Azure/avm-res-storage-storageaccount/azurerm"
  version   = "0.7.3"
  location  = var.location
  name      = "st${var.project_name}${var.environment}finlogs"
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  # Immutable Storage for finicial auditing
  immutability_policy = {
    allow_protected_append_writes = true
    period_since_creation_in_days = 1 #For test only
    state                         = "Unlocked"
  }
}