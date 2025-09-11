provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-homelab" {
  name     = "rg-homelab"
  location = "southeastasia"
}

module "sentinel" {
  source = "./modules/sentinel"
  rg = {
    name     = azurerm_resource_group.rg-homelab.name
    location = azurerm_resource_group.rg-homelab.location
  }
}