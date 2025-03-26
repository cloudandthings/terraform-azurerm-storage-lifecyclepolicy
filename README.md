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

