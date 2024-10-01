module "dns" {
  source                  = "./dns"
  site_name               = var.site_name
  domain_name             = var.domain_name
  subscription_id         = var.subscription_id
  workload_identity       = var.workload_identity
  dns_resource_group      = var.dns_resource_group
  public_ip_address       = var.public_ip_address
  letsencrypt_server      = var.letsencrypt_server
  letsencrypt_solver_type = var.letsencrypt_solver_type
  email                   = var.email
}

module "web" {
  source          = "./k8s"
  site_name       = var.site_name
  domain_name     = var.domain_name
  site_namespace  = module.dns.site_namespace
  container_image = var.container_image
  env_vars        = var.env_vars
}

