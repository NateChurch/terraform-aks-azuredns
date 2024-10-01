resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata.0.name

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  values = [
      file("${path.module}/cert-manager-values.yaml")
  ]

}
