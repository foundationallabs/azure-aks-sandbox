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

// Some customer pipelines (notably ARM templates that deployed an ACI for
// phone-home) leave orphan service association links on the subnet. Those
// SALs hold a Microsoft.ContainerInstance delegation in place, so a delete
// of the delegation is rejected with SubnetMissingRequiredDelegation until
// the SAL itself is removed.
data "azapi_resource_list" "aks_subnet_sals" {
  type      = "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks@2024-05-01"
  parent_id = data.azurerm_subnet.existing.id

  response_export_values = ["value"]
}

data "azapi_resource_list" "pe_subnet_sals" {
  type      = "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks@2024-05-01"
  parent_id = data.azurerm_subnet.private_endpoints.id

  response_export_values = ["value"]
}

locals {
  aks_subnet_orphan_aci_sals = [
    for sal in try(data.azapi_resource_list.aks_subnet_sals.output.value, []) :
    sal.name
    if try(sal.properties.linkedResourceType, "") == "Microsoft.ContainerInstance/containerGroups"
  ]

  pe_subnet_orphan_aci_sals = [
    for sal in try(data.azapi_resource_list.pe_subnet_sals.output.value, []) :
    sal.name
    if try(sal.properties.linkedResourceType, "") == "Microsoft.ContainerInstance/containerGroups"
  ]
}

resource "azapi_resource_action" "delete_aks_subnet_orphan_sals" {
  for_each = toset(local.aks_subnet_orphan_aci_sals)

  type        = "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks@2024-05-01"
  resource_id = "${data.azurerm_subnet.existing.id}/serviceAssociationLinks/${each.value}"
  method      = "DELETE"
}

resource "azapi_resource_action" "delete_pe_subnet_orphan_sals" {
  for_each = toset(local.pe_subnet_orphan_aci_sals)

  type        = "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks@2024-05-01"
  resource_id = "${data.azurerm_subnet.private_endpoints.id}/serviceAssociationLinks/${each.value}"
  method      = "DELETE"
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

  depends_on = [azapi_resource_action.delete_aks_subnet_orphan_sals]
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

  depends_on = [azapi_resource_action.delete_pe_subnet_orphan_sals]
}

