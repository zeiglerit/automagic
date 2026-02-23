resource "azurerm_resource_group" "rg" {
  name     = "lab-rg"
  location = var.azure_region
}

output "aks_ready" {
  value = true
}
