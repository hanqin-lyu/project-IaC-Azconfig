terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-holder"
    storage_account_name = "sttfstateexpense001"
    container_name       = "tfstate"
    key                  = "02-workload-resources.tfstate"
    use_azuread_auth      = true
  }
}

provider "azurerm" {
  features {}
}