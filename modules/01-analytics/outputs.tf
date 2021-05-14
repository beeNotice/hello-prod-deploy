output "log_analytics_workspace_id" {
  description = "The workspace id"
  value       = azurerm_log_analytics_workspace.hello.id
}

output "application_insights_instrumentation_key" {
  description = "The Application Insights instrumentation key"
  value       = azurerm_application_insights.hello.instrumentation_key
}

output "application_insights_connection_string" {
  description = "The Application Insights connection string"
  value       = azurerm_application_insights.hello.connection_string
}


