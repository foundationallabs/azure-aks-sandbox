locals {
  service_cidr   = "10.2.1.0/24"
  dns_service_ip = "10.2.1.10"
}

// Data source to reference existing Virtual Network created by Bicep
data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

// Data source to reference existing subnet
data "azurerm_subnet" "existing" {
  name                 = local.private_subnet_name_list[0]
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

// Some customer environments auto-delegate this subnet to
// Microsoft.ContainerInstance (via Azure Policy or a prior ACI deployment),
// which blocks AKS from using it. Clear delegations before AKS provisions.
resource "azapi_update_resource" "clear_subnet_delegations" {
  type                    = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  resource_id             = data.azurerm_subnet.existing.id
  ignore_missing_property = true

  body = {
    properties = {
      delegations = []
    }
  }
}

