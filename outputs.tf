output "aks" {
  value = azurerm_kubernetes_cluster.hello.fqdn
}