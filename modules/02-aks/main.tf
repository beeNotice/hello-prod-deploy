##############################################
#         Container registry                 #
##############################################
/*
resource "azurerm_container_registry" "bee" {
  name                = "beenotice"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
}
*/

##############################################
#        Azure Kubernetes Service            #
##############################################
resource "azurerm_kubernetes_cluster" "hello" {
  name = "aks-${var.prefix}-${var.env}"

  resource_group_name = var.resource_group_name
  location            = var.location

  dns_prefix = "hello-aks"

  default_node_pool {
    name           = "hellopool"
    node_count     = 1
    vm_size        = "Standard_A2_v2"
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }
}

##############################################
#                 Roles                      #
##############################################
# Autorization to pull images from repository
/*
resource "azurerm_role_assignment" "hello_to_acr" {
  scope                = azurerm_container_registry.bee.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.hello.kubelet_identity[0].object_id
}
*/
