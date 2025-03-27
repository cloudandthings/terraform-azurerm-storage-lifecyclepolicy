provider "azurerm" {
  features {}
  subscription_id = ""
}

module "storage_lifecycle" {
  source = "../" # Update this to the path of your module to test set parameters as per below according to your needs, for example, location, subscription_id, etc.

  scope_type      = ""
  subscription_id = ""
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
