##############################################
#               Plan                         #
##############################################
resource "azurerm_app_service_plan" "main" {
  name                = "azapp-${var.prefix}-plan-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Linux type configuration
  kind     = "Linux"
  reserved = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

##############################################
#             Application                    #
##############################################
resource "azurerm_app_service" "app" {
  name                = "azapp-${var.prefix}-app-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location

  app_service_plan_id = azurerm_app_service_plan.main.id
  https_only          = true

  site_config {
    linux_fx_version = "JAVA|11-java11"
    # Avoid startup time since it's available in our tier
    always_on         = true
    http2_enabled     = true
    health_check_path = "/actuator/health"
  }

  logs {
    http_logs {
      file_system {
        retention_in_mb   = 100 # in Megabytes
        retention_in_days = 7   # in days
      }
    }
  }
}

##############################################
#           Deployment slot                  #
##############################################
resource "azurerm_app_service_slot" "staging" {
  name = "staging"

  resource_group_name = var.resource_group_name
  location            = var.location

  app_service_name    = azurerm_app_service.app.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  site_config {
    linux_fx_version = "JAVA|11-java11"
    always_on         = true
    http2_enabled     = true
    health_check_path = "/actuator/health"
  }
}
