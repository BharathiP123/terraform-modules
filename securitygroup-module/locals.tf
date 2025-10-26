locals {
    common_tags = {
    Terraform   = true
    Project = var.project
    Environment = var.environment
  }
  common_name_suffix = "${var.project}-${var.environment}"
}