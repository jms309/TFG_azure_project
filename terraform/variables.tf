variable "location"{
    type = string
}

variable "workspace_to_environment_map" {
  type = map
  default = {
    dev  = "dev"
    test = "test"
    prod = "prod"
  }
}