# == Variables

locals {
    # Defining the workspace
    workspace = "${lookup(var.workspace_to_environment_map, terraform.workspace, "dev")}"
}

# == Configure the Azure Provider
provider "azurerm" {
  version = "=2.0.0"
  subscription_id = "${module.environment.subscription}"
  features {}
}

data "azurerm_client_config" "current" {}


# == Environment 

module "environment" {
  source = "./environment"
  environment = "${local.workspace}"
}


# == Resource group
resource "azurerm_resource_group" "rg" {
  name     = "${module.environment.resource_group_name}"
  location = "${var.location}"
}


# == ADF

resource "azurerm_data_factory" "adf" {
  name                = "${module.environment.project-prefix}-${module.environment.env-prefix}-adf"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  dynamic "github_configuration"{
    for_each = module.environment.adf_github == null ? [] : list(module.environment.adf_github)
    content {
      account_name    = lookup(module.environment.adf_github, "account_name", null)
      branch_name     = lookup(module.environment.adf_github, "branch_name", null)
      git_url         = lookup(module.environment.adf_github, "git_url", null)
      repository_name = lookup(module.environment.adf_github, "repository_name", null)
      root_folder     = lookup(module.environment.adf_github, "root_folder", null)
    }
  }

  identity {type = "SystemAssigned"}
}


# == Databricks

resource "azurerm_databricks_workspace" "dbricks"{
  name                = "${module.environment.project-prefix}-${module.environment.env-prefix}-dbricks"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  sku                 = "standard"
}

# == Storage Account

resource "azurerm_storage_account" "dlv2" {
  name                     = replace("${module.environment.project-prefix}-${module.environment.env-prefix}-datalake", "-", "")
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

resource "azurerm_role_assignment" "dlv2_contributor" {
  scope                = "${azurerm_storage_account.dlv2.id}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = "${data.azurerm_client_config.current.object_id}"
}


resource "azurerm_storage_data_lake_gen2_filesystem" "dlv2_fs" {
  name               = "datalake"
  storage_account_id = azurerm_storage_account.dlv2.id
}

# == Key Vault

resource "azurerm_key_vault" "kv" {
  name                        = "${module.environment.project-prefix}-${module.environment.env-prefix}-kv"
  location                    = "${azurerm_resource_group.rg.location}"
  resource_group_name         = "${azurerm_resource_group.rg.name }"
  enabled_for_disk_encryption = true
  tenant_id                   = "${data.azurerm_client_config.current.tenant_id}"

  sku_name = "standard"
}


resource "azurerm_key_vault_access_policy" "kv_user_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id }"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.azurerm_client_config.current.object_id}"

  certificate_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "ManageContacts",
    "ManageIssuers",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers",
    "Purge"
  ]

  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]

  storage_permissions = [
    "get",
  ]
}


resource "azurerm_key_vault_access_policy" "kv_adf_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"

  tenant_id = "${azurerm_data_factory.adf.identity[0].tenant_id}"
  object_id = "${azurerm_data_factory.adf.identity[0].principal_id}"

  depends_on = [azurerm_data_factory.adf]

  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Recover"
  ]
}

# == Key Vault Secrets

resource "azurerm_key_vault_secret" "stg_key" {
  name         = "stg-key"
  value        = "${azurerm_storage_account.dlv2.primary_access_key}"
  key_vault_id = "${azurerm_key_vault.kv.id}"
}

resource "azurerm_key_vault_secret" "stg_name" {
  name         = "stg-name"
  value        = "${azurerm_storage_account.dlv2.name}"
  key_vault_id = "${azurerm_key_vault.kv.id}"
}

resource "azurerm_key_vault_secret" "databricks-token" {
  name         = "databricks-token"
  value        = "generate"
  key_vault_id = "${azurerm_key_vault.kv.id}"
}