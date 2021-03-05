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

# Create Hello Application Insights
resource "azurerm_application_insights" "hello" {
  name                = "appinsights-${var.prefix}-athena-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  application_type = "java"
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

  app_settings = {

    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"

    "SPRING_PROFILES_ACTIVE" = "prod"

    # App Insights 
    # https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps?tabs=net#automate-monitoring
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = azurerm_application_insights.hello.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = azurerm_application_insights.hello.connection_string
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~3"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
  }
}
