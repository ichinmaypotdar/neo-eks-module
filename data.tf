locals {
  env_prefix = {
    "dev"        = "neo-dev"
    "prod"       = "neo-prod"
    "sandbox"    = "neo-sandbox"
    "qa"         = "neo-qa"
    "poc"        = "neo-poc"
  }

  name_prefix = lookup(local.env_prefix, var.Environment)
}

locals {

  standard_tags = {
    Name        = "${local.name_prefix}-${var.project}-eks-cluster"
    Service     = var.project
    Email       = var.Email
    Env         = var.Environment
    Management  = "Terraform"
    Type        = var.type
    Team        = var.team
    Service_Version = var.Service_Version
  }

  resource_tags = merge(local.standard_tags, var.special_tags)
}

