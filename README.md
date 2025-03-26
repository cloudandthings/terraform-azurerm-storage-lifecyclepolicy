# Azure Storage Lifecycle Management Policy Terraform Module

This Terraform module creates and assigns an Azure Policy that enforces lifecycle management on Azure Storage accounts. The policy can be applied at either management group or subscription level.

## Features

- Enforce consistent lifecycle management across all storage accounts
- Configure days for transition to cool tier, archive tier, and deletion
- Apply to management group or subscription level
- Configurable policy effect (Deploy, Audit, or Disable)
- Custom prefix filters for targeted application

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.20.0
- Azure subscription or management group with appropriate permissions

## Usage

location = "eastus2" # Specify an Azure region for the policy# example/main.tf

# Example usage of the Azure Storage Lifecycle Management Policy Module

provider "azurerm" {
features {}
skip_provider_registration = true
}

# Example 1: Apply at subscription level

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

# Example 2: Apply at management group level

module "storage_lifecycle_management_group" {
source = "../" # Path to the module directory

scope_type = "management_group"
management_group_id = "mg-production" # Replace with your management group ID

days_to_cool_tier = 45
days_to_archive_tier = 120
days_to_delete = 730
days_to_delete_snapshots = 45

prefix_filters = ["logs/", "metrics/"]

policy_effect = "AuditIfNotExists" # Start with audit before enforcing
}
