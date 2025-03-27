# Azure Storage Lifecycle Management Policy Terraform Module

This Terraform module creates and assigns an Azure Policy that enforces lifecycle management on Azure Storage accounts. The policy can be applied at either management group, subscription level or storage account level.

## Features

- Enforce consistent lifecycle management across all storage accounts
- Configure days for transition to cool tier, archive tier, and deletion
- Apply at management group, subscription, or individual storage account level
- Configurable policy effect (Deploy, Audit, or Disable)
- Custom prefix filters for targeted application

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.20.0
- Azure subscription or management group with appropriate permissions

# Usage

## Example usage of the Azure Storage Lifecycle Management Policy Module

## Example 1: Apply at subscription level

module "storage_lifecycle_subscription" {
source = "../" # Path to the module directory

scope_type = "subscription"
subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID

days_to_cool_tier = 30
days_to_archive_tier = 90
days_to_delete = 365
days_to_delete_snapshots = 30

prefix_filters = ["container1/", "backups/"]

policy_effect = "DeployIfNotExists"
}

## Example 2: Apply at management group level

module "storage_lifecycle_management_group" {
source = "../" # Path to the module directory

scope_type = "management_group"
management_group_id = "mg-production" # Use the display name of the management group, not the UUID

days_to_cool_tier = 45
days_to_archive_tier = 120
days_to_delete = 730
days_to_delete_snapshots = 45

prefix_filters = ["logs/", "metrics/"]

policy_effect = "AuditIfNotExists" # Start with audit before enforcing
}

## Example 3: Apply to a specific storage account

module "storage_lifecycle_storage_account" {
source = "../" # Path to the module directory

scope_type = "storage_account"
subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID
storage_account_name = "mystorageaccount" # Replace with your storage account name
resource_group_name = "myresourcegroup" # Replace with your resource group name

days_to_cool_tier = 60
days_to_archive_tier = 180
days_to_delete = 365
days_to_delete_snapshots = 30

prefix_filters = ["critical/", "important/"]

policy_effect = "DeployIfNotExists"
}

# Terraform Documentation

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=3.0.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >= 3.0.0 |

## Providers

| Name                                                         | Version          |
| ------------------------------------------------------------ | ---------------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >=3.0.0 >= 3.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_management_group_policy_assignment.mg_storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource    |
| [azurerm_policy_definition.storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition)                                      | resource    |
| [azurerm_resource_policy_assignment.sa_storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment)                 | resource    |
| [azurerm_role_assignment.mg_storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                       | resource    |
| [azurerm_role_assignment.sa_storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                       | resource    |
| [azurerm_role_assignment.sub_storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                      | resource    |
| [azurerm_subscription_policy_assignment.sub_storage_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment)        | resource    |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription)                                                       | data source |

## Inputs

| Name                                                                                                      | Description                                                                                                                                                                            | Type           | Default               | Required |
| --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------------------- | :------: |
| <a name="input_days_to_archive_tier"></a> [days_to_archive_tier](#input_days_to_archive_tier)             | The number of days after which a blob should be moved to the archive tier                                                                                                              | `number`       | `90`                  |    no    |
| <a name="input_days_to_cool_tier"></a> [days_to_cool_tier](#input_days_to_cool_tier)                      | The number of days after which a blob should be moved to the cool tier                                                                                                                 | `number`       | `30`                  |    no    |
| <a name="input_days_to_delete"></a> [days_to_delete](#input_days_to_delete)                               | The number of days after which a blob should be deleted                                                                                                                                | `number`       | `365`                 |    no    |
| <a name="input_days_to_delete_snapshots"></a> [days_to_delete_snapshots](#input_days_to_delete_snapshots) | The number of days after which blob snapshots should be deleted                                                                                                                        | `number`       | `30`                  |    no    |
| <a name="input_location"></a> [location](#input_location)                                                 | The Azure region to use for deployments                                                                                                                                                | `string`       | `"westeurope"`        |    no    |
| <a name="input_management_group_id"></a> [management_group_id](#input_management_group_id)                | The ID of the management group to assign the policy to. Required if scope_type is 'management_group'                                                                                   | `string`       | `null`                |    no    |
| <a name="input_policy_effect"></a> [policy_effect](#input_policy_effect)                                  | The effect of the policy. Valid values are 'DeployIfNotExists', 'AuditIfNotExists', or 'Disabled'                                                                                      | `string`       | `"DeployIfNotExists"` |    no    |
| <a name="input_prefix_filters"></a> [prefix_filters](#input_prefix_filters)                               | A list of blob prefix filters to apply the lifecycle policy to                                                                                                                         | `list(string)` | `[]`                  |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)                | The name of the resource group containing the storage account. Required if scope_type is 'storage_account'                                                                             | `string`       | `null`                |    no    |
| <a name="input_scope_type"></a> [scope_type](#input_scope_type)                                           | The type of scope to assign the policy to. Valid values are 'management_group', 'subscription', or 'storage_account'                                                                   | `string`       | `"subscription"`      |    no    |
| <a name="input_storage_account_name"></a> [storage_account_name](#input_storage_account_name)             | The name of the storage account to assign the policy to. Required if scope_type is 'storage_account'                                                                                   | `string`       | `null`                |    no    |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id)                            | The ID of the subscription to assign the policy to. Required if scope_type is 'subscription'. If not provided and scope_type is 'subscription', the current subscription will be used. | `string`       | `null`                |    no    |

## Outputs

| Name                                                                                                              | Description                                                |
| ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| <a name="output_applied_scope"></a> [applied_scope](#output_applied_scope)                                        | The scope where the policy was applied                     |
| <a name="output_policy_assignment_id"></a> [policy_assignment_id](#output_policy_assignment_id)                   | The ID of the policy assignment                            |
| <a name="output_policy_assignment_identity"></a> [policy_assignment_identity](#output_policy_assignment_identity) | The managed identity associated with the policy assignment |
| <a name="output_policy_id"></a> [policy_id](#output_policy_id)                                                    | The ID of the created policy definition                    |
