locals {
  env-prefix = {
      dev = "dev"
      prod = "prod"
  }

  project-prefix = "tfg"
}

output "env-prefix" {
  value = local.env-prefix[var.environment]
}

output "project-prefix" {
  value = local.project-prefix
}
