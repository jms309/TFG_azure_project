locals {
  github_configuration = {
      account_name = "jms309"
      branch_name = "tfg/develop"
      git_url = "https://github.com"
      repository_name = "TFG_azure_project"
      root_folder = "/adf"
  }
}

locals {
  adf_github = {
      dev = local.github_configuration
      test = null
  }
}

output "adf_github" {
  value = local.adf_github[var.environment]
}
