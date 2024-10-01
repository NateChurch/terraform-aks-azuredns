resource "kubernetes_deployment" "site_deployment" {
  metadata {
    name      = var.site_name
    namespace = var.site_namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.site_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.site_name
        }
      }
      spec {
        container {
          image = var.container_image
          name  = var.site_name
          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "site_service" {
  metadata {
    name      = "${var.site_name}-root-svc"
    namespace = kubernetes_deployment.site_deployment.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.site_deployment.spec.0.template.0.metadata.0.labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }

}

