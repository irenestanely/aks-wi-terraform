# Commenting out to skip provider registration errors for container service(Its a one time activity)

resource "azurerm_kubernetes_cluster" "aks" {
  location            = var.location
  name                = var.cluster_name
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix
  oidc_issuer_enabled        = true
  workload_identity_enabled  = true

  tags                = {
    Environment = var.env
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.agent_count
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id_app1, var.user_assigned_identity_id_app2]
  }
}


