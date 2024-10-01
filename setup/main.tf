module "workload_identity" {
  source                      = "./workload_identity"
  workload_identity_namespace = kubernetes_namespace.workload_identity_k8s_namespace.metadata[0].name
  depends_on                  = [azurerm_kubernetes_cluster.aks]
}

module "nginx_ingress" {
  source     = "./nginx_ingress"
  depends_on = [azurerm_kubernetes_cluster.aks]
}

module "cert_manager" {
  source     = "./cert_manager"
  depends_on = [azurerm_kubernetes_cluster.aks, module.workload_identity]
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "nginx-ingress"
  }
  depends_on = [module.nginx_ingress]
}

module "web" {
  source             = "./web"
  site_name          = "mechatronicsdigital"
  domain_name        = "mechatronics.digital"
  letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"
  email              = "your_address@email.com"
  workload_identity  = azurerm_user_assigned_identity.workload_identity
  dns_resource_group = azurerm_resource_group.dns_resource_group.name
  subscription_id    = data.azurerm_client_config.current.subscription_id
  env_vars           = { "MESSAGE" : "mechatronics.digital" }
  public_ip_address  = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
  depends_on         = [azurerm_kubernetes_cluster.aks, module.nginx_ingress, module.cert_manager]
}
