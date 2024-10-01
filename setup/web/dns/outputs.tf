output "soa_record" {
  value = azurerm_dns_zone.site_dns_zone.soa_record
}

output "name_servers" {
  value = azurerm_dns_zone.site_dns_zone.name_servers
}

output "site_namespace" {
  value = kubernetes_namespace.site_namespace.metadata.0.name
}

output "letsencrypt_issuer_name" {
  value = kubernetes_ingress_v1.site_ingress.metadata.0.annotations["cert-manager.io/issuer"]
}

output "letsencrypt_secret_name" {
  value = kubernetes_ingress_v1.site_ingress.spec.0.tls.0.secret_name
}
