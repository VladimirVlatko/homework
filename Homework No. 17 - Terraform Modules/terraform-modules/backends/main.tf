terraform {
backend "azurerm" {}
}

provider "azurerm" {
 features {}
}

data "azurerm_subscription" "current" {} 