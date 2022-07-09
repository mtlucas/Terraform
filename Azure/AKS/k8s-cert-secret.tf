# Import Certificate/Key from Azure Key Vault and save as Kubernetes secret
# -- It should be noted this is a workaround for the failing SecretProviderClass sync feature

resource "kubernetes_secret_v1" "ingress-tls" {
  metadata {
    name      = var.nginx_ingress_secret_name
    namespace = var.nginx_ingress_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "ca.crt"  = base64decode(data.azurerm_key_vault_secret.ca_cert.value)
    "tls.crt" = data.azurerm_key_vault_certificate_data.wildcard_cert.pem
    "tls.key" = data.azurerm_key_vault_certificate_data.wildcard_cert.key
  }

  depends_on = [
    kubernetes_namespace.ingress-basic,
  ]
}
