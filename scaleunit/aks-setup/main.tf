

resource "kubernetes_service_account" "app1" {
  metadata {
    name      = "irenes-sa1"
    namespace = "irenes-nsp"
    annotations = {
      "azure.workload.identity/client-id" = var.client_id_app1
    }
    labels = {
      "azure.workload.identity/use" : "true"
    }
  }
}

resource "kubernetes_service_account" "app2" {
  metadata {
    name      = "irenes-sa2"
    namespace = "irenes-nsp"
    annotations = {
      "azure.workload.identity/client-id" = var.client_id_app2
    }
    labels = {
      "azure.workload.identity/use" : "true"
    }
  }
}

resource "azurerm_federated_identity_credential" "app1" {
  name                = "aks-fed-app1"
  resource_group_name = var.resource_group
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.issuer_url
  parent_id           = var.user_assigned_identity_id_app1
  subject             = "system:serviceaccount:${var.aks_namespace}:irenes-sa1"
}

resource "azurerm_federated_identity_credential" "mi" {
  name                = "aks-fed-app2"
  resource_group_name = var.resource_group
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.issuer_url
  parent_id           = var.user_assigned_identity_id_app2
  subject             = "system:serviceaccount:${var.aks_namespace}:irenes-sa2"
}