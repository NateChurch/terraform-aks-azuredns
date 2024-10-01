output "site_deployment_name" {
    value = kubernetes_deployment.site_deployment.metadata.0.name
}

output "site_deployment_service" {
    value = kubernetes_service.site_service.metadata.0.name 
}