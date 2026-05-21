locals {
  service_cidr   = "10.2.1.0/24"
  dns_service_ip = "10.2.1.10"
}

// Data source to reference existing Virtual Network created by Bicep
data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

// Data source to reference existing subnet for AKS nodes
data "azurerm_subnet" "existing" {
  name                 = local.private_subnet_name_list[0]
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

// Separate subnet for private endpoints. Azure disallows private endpoints in
// subnets with any delegation, and AKS subnets accumulate delegations
// (either from AKS itself or customer Azure Policy), so PEs need their own.
data "azurerm_subnet" "private_endpoints" {
  name                 = local.private_subnet_name_list[1]
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

// Some customer environments auto-delegate these subnets to
// Microsoft.ContainerInstance (via Azure Policy or a prior ACI deployment),
// which blocks AKS / PE creation. Clear delegations before resources provision.
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

resource "azapi_update_resource" "clear_pe_subnet_delegations" {
  type                    = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  resource_id             = data.azurerm_subnet.private_endpoints.id
  ignore_missing_property = true

  body = {
    properties = {
      delegations = []
    }
  }
}

