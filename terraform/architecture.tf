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

# data "azurerm_data_factory" "adf" {
#   name                = azurerm_data_factory.adf.name
#   resource_group_name = azurerm_data_factory.adf.resource_group_name
# }

# == Databricks



# == Storage Account



# == Key Vault