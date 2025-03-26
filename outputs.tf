# outputs.tf
# Outputs for the Azure Storage Lifecycle Management Policy Module

output "policy_id" {
  description = "The ID of the created policy definition"
  value       = azurerm_policy_definition.storage_lifecycle.id
}

output "policy_assignment_id" {
  description = "The ID of the policy assignment"
  value       = var.scope_type == "management_group" ? azurerm_management_group_policy_assignment.mg_storage_lifecycle[0].id : azurerm_subscription_policy_assignment.sub_storage_lifecycle[0].id
}

output "policy_assignment_identity" {
  description = "The managed identity associated with the policy assignment"
  value       = var.scope_type == "management_group" ? azurerm_management_group_policy_assignment.mg_storage_lifecycle[0].identity : azurerm_subscription_policy_assignment.sub_storage_lifecycle[0].identity
}

output "applied_scope" {
  description = "The scope where the policy was applied"
  value       = local.scope
}
