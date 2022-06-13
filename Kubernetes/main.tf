terraform {
 required_providers {
   kubernetes = {
     source = "hashicorp/kubernetes"
     version = "2.11.0"
   }
 }
}

provider "kubernetes" {
  config_path    = "C:\\Users\\mike\\.kube\\config"
  config_context = "rancher-desktop"
  insecure       = true
}

resource "kubernetes_namespace" "default" {


}