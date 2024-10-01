resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${local.cluster_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_resource_group.location
  resource_group_name = azurerm_resource_group.aks_resource_group.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${local.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.aks_resource_group.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

