locals {
  resource_group_name = {
      dev = "tfg-dev-rg"
      prod = "tfg-prod-rg"
  }
}

output "resource_group_name" {
  value = local.resource_group_name[var.environment]
}