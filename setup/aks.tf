# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault


resource "azurerm_kubernetes_cluster" "aks" {
  name                      = local.cluster_name
  location                  = azurerm_resource_group.aks_resource_group.location
  resource_group_name       = azurerm_resource_group.aks_resource_group.name
  dns_prefix                = "${local.cluster_name}-dns"
  automatic_channel_upgrade = "stable"  # as of now this shows an error

  node_resource_group    = local.resource_group_name_nodes
  local_account_disabled = false
  oidc_issuer_enabled    = true

  azure_active_directory_role_based_access_control {
    managed   = true  # as of the writing of this, this shows deprecated
    tenant_id = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = [
      local.envs.K8S_ADMIN_GROUP_ID,
      local.envs.TERRAFORM_GROUP_ID
    ]
    azure_rbac_enabled = true
  }

  default_node_pool {
    name           = "system"
    node_count     = local.configs.aks.default_node_count
    vm_size        = local.configs.aks.default_node_vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  storage_profile {
    file_driver_enabled = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.controlplane_identity.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet_identity.id
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
    service_cidr      = "10.1.0.0/16" # Updated service CIDR
    dns_service_ip    = "10.1.0.10"   # Updated DNS service IP
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  depends_on = [
    azurerm_role_assignment.controlplane_identity_contributor,
    azurerm_role_assignment.aks_resource_group_controlplane_contributor
  ]
}

# Assign the AcrPull role to the AKS cluster's service principal
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = local.envs.EXISTING_ACR_ID
}

# Assign the necessary roles to the control plane identity
resource "azurerm_role_assignment" "controlplane_identity_contributor" {
  scope                = azurerm_user_assigned_identity.kubelet_identity.id
  role_definition_name = "Managed Identity Contributor"
  principal_id         = azurerm_user_assigned_identity.controlplane_identity.principal_id
}

resource "azurerm_role_assignment" "controlplane_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = local.envs.K8S_ADMIN_GROUP_ID
}

# Dump out kubeconfig to a file
resource "local_sensitive_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  filename = local.kubeconfig_path
}
