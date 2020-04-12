locals {
  subscription = {
    dev = "fb2e5c74-146d-4e75-aa8f-ffb48a192d6b"
    # prod = "fb2e5c74-146d-4e75-aa8f-ffb48a192d6b"
  }
}

output "subscription" {
  value = local.subscription[var.environment]
}

