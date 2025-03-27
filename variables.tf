# variables.tf
# Variables for the Azure Storage Lifecycle Management Policy Module

variable "scope_type" {
  description = "The type of scope to assign the policy to. Valid values are 'management_group', 'subscription', or 'storage_account'"
  type        = string
  default     = "subscription"

  validation {
    condition     = contains(["management_group", "subscription", "storage_account"], var.scope_type)
    error_message = "The scope_type must be either 'management_group', 'subscription', or 'storage_account'."
  }
}

variable "management_group_id" {
  description = "The ID of the management group to assign the policy to. Required if scope_type is 'management_group'"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "The ID of the subscription to assign the policy to. Required if scope_type is 'subscription'. If not provided and scope_type is 'subscription', the current subscription will be used."
  type        = string
  default     = null
}

variable "location" {
  description = "The Azure region to use for deployments"
  type        = string
  default     = "westeurope" # Provide a default location
}

variable "days_to_cool_tier" {
  description = "The number of days after which a blob should be moved to the cool tier"
  type        = number
  default     = 30

  validation {
    condition     = var.days_to_cool_tier >= 0
    error_message = "The days_to_cool_tier value must be greater than or equal to 0."
  }
}

variable "days_to_archive_tier" {
  description = "The number of days after which a blob should be moved to the archive tier"
  type        = number
  default     = 90

  validation {
    condition     = var.days_to_archive_tier >= 0
    error_message = "The days_to_archive_tier value must be greater than or equal to 0."
  }
}

variable "days_to_delete" {
  description = "The number of days after which a blob should be deleted"
  type        = number
  default     = 365

  validation {
    condition     = var.days_to_delete >= 0
    error_message = "The days_to_delete value must be greater than or equal to 0."
  }
}

variable "days_to_delete_snapshots" {
  description = "The number of days after which blob snapshots should be deleted"
  type        = number
  default     = 30

  validation {
    condition     = var.days_to_delete_snapshots >= 0
    error_message = "The days_to_delete_snapshots value must be greater than or equal to 0."
  }
}

variable "prefix_filters" {
  description = "A list of blob prefix filters to apply the lifecycle policy to"
  type        = list(string)
  default     = []
}

variable "policy_effect" {
  description = "The effect of the policy. Valid values are 'DeployIfNotExists', 'AuditIfNotExists', or 'Disabled'"
  type        = string
  default     = "DeployIfNotExists"

  validation {
    condition     = contains(["DeployIfNotExists", "AuditIfNotExists", "Disabled"], var.policy_effect)
    error_message = "The policy_effect must be either 'DeployIfNotExists', 'AuditIfNotExists', or 'Disabled'."
  }
}
variable "storage_account_name" {
  description = "The name of the storage account to assign the policy to. Required if scope_type is 'storage_account'"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group containing the storage account. Required if scope_type is 'storage_account'"
  type        = string
  default     = null
}
