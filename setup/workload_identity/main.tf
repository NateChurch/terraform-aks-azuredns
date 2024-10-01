resource "helm_release" "azure-workload-identity" {
  name       = "azure-workload-identity"
  repository = "https://azure.github.io/azure-workload-identity/charts"
  chart      = "workload-identity-webhook"
  namespace  = var.workload_identity_namespace

  set {
    name  = "azureTenantID"
    value = data.azurerm_client_config.current.tenant_id
  }
}
