# Essential variable values - auto imported

cluster_name                        = "aks-1"
environment                         = "Development"
kubernetes_version                  = "1.22"
location                            = "Central US"
resource_group_name                 = "lucasnet"
resource_group_location             = "centralus"
vnet_name                           = "lucasnet-central-1"
node_count                          = 1
nodepool_vm_size                    = "Standard_B2s"
container_registry_name             = "lucasnet"
keyvault_name                       = "lucasnet-keyvault"
dns_zone_name                       = "lucasnet.int"
dns_admin_username                  = "Mike"
cert_name                           = "wild-lucasnet-int"
ca_cert_name                        = "ca-lucasnet-int"
csi_driver_chart_version            = "1.2.0"
log_analytics_workspace_name        = "lucasnet-analytics-workspace"
private_subnet_name                 = "subnet-central-1-private"
private_subnet_name_for_aci         = "subnet-central-2-private"      # These subnet must not have routing table
network_service_cidr                = "10.43.0.0/24"
network_dns_service_ip              = "10.43.0.10"
nginx_ingress_create                = true
nginx_ingress_version               = "4.1.4"
nginx_ingress_lb_static_ip          = ""                              # Leave empty string for Dynamic IP
kubernetes_dashboard_create         = true
kubernetes_dashboard_chart_version  = "5.7.0"
