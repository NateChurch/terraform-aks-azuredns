variable "workload_identity_namespace" {
  type        = string
  description = "The place to put the workload identity"
  default     = "azure-workload-identity-system"
}

data "azurerm_client_config" "current" {}

