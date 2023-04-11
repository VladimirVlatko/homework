output "resource_group_name" { 
  value = azurerm_resource_group.example.name 
  description = "The name of the resource group we deployed" 
}

output "storage_account_name" { 
  value = azurerm_storage_account.example.name 
  description = "The name of the storage account we deployed" 
}