### Identities
# Control Plane Identity
resource "azurerm_user_assigned_identity" "controlplane_identity" {
  location            = azurerm_resource_group.aks_resource_group.location
  name                = "id-csi-${local.cluster_name}-controlplane-01"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  # depends_on          = [azurerm_resource_group.aks_resource_group]
}

# Kubelet Identity
resource "azurerm_user_assigned_identity" "kubelet_identity" {
  location            = azurerm_resource_group.aks_resource_group.location
  name                = "id-csi-${local.cluster_name}-kubelet-01"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  # depends_on          = [azurerm_resource_group.aks_resource_group]
}

# Workload Identity
## Create workload identity user assigned identity
resource "azurerm_user_assigned_identity" "workload_identity" {
  location            = azurerm_resource_group.aks_resource_group.location
  name                = "id-csi-${local.cluster_name}-workload-01"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
}

## Create workload identity AKS service account and namespace
resource "kubernetes_namespace" "workload_identity_k8s_namespace" {
  metadata {
    name = local.configs.workload_identity.key_vault.namespace
  }
}

resource "kubernetes_service_account" "workload_identity_k8s_service_account" {
  metadata {
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.workload_identity.client_id
    }
    name      = local.configs.workload_identity.key_vault.service_account
    namespace = kubernetes_namespace.workload_identity_k8s_namespace.metadata[0].name
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

## Create a federated account with workload identity and the service account for key vault
resource "azurerm_federated_identity_credential" "workload_identity_federated_credential" {
  name                = "kubernetes-federated-credential-keyvault"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${local.configs.workload_identity.key_vault.namespace}:${local.configs.workload_identity.key_vault.service_account}"
}

## Create a federated account with workload identity and the service account for cert-manager
resource "azurerm_federated_identity_credential" "workload_identity_federated_credential_cert_manager" {
  name                = "kubernetes-federated-credential-cert-manager"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${local.configs.workload_identity.cert_manager.namespace}:${local.configs.workload_identity.cert_manager.service_account}"
}



