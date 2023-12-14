# Provider

provider "aws" {
  #profile = "${var.organization}-${var.account}"
  #profile = "default"
  region = var.region
  default_tags {
    tags = local.standard_tags
  }
}