# This creates major k8s resources that don't normally change with regular deployments.
# This includes the namespace, the DNS01 and HTTP01 issuers, and the ingress.

resource "kubernetes_namespace" "site_namespace" {
  metadata {
    name = var.site_name
  }
}

resource "kubectl_manifest" "site_dns01_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-${var.site_name}-dns01
  namespace: ${kubernetes_namespace.site_namespace.metadata.0.name}
spec:
  acme:
    email: ${var.email}
    server: ${var.letsencrypt_server}
    privateKeySecretRef:
      name: letsencrypt-${var.site_name}-dns01
    solvers:
      - dns01:
          azureDNS:
            hostedZoneName: ${var.domain_name}
            resourceGroupName: ${var.dns_resource_group}
            subscriptionID: ${var.subscription_id}
            managedIdentity:
              clientID: ${var.workload_identity.client_id}
YAML
}

resource "kubectl_manifest" "site_http01_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-${var.site_name}-http01
  namespace: ${kubernetes_namespace.site_namespace.metadata.0.name}
spec:
  acme:
    email: ${var.email}
    server: ${var.letsencrypt_server}
    privateKeySecretRef:
      name: letsencrypt-${var.site_name}-http01
    solvers:
      - http01:
          ingress:
            class: nginx
YAML
}

resource "kubernetes_ingress_v1" "site_ingress" {
  metadata {
    name      = "${var.site_name}-ingress"
    namespace = kubernetes_namespace.site_namespace.metadata.0.name
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = true
      "cert-manager.io/issuer" = (var.letsencrypt_solver_type == "dns01") ? (
        "letsencrypt-${var.site_name}-dns01"
        ) : (
        "letsencrypt-${var.site_name}-http01"
      )
    }
  }
  spec {
    ingress_class_name = "nginx"
        rule {
      host = "*.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "${var.site_name}-root-svc"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }

    rule {
      host = var.domain_name
      http {
        path {
          path = "/"
          backend {
            service {
              name = "${var.site_name}-root-svc"
              port {
                name = "http"
              }
            }
          }
        }
      }

    }

    tls {
      hosts = ["*.${var.domain_name}", var.domain_name ]
      secret_name = (var.letsencrypt_solver_type == "dns01") ? (
        "letsencrypt-${var.site_name}-dns01"
        ) : (
        "letsencrypt-${var.site_name}-http01"
      )
    }

  }
}
