# Azure Log Analytics - unique per cluster

# The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
resource "azurerm_log_analytics_workspace" "k8s" {
    name                = "${var.log_analytics_workspace_name}-k8s-${var.cluster_name}"
    location            = var.resource_group_location
    resource_group_name = data.azurerm_resource_group.primary.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "k8s" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.k8s.location
    resource_group_name   = data.azurerm_resource_group.primary.name
    workspace_resource_id = azurerm_log_analytics_workspace.k8s.id
    workspace_name        = azurerm_log_analytics_workspace.k8s.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
