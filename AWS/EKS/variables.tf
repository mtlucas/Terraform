# Variables - Some are Constants and should not be changed due to static index requirements

variable "name" {
  description = "Name of EKS Cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS Cluster"
  type        = string
}

variable "environment" {
  description = "Name of Development Lifecycle environment"
  type        = string
}

variable "node_group_create" {
  description = "(Optional) Create Node Group"
  type        = bool
  default     = false
}

variable "openid_thumbprint_hash" {
  description = "OpenID Thumbprint hash (Default is for US-EAST-2 region)"
  type        = list(string)
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

variable "aws_eks_default_storage_class_enabled" {
  description = "Enable or disable EKS default storeage class (gp2)"
  type        = string
  default     = "true"
}

variable "alb_namespace" {
  description = "(Constant - do not change) Namespace for ALB"
  type        = string
  default     = "kube-system"
}

variable "alb_create_namespace" {
  description = "(Optional) Create namespace for ALB, default true"
  type        = bool
  default     = false
}

variable "alb_chart_version" {
  description = "HELM Chart Version for ALB"
  type        = string
}

variable "alb_service_account_name" {
  description = "(Constant - do not change) ALB Service Account name for Kubernetes"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "cert_manager_namespace" {
  description = "(Constant - do not change) Namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_create_namespace" {
  description = "(Optional) Create cert-manager namespace, default true"
  type        = bool
  default     = true
}

variable "cert_manager_chart_version" {
  description = "HELM Chart Version for cert-manager"
  type        = string
}

variable "cert_manager_cluster_issuer_server" {
  description = "The ACME server URL"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cert_manager_cluster_issuer_email" {
  description = "Email address used for ACME registration"
  type        = string
  default     = "admin@lucasnet.org"
}

variable "cert_manager_cluster_issuer_private_key_secret_name" {
  description = "Name of a secret used to store the ACME account private key"
  type        = string
  default     = "cert-manager-private-key"
}

variable "cert_manager_cluster_issuer_name" {
  description = "Cluster Issuer Name, used for annotations"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_cluster_issuer_create" {
  description = "(Optional) Create Cluster Issuer, default true"
  type        = bool
  default     = true
}

variable "cert_manager_cluster_issuer_yaml" {
  description = "(Optional) Create Cluster Issuer with your yaml"
  type        = string
  default     = null
}

# The default value conflicts with EKS, so use this
variable "cert_manager_additional_set" {
  description = "Additional sets to Helm"
  default     = [{
    name  = "webhook.securePort"
    value = 1260
  }]
}

variable "cert_manager_solvers" {
  description = "List of Cert manager solvers. For a complex example please look at the Readme"
  type        = any
  default = [{
    http01 = {
      ingress = {
        class = "nginx"
      }
    }
  }]
}

variable "certificates" {
  description = "List of Certificates"
  type        = any
  default     = {}
}

variable "ingress_cert_name" {
  description = "Name of ACM certificate imported into AWS"
  type        = string
}

variable "coredns_namespace" {
  description = "(Constant - do not change) Namespace for coredns"
  type        = string
  default     = "kube-system"
}

variable "coredns_fix_via_job" {
  description = "(Optional) Apply coredns fix via job, default false"
  type        = bool
  default     = false
}

variable "rancher_create" {
  description = "(Optional) Install Rancher helm chart, default false"
  type        = bool
  default     = false
}

variable "rancher_primary_namespace" {
  description = "(Constant - do not change) Primary Namespace for Rancher"
  type        = string
  default     = "cattle-system"
}

variable "rancher_bootstrap_password" {
  description = "Bootstrap Admin password for Rancher - prompted to reset after initial login"
  type        = string
}

variable "rancher_version" {
  description = "Version of Rancher to install"
  type        = string
}

variable "rancher_replicas" {
  description = "Number of Rancher pod replicas"
  type        = number
  default     = 1
}

variable "rancher_api_url" {
  description = "Api URL for Rancher - add DNS entry manually"
  type        = string
}

variable "whoami_create" {
  description = "(Optional) Install whoami deployment, default true"
  type        = bool
  default     = true
}
