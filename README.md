# Azure Storage Account Terraform Module

This Terraform module provisions an Azure Storage Account with blob containers, designed to provide object storage with performance-based replication configurations.

## Features

- **Performance Profiles**: Choose from `sandbox`, `development`, or `production` profiles that automatically map to appropriate replication strategies
- **Container Creation**: Dynamically create multiple private blob containers
- **Security Hardened**: Enforces HTTPS-only traffic, TLS 1.2 minimum, and private access
- **Flexible Access Tiers**: Support for Hot and Cool access tiers
- **Tagged Resources**: Automatic tagging for environment tracking and management

## Performance Profile Mapping

The module automatically maps performance profiles to Azure Storage replication types:

| Performance Profile | Account Tier | Replication Type | Description |
|---------------------|--------------|------------------|-------------|
| `sandbox` | Standard | LRS (Locally Redundant Storage) | Economic option for demos and testing |
| `development` | Standard | GRS (Geo-Redundant Storage) | Data replicated to secondary region |
| `production` | Standard | RA-GRS (Read-Access Geo-Redundant) | GRS with read access to secondary region |

## Usage

```hcl
module "storage" {
  source = "./tf-azure-storage"

  service_name         = "paymentservice"  # Must be 3-24 lowercase alphanumeric
  resource_group_name  = "rg-myapp"
  location             = "eastus"
  performance_profile  = "production"
  container_names      = ["uploads", "processed", "archive"]
  access_tier          = "Hot"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Required | Default | Validation |
|------|-------------|------|----------|---------|------------|
| `service_name` | The name of the service. Used for storage account naming. | `string` | Yes | - | Must be 3-24 lowercase alphanumeric characters (no hyphens or special characters) |
| `resource_group_name` | The name of the existing Resource Group in Azure. | `string` | Yes | - | - |
| `location` | The Azure region to deploy to. | `string` | Yes | - | - |
| `performance_profile` | The performance tier selected by the developer. Account tier and replication type are automatically configured. | `string` | Yes | - | Must be one of: `sandbox`, `development`, `production` |
| `container_names` | List of blob container names to create. | `list(string)` | No | `[]` | - |
| `access_tier` | The access tier for the storage account (Hot or Cool). | `string` | No | `"Hot"` | - |

## Outputs

| Name | Description |
|------|-------------|
| `storage_account_id` | The ID of the Storage Account. |
| `storage_account_name` | The name of the Storage Account. |
| `primary_blob_endpoint` | The primary blob endpoint of the Storage Account. |
| `container_names` | List of created container names. |

## Resources Created

- `azurerm_storage_account`: Storage account with performance-based replication and security settings
- `azurerm_storage_container`: One or more private blob containers based on the `container_names` variable

## Example with Minimal Configuration

```hcl
module "simple_storage" {
  source = "./tf-azure-storage"

  service_name         = "demoapp"
  resource_group_name  = "rg-sandbox"
  location             = "centralus"
  performance_profile  = "sandbox"
  container_names      = ["data"]
}
```

## Example with Multiple Environments

```hcl
# Development storage
module "dev_storage" {
  source = "./tf-azure-storage"

  service_name         = "imageprocessor"
  resource_group_name  = "rg-dev"
  location             = "westus2"
  performance_profile  = "development"
  container_names      = ["raw-images", "thumbnails", "processed"]
  access_tier          = "Hot"
}

# Production storage with Cool tier for archive
module "prod_storage" {
  source = "./tf-azure-storage"

  service_name         = "imageprocessor"
  resource_group_name  = "rg-prod"
  location             = "westus2"
  performance_profile  = "production"
  container_names      = [
    "raw-images",
    "thumbnails",
    "processed",
    "archive",
    "backup"
  ]
  access_tier          = "Hot"
}
```

## Storage Replication Types

### LRS (Locally Redundant Storage)
- Data replicated 3 times within a single datacenter
- 99.999999999% (11 nines) durability
- Lowest cost option
- Best for: Development, testing, non-critical data

### GRS (Geo-Redundant Storage)
- Data replicated to a secondary region (hundreds of miles away)
- 99.99999999999999% (16 nines) durability
- Automatic failover available
- Best for: Production data requiring regional redundancy

### RA-GRS (Read-Access Geo-Redundant Storage)
- Same as GRS but with read access to secondary region
- Enables read operations from secondary endpoint
- Best for: High availability applications needing read access during outages

## Access Tiers

### Hot
- Optimized for frequently accessed data
- Higher storage costs, lower access costs
- Best for: Active data, web content, immediate processing

### Cool
- Optimized for infrequently accessed data (stored for at least 30 days)
- Lower storage costs, higher access costs
- Best for: Short-term backup, archive data, older datasets

## Security Features

This module enforces the following security settings:

- **HTTPS Only**: `https_traffic_only_enabled = true`
- **Minimum TLS Version**: TLS 1.2
- **Private Containers**: All containers have `container_access_type = "private"`
- **No Public Access**: `allow_nested_items_to_be_public = false`

## Storage Account Naming

**Important**: Azure Storage Account names have strict requirements:
- Must be 3-24 characters long
- Can only contain lowercase letters and numbers
- Must be globally unique across all of Azure
- No hyphens or special characters allowed

The module enforces this with validation and names the account using the pattern: `st{service_name}`

## Example Connection Strings

```bash
# Using Azure CLI to get connection string
az storage account show-connection-string \
  --name st{service_name} \
  --resource-group {resource_group_name}

# Blob endpoint format
https://{storage_account_name}.blob.core.windows.net/{container_name}/{blob_name}
```

## Working with Containers

```bash
# List containers
az storage container list \
  --account-name st{service_name} \
  --auth-mode login

# Upload a blob
az storage blob upload \
  --account-name st{service_name} \
  --container-name uploads \
  --name myfile.txt \
  --file ./local/path/myfile.txt \
  --auth-mode login
```

## Notes

- The Storage Account is named using the pattern: `st{service_name}` (with service_name being alphanumeric only)
- All containers are created with private access by default
- All resources are tagged with environment, managed_by, and service metadata
- To access blob storage, you'll need to configure access keys, SAS tokens, or use Azure Managed Identity
- Consider enabling soft delete and versioning for production workloads (not included in this module)

## License

See the main project LICENSE file for details.
