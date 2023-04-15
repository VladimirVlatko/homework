terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.36.0"
    }
  }
}

provider "azurerm" {
 features {}
}

locals { 
  resource_prefix = "${var.my_name}${random_string.random.result}"
  base_name = "${var.my_name}-${var.environment}"
  network_base_name = "${local.base_name}-ntwrk"  
  }

data "azurerm_subscription" "current" {} 

resource "random_string" "random" {
  length = 8
  special = false
  lower = true
  upper = false
}

# Create an Azure Resource Group
resource "azurerm_resource_group" "example" { 
  name = "${local.resource_prefix}-rg" 
  location = var.location 
}

# Create azurerm storage account
resource "azurerm_storage_account" "example" {
  name = "${local.resource_prefix}sa"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  account_tier = "Standard"
  account_replication_type = "GRS"

 blob_properties {
  restore_policy {
    days = 7
  }

  delete_retention_policy {
    days = 8
  }

  versioning_enabled = true
  change_feed_enabled = true
}

  tags = {
    environment = "staging"
  }
}

# Create container
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = "vladimirs1pmq7jdsa"
  container_access_type = "private"
}

# Create resource group general_network
resource "azurerm_resource_group" "general_network" {
  name     = "${local.network_base_name}-rg"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "general_network" {
  name                = "${local.network_base_name}-vnet"
  location            = azurerm_resource_group.general_network.location
  resource_group_name = azurerm_resource_group.general_network.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "general_network_vms" {
  name                 = "${azurerm_virtual_network.general_network.name}-vms-snet"
  resource_group_name  = azurerm_resource_group.general_network.name
  virtual_network_name = azurerm_virtual_network.general_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Decalre the module
module "vm" {
source = "./vm_module"
base_name = local.base_name
location = var.location
vms_subnet_id = azurerm_subnet.general_network_vms.id
my_public_ip = var.my_public_ip
my_password = var.my_password
}
