# main.tf
# Azure Storage Lifecycle Management Policy Terraform Module

# Get current subscription information for default subscription ID
data "azurerm_subscription" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  policy_name         = "storage-lifecycle-management-policy"
  policy_display_name = "Enforce Storage Lifecycle Management"
  policy_description  = "This policy ensures that Azure Storage accounts have lifecycle management policies configured according to organizational standards."

  # Format subscription ID with proper prefix if needed
  formatted_subscription_id = var.subscription_id != null ? (
    startswith(var.subscription_id, "/subscriptions/") ?
    var.subscription_id :
    "/subscriptions/${var.subscription_id}"
  ) : "/subscriptions/${data.azurerm_subscription.current.subscription_id}"

  # Handle scope type (management group or subscription) with null checks
  management_group_scope = var.scope_type == "management_group" && var.management_group_id != null ? "/providers/Microsoft.Management/managementGroups/${var.management_group_id}" : null
  subscription_scope     = var.scope_type == "subscription" ? local.formatted_subscription_id : null
  scope                  = coalesce(local.management_group_scope, local.subscription_scope, "/subscriptions/${data.azurerm_subscription.current.subscription_id}")

  # Convert days to string values for the policy
  days_to_cool_str             = tostring(var.days_to_cool_tier)
  days_to_archive_str          = tostring(var.days_to_archive_tier)
  days_to_delete_str           = tostring(var.days_to_delete)
  days_to_delete_snapshots_str = tostring(var.days_to_delete_snapshots)
}

# Define the custom policy definition
resource "azurerm_policy_definition" "storage_lifecycle" {
  name         = local.policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = local.policy_display_name
  description  = local.policy_description

  metadata = jsonencode({
    category = "Storage"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        }
      ]
    }
    then = {
      effect = var.policy_effect
      details = {
        type            = "Microsoft.Storage/storageAccounts/managementPolicies"
        name            = "default"
        deploymentScope = "subscription"
        existenceScope  = "resourceGroup"
        existenceCondition = {
          allOf = [
            {
              field  = "Microsoft.Storage/storageAccounts/managementPolicies/policy.rules[*]"
              exists = "true"
            }
          ]
        }
        roleDefinitionIds = [
          "/providers/microsoft.authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab" # Storage Account Contributor
        ]
        deployment = {
          properties = {
            mode = "incremental"
            template = {
              "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
              contentVersion = "1.0.0.0"
              parameters = {
                storageAccountName = {
                  type = "string"
                }
                resourceGroupName = {
                  type = "string"
                }
              }
              variables = {}
              resources = [
                {
                  type       = "Microsoft.Storage/storageAccounts/managementPolicies"
                  apiVersion = "2021-09-01"
                  name       = "[concat(parameters('storageAccountName'), '/default')]"
                  properties = {
                    policy = {
                      rules = [
                        {
                          name    = "standardLifecycleRule"
                          enabled = true
                          type    = "Lifecycle"
                          definition = {
                            filters = {
                              blobTypes   = ["blockBlob"]
                              prefixMatch = var.prefix_filters
                            }
                            actions = {
                              baseBlob = {
                                tierToCool = {
                                  daysAfterModificationGreaterThan = "[parameters('daysToCool')]"
                                }
                                tierToArchive = {
                                  daysAfterModificationGreaterThan = "[parameters('daysToArchive')]"
                                }
                                delete = {
                                  daysAfterModificationGreaterThan = "[parameters('daysToDelete')]"
                                }
                              }
                              snapshot = {
                                delete = {
                                  daysAfterCreationGreaterThan = "[parameters('daysToDeleteSnapshots')]"
                                }
                              }
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              ]
            }
            parameters = {
              storageAccountName = {
                value = "[field('name')]"
              }
              resourceGroupName = {
                value = "[resourceGroup().name]"
              }
              daysToCool = {
                value = var.days_to_cool_tier
              }
              daysToArchive = {
                value = var.days_to_archive_tier
              }
              daysToDelete = {
                value = var.days_to_delete
              }
              daysToDeleteSnapshots = {
                value = var.days_to_delete_snapshots
              }
            }
          }
        }
      }
    }
  })
}

# Assign the policy to the specified scope
resource "azurerm_management_group_policy_assignment" "mg_storage_lifecycle" {
  count                = var.scope_type == "management_group" ? 1 : 0
  name                 = "${local.policy_name}-assignment"
  policy_definition_id = azurerm_policy_definition.storage_lifecycle.id
  management_group_id  = var.management_group_id
  display_name         = "${local.policy_display_name} Assignment"
  description          = "Assigns the storage lifecycle management policy to the specified management group"

  parameters = jsonencode({})

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_subscription_policy_assignment" "sub_storage_lifecycle" {
  count                = var.scope_type == "subscription" ? 1 : 0
  name                 = "${local.policy_name}-assignment"
  policy_definition_id = azurerm_policy_definition.storage_lifecycle.id
  subscription_id      = local.formatted_subscription_id
  display_name         = "${local.policy_display_name} Assignment"
  description          = "Assigns the storage lifecycle management policy to the specified subscription"

  parameters = jsonencode({})

  identity {
    type = "SystemAssigned"
  }
}

# Assign the necessary permissions to the policy assignment's managed identity
resource "azurerm_role_assignment" "mg_storage_lifecycle" {
  count                = var.scope_type == "management_group" ? 1 : 0
  scope                = local.scope
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_management_group_policy_assignment.mg_storage_lifecycle[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "sub_storage_lifecycle" {
  count                = var.scope_type == "subscription" ? 1 : 0
  scope                = local.scope
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_subscription_policy_assignment.sub_storage_lifecycle[0].identity[0].principal_id
}
