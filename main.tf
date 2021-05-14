##############################################
#          Terraform configuration           #
##############################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.56.0"
    }
  }
}

provider "azurerm" {
  features {}
}

##############################################
#   Azure Resources groups configuration     #
##############################################
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-${var.env}"
  location = var.location
}

##############################################
#                  Modules                   #
##############################################
module "network" {
  source = "./modules/00-network"

  prefix   = var.prefix
  env      = var.env
  location = var.location

  resource_group_name = azurerm_resource_group.main.name
}

module "analytics" {
  source = "./modules/01-analytics"

  prefix   = var.prefix
  env      = var.env
  location = var.location

  resource_group_name = azurerm_resource_group.main.name
}

/**
module "aks" {
  source = "./modules/02-aks"

  prefix   = var.prefix
  env      = var.env
  location = var.location

  resource_group_name = azurerm_resource_group.main.name

  log_analytics_workspace_id = module.analytics.log_analytics_workspace_id
  aks_subnet_id = module.network.aks_subnet_id
}
**/

module "app_service" {
  source = "./modules/03-app_service"

  prefix   = var.prefix
  env      = var.env
  location = var.location

  resource_group_name = azurerm_resource_group.main.name

  application_insights_instrumentation_key = module.analytics.application_insights_instrumentation_key
  application_insights_connection_string   = module.analytics.application_insights_connection_string
}



