# Allows all get list of namespaces, otherwise tools like 'kubens' won't work

resource "kubernetes_cluster_role" "all_can_list_namespaces" {
  for_each   = true ? toset(["ad_rbac"]) : []

  metadata {
    name = "list-namespaces"
  }

  rule {
    api_groups = ["*"]
    resources = [
      "namespaces"
    ]
    verbs = [
      "list",
    ]
  }

  depends_on = [
    azurerm_user_assigned_identity.aks_identity,
    azurerm_role_assignment.aks-aci-vnet-assignment,
    azurerm_role_assignment.private-dns-contributor,
    azurerm_role_assignment.network-contributor,
    azurerm_role_assignment.acr-image-puller,
    azurerm_role_assignment.vm-contributor,
  ]
}

resource "kubernetes_cluster_role_binding" "all_can_list_namespaces" {
  for_each   = true ? toset(["ad_rbac"]) : []

  metadata {
    name = "authenticated-can-list-namespaces"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.all_can_list_namespaces[each.key].metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:authenticated"
  }

  depends_on = [
    kubernetes_cluster_role.all_can_list_namespaces,
  ]
}
