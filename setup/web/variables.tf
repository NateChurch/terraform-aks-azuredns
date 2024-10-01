variable "site_name" {
  type    = string
  description = "This is what the site is called without dots in the name"
}

variable "domain_name" {
  type    = string
  description = "This is the domain name for the site"
}

variable "subscription_id" {
  type    = string
  description = "subscription id of the dns zone rg"
}

variable "workload_identity" {
  type    = any
  description = "This is the workload identity for the cluster"
}

variable "dns_resource_group" {
  type    = string
  description = "This is the resource group where the dns zones are kept."
}

variable "public_ip_address" {
  type = string
  description = "This is the value of the public ip address and should be pulled from k8s"
}

variable "email" {
  type    = string
  description = "let's encrypt email address"
}

variable "letsencrypt_server" {
  type    = string
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
  description = "This is the server, defaults to staging."
}

variable "letsencrypt_solver_type" {
  type    = string
  default = "dns01"
  description = "dns01 or http01 - based on if we are doing whole domain or just a subdomain"
}

variable "container_image" {
  type    = string
  default = "natechurch.azurecr.io/test-site:latest"
  description = "This is the container image to deploy. Defaults to a test site."
}

variable "env_vars" {
  type    = map(string)
  default = {
    "MESSAGE" = "Hello World"
  }
  description = "This is a map of environment variables to pass to the container."
}
