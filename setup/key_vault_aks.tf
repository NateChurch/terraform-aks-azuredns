resource "azurerm_key_vault" "aks_key_vault" {
  name                        = "${local.cluster_name}-kv"
  location                    = azurerm_resource_group.aks_resource_group.location
  resource_group_name         = azurerm_resource_group.aks_resource_group.name
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
}

resource "azurerm_role_assignment" "workload_identity_secret_user" {
  scope                = azurerm_key_vault.aks_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
}

resource "azurerm_role_assignment" "terraform_group_secret_officer" {
  scope                = azurerm_key_vault.aks_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = local.envs.ARM_GROUP_ID
}

resource "azurerm_role_assignment" "kubelet_identity_secret_officer" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.aks_key_vault.id
}

