terraform {
 required_providers {
   kubernetes = {
     source = "hashicorp/kubernetes"
     version = "2.12.0"
   }
 }
}

provider "kubernetes" {
  config_path    = "C:\\Users\\mike\\.kube\\config"
  config_context = "rancher-desktop"
  insecure       = true
}

