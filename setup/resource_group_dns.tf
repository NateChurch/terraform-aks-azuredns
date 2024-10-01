resource "azurerm_resource_group" "dns_resource_group" {
  name     = local.resource_group_name_dns
  location = var.location
}

resource "azurerm_role_assignment" "dns_resource_group_workload_identity_contributor" {
  scope                = azurerm_resource_group.dns_resource_group.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
}

resource "azurerm_role_assignment" "dns_resource_group_terraform_group_contributor" {
  scope                = azurerm_resource_group.aks_resource_group.id
  role_definition_name = "Contributor"
  principal_id         = local.envs.TERRAFORM_GROUP_ID
}
