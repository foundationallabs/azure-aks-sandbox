locals {
  private_subnet_name_list = split(",", var.private_subnet_names)
  node_pool_subnet_id      = var.node_pool_subnet_name == "" ? data.azurerm_subnet.existing.id : data.azurerm_subnet.node_pool[0].id
}
