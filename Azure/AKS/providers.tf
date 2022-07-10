# Provider configuration
#
# Initialize cmd:  "terraform init -upgrade"

# Login to Azure first:  "az login"
provider "azurerm" {
  features {}
}

# Must have kubectl installed (choco install kubernetes-cli -y)
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  username               = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  password               = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  #load_config_file       = false
}

# Must have kubectl installed (choco install kubernetes-cli -y)
provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  username               = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  password               = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  load_config_file       = false
}

# Must have helm installed (choco install kubernetes-helm -y)
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    username               = azurerm_kubernetes_cluster.k8s.kube_config[0].username
    password               = azurerm_kubernetes_cluster.k8s.kube_config[0].password
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  }
}

# Configure the Windows DNS Provider
provider "dns" {
  update {
    server     = "dc-1.lucasnet.int"
    gssapi {
      realm    = upper(var.dns_zone_name)
      username = var.dns_admin_username
      password = var.dns_admin_password
    }
  }
}
