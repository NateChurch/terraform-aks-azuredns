resource "azurerm_dns_zone" "site_dns_zone" {
  name                = var.domain_name
  resource_group_name = var.dns_resource_group
}

resource "azurerm_dns_a_record" "root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.site_dns_zone.name
  resource_group_name = azurerm_dns_zone.site_dns_zone.resource_group_name
  ttl                 = 300
  records             = [var.public_ip_address]
}

resource "azurerm_dns_a_record" "wildcard" {
  name                = "*"
  zone_name           = azurerm_dns_zone.site_dns_zone.name
  resource_group_name = azurerm_dns_zone.site_dns_zone.resource_group_name
  ttl                 = 300
  records             = [var.public_ip_address]
}

resource "namecheap_domain_records" "site_domain" {
  domain = var.domain_name
  mode = "OVERWRITE"
  nameservers = azurerm_dns_zone.site_dns_zone.name_servers 
}
