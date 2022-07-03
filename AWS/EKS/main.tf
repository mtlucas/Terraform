##########################################################
# Developed by: Michael Lucas (mike@lucasnet.org)        #
##########################################################

##########################################################
# Main.tf for EKS on Fargate cluster buildout            #
#                                                        #
# This will deploy a EKS cluster with Fargate profiles   #
# and Application Loadbalancer.  Rancher and Whoami apps #
# are also installed by default.  Prerequisites are:     #
#  - Common IAM polcies and roles must exist             #
#  - Apply "IAM-Common" code beforehand                  #
#  - Kubernetes version 1.22 or greater                  #
#  - Default Rancher bootstrap password = "admin"        #
#  - Execute on Windows machine only                     #
##########################################################

##########################################################
# Execution prep:                                        #
#                                                        #
# Make sure you have the following setup in environment  #
# where running "terraform apply" command:               #
#  - aws client is installed (choco install awscli) and  #
#    configured: "aws configure"                         #
#  - helm is installed (choco install kubernetes-helm)   #
#    and up to date repos: "helm repo update"            #
#  - kubectl is installed (choco install kubernetes-cli) #
#  - KUBECONFIG env variable points to working cluster   #
#    before running apply (Windows use KUBE_CONFIG_PATH) #
##########################################################

# To delete cluster, install eksctl and execute this command:
#   eksctl delete cluster --name eks-1  # Change to <CLUSTER_NAME>
#   terraform state rm kubernetes_service.whoami
# OR execute this:
#   terraform destroy

terraform {

    required_version = "> 1.2"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 4.18.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 2.12.0"
        }
        helm = {
            source  = "hashicorp/helm"
            version = ">= 2.6.0"
        }
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = ">= 1.14.0"
        }
        rancher2 = {
            source = "rancher/rancher2"
            version = ">= 1.24.0"
        }
        random = {
            source = "hashicorp/random"
            version = ">= 3.1.3"
        }
        local = {
            version = "~> 1.4"
        }
        external = {
            version = "~> 1.2"
        }
        template = {
            version = "~> 2.1"
        }
    }
    # Optional attributes and the defaults function are
    # both experimental, so we must opt in to the experiment.
    #experiments = [module_variable_optional_attrs]
}

# Sub modules
