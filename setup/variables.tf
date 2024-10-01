# names of the cluster resources
resource "random_pet" "cluster_name" {
  length = 1
}
resource "random_integer" "cluster_name" {
  min = 100
  max = 999
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "config_env_path" {
  type    = string
  default = "../config/*.env"
}

variable "config_json_path" {
  type    = string
  default = "../config/*.json"
}

locals {
  cluster_name              = "${random_pet.cluster_name.id}${random_integer.cluster_name.id}"
  resource_group_name_dns   = "${local.cluster_name}-dns-rg"
  resource_group_name_aks   = "${local.cluster_name}-aks-rg"
  resource_group_name_nodes = "${local.cluster_name}-nodes-rg"
  kubeconfig_path           = "../${local.cluster_name}.kubeconfig"
  envs = merge([
    for f in fileset("${path.cwd}", var.config_env_path) : {
      for tuple in regexall(
        # regex before backslash escaping for terraform
        # (?m:^\s*([^#\s]\S*?)[\s*?=\s*?]+?[\"']?(.*[^\"'\s])[\"']?\s*$)
        "(?m:^\\s*([^#\\s]\\S*?)[\\s*?=\\s*?]+?[\"']?(.*[^\"'\\s])[\"']?\\s*$)",
        file(f)
      ) : tuple[0] => sensitive(tuple[1])
  }]...)
  configs = { for file_name in fileset("${path.cwd}", var.config_json_path) :
    trimsuffix(basename(file_name), ".json") =>
    { for record_type, records in jsondecode(file("${path.module}/${file_name}")) :
      record_type => records
    }
  }
}
