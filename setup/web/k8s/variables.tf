variable "site_name" {
  type    = string
  description = "This is what the site is called without dots in the name"
}

variable "domain_name" {
  type    = string
  description = "This is the domain name for the site"
}

variable "site_namespace" {
  type    = string
  description = "This is the namespace for the site"
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
