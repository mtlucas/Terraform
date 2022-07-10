# Essential variable values - auto imported

name                       = "eks-1"                 # Cluster name
kubernetes_version         = "1.22"                  # K8S version 1.22 or greater is required
environment                = "Development"           # Used in tags
alb_chart_version          = "1.4.2"
cert_manager_chart_version = "1.8.2"
ingress_cert_name          = "lucasnet.int"          # Cert is retrieved from existing AWS ACM
rancher_version            = "2.6.5"
rancher_create             = false                   # Rancher creation is a little expirmental on Fargate - expect issues
rancher_replicas           = 2
rancher_bootstrap_password = "admin"
whoami_create              = true
dns_zone_name              = "lucasnet.int"          # Local DNS zone must be valid and Windows Domain
dns_admin_username         = "Mike"
dns_admin_password         = ""
