terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.44.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create the resource group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-${var.env}"
  location = var.location
}

# Create the App Service plan
resource "azurerm_app_service_plan" "main" {
  name                = "azapp-${var.prefix}-plan-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Linux type configuration
  kind     = "Linux"
  reserved = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}


# Hello application
resource "azurerm_app_service" "app" {
  name                = "azapp-${var.prefix}-app-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  app_service_plan_id = azurerm_app_service_plan.main.id
  https_only          = true

  site_config {
    linux_fx_version = "JAVA|11-java11"
    # Avoid startup time since it's available in our tier
    always_on        = true
    http2_enabled    = true
  }
}
