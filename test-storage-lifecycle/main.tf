provider "azurerm" {
  features {}
  subscription_id = "605d8880-9a46-4bdd-b718-f665135cbc37"
}

module "storage_lifecycle" {
  source = "../" # Update this to the path of your module

  scope_type      = "subscription"
  subscription_id = "605d8880-9a46-4bdd-b718-f665135cbc37"
  location        = var.location

  days_to_cool_tier        = 30
  days_to_archive_tier     = 90
  days_to_delete           = 365
  days_to_delete_snapshots = 30

  prefix_filters = []
  policy_effect  = "AuditIfNotExists"
}

output "policy_id" {
  value = module.storage_lifecycle.policy_id
}

output "policy_assignment_id" {
  value = module.storage_lifecycle.policy_assignment_id
}
