# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "azurerm_resource_group" "aks_rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
  location            = var.log_analytics_workspace_location
  # The WorkSpace name has to be unique across the whole of azure;
  # not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
  location              = azurerm_log_analytics_workspace.test.location
  resource_group_name   = azurerm_resource_group.rg.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

data "azuread_client_config" "current" {}

module "resource_app1" {
  source = "./applications/app1"
  resource_group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  app_name = "app1"
}

module "resource_app2" {
  source = "./applications/app2"
  resource_group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  app_name = "app2"
}

// same resource, role however multiple identities will share this.
module "adgroup_app1" {
  source = "./applications/adgroup"
  app_name = "app1"
}

module "adgroup_app2" {
  source = "./applications/adgroup"
  app_name = "app2"
}

module "identity-rbac-app1" {
  source = "./applications/identity"
  resource_group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  app_name = "app1"
}

module "identity-rbac-app2" {
  source = "./applications/identity"
  resource_group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  app_name = "app2"
}

module "adgroup_app1_members" {
  source = "./applications/adgroup/members"
  group_id = module.adgroup_app1.ad_group_id
  object_id = module.identity-rbac-app1.principal_object_id
}

module "adgroup_app2_members" {
  source = "./applications/adgroup/members"
  group_id = module.adgroup_app2.ad_group_id
  object_id = module.identity-rbac-app2.principal_object_id
}

module "role_app1" {
  source = "./applications/roles"
  ad_group_id = module.adgroup_app1.ad_group_id
  scope = module.resource_app1.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
}

module "role_app2" {
  source = "./applications/roles"
  ad_group_id = module.adgroup_app2.ad_group_id
  scope = module.resource_app2.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
}

//data.azuread_group.sg_az_sub-dev_reader_01.id
module "aks-scaleunitshared" {
  source = "./scaleunit"
  location = azurerm_resource_group.aks_rg.location
  resource_group = azurerm_resource_group.aks_rg.name
  cluster_name = "aks1"
  dns_prefix =  "aks1"
  agent_count =  "2"
  user_assigned_identity_id_app1 = module.identity-rbac-app1.identity_id
  user_assigned_identity_id_app2 = module.identity-rbac-app2.identity_id
}

provider "kubernetes" {
  host                   = module.aks-scaleunitshared.host
  username               = module.aks-scaleunitshared.cluster_username
  password               = module.aks-scaleunitshared.cluster_password
  client_certificate     = base64decode(module.aks-scaleunitshared.client_certificate)
  client_key             = base64decode(module.aks-scaleunitshared.client_key)
  cluster_ca_certificate = base64decode(module.aks-scaleunitshared.cluster_ca_certificate)
}

module "aks-setup" {
  source = "./scaleunit/aks-setup"
  resource_group = azurerm_resource_group.aks_rg.name
  user_assigned_identity_id_app1 = module.identity-rbac-app1.identity_id
  user_assigned_identity_id_app2 = module.identity-rbac-app2.identity_id
  client_id_app1 = module.identity-rbac-app1.client_id
  client_id_app2 = module.identity-rbac-app2.client_id
  issuer_url = module.aks-scaleunitshared.oidc_issuer_url
  aks_namespace = "irenes-namespace"
}

