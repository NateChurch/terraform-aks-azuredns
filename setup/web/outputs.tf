output "site_soa_record" {
  value = module.dns.soa_record
}

output "site_name_servers" {
  value = module.dns.name_servers
}

output "site_namespace" {
  value = module.dns.site_namespace
}

output "site_letsencrypt_issuer_name" {
  value = module.dns.letsencrypt_issuer_name
  description = "This is the name of the secret that holds the letsencrypt cert. Created by the dns. module"
}

output "site_letsencrypt_secret_name" {
  value = module.dns.letsencrypt_secret_name
  description = "This is the name of the secret that holds the letsencrypt cert. Created by the dns. module"
}

output "site_deployment_name" {
    value = module.web.site_deployment_name
}

output "site_deployment_service" {
    value = module.web.site_deployment_service
}