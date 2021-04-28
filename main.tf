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
#                  Network                   #
##############################################
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  address_space = ["192.168.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "aks" {
  name                = "snet-${var.prefix}-aks-${var.env}"
  resource_group_name = azurerm_resource_group.main.name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.1.0/24"]
}

##############################################
#           Application Insights             #
##############################################
resource "random_id" "workspace" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "hello" {
  name                = "log-${var.prefix}-${random_id.workspace.hex}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "example" {
  solution_name         = "ContainerInsights"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  workspace_resource_id = azurerm_log_analytics_workspace.hello.id
  workspace_name        = azurerm_log_analytics_workspace.hello.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
resource "azurerm_application_insights" "hello" {
  name                = "appinsights-${var.prefix}-hello-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  application_type = "java"
}

##############################################
#         Container registry                 #
##############################################
resource "azurerm_container_registry" "bee" {
  name                = "beenotice"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
}

##############################################
#        Azure Kubernetes Service            #
##############################################
resource "azurerm_kubernetes_cluster" "hello" {
  name = "aks-${var.prefix}-${var.env}"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  dns_prefix = "hello-aks"

  default_node_pool {
    name           = "hellopool"
    node_count     = 1
    vm_size        = "Standard_A2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.hello.id
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
resource "azurerm_role_assignment" "hello_to_acr" {
  scope                = azurerm_container_registry.bee.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.hello.kubelet_identity[0].object_id
}
