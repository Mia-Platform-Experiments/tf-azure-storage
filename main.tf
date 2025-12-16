# Map performance profiles to Storage Account configurations
locals {
  storage_config = {
    sandbox = {
      account_tier     = "Standard"
      replication_type = "LRS"  # Locally Redundant Storage - economic for demos
    }
    development = {
      account_tier     = "Standard"
      replication_type = "GRS"  # Geo-Redundant Storage
    }
    production = {
      account_tier     = "Standard"
      replication_type = "RAGRS"  # Read-Access Geo-Redundant Storage
    }
  }
}

# Create Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "st${var.service_name}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = local.storage_config[var.performance_profile].account_tier
  account_replication_type = local.storage_config[var.performance_profile].replication_type
  access_tier              = var.access_tier
  
  min_tls_version               = "TLS1_2"
  https_traffic_only_enabled    = true
  allow_nested_items_to_be_public = false

  tags = {
    environment = var.performance_profile
    managed_by  = "terraform"
    service     = var.service_name
  }
}

# Create Blob Containers
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.container_names)

  name                  = each.value
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
