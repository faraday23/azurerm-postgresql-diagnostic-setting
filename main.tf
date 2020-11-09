# toggles on/off auditing and advanced threat protection policy for sql server
locals {
    if_threat_detection_policy_enabled = var.enable_threat_detection_policy ? [{}] : []                
}

# creates random password for postgresSQL admin account
resource "random_password" "admin" {
  count       = (var.create_mode == "Default" ? 1 : 0)
  length      = 24
  special     = true
}

# Manages a PostgreSQL Server
resource "azurerm_postgresql_server" "instance" {
  name                = "${var.names.product_name}-${var.names.environment}-postgres${var.server_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  administrator_login          = (var.create_mode == "Replica" ? null : var.administrator_login)
  administrator_login_password = (var.create_mode == "Replica" ? null : random_password.admin[0].result)

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  auto_grow_enabled                 = var.auto_grow_enabled
  public_network_access_enabled     = (((length(var.service_endpoints) > 0) || (length(var.access_list) > 0)) ? true : false)
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  ssl_enforcement_enabled           = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = "TLS1_2"
  
  create_mode                       = var.create_mode
  creation_source_server_id         = (var.create_mode == "Replica" ? var.creation_source_server_id : null)

  dynamic "threat_detection_policy" {
      for_each = local.if_threat_detection_policy_enabled
      content {
          storage_endpoint           = var.storage_endpoint
          storage_account_access_key = var.storage_account_access_key 
          retention_days             = var.log_retention_days
      }
  }

}

# Diagnostic setting
module "ds_postgresql_server" {
  source                          = "git@github.com:openrba/terraform-azurerm-monitor-diagnostic-setting.git"
  storage_account                 = var.storage_endpoint
  sa_resource_group               = var.storage_account_resource_group
  target_resource_id              = azurerm_postgresql_server.instance.id
  target_resource_name            = azurerm_postgresql_server.instance.resource_group_name
  ds_log_api_endpoints            = {"PostgreSQLLogs" = var.postgresql_logs, "QueryStoreRuntimeStatistics" = var.query_store_runtime_statistics, "QueryStoreWaitStatistics" = var.query_store_wait_statistics}
  ds_allmetrics_rentention_days   = var.ds_allmetrics_rentention_days
}

# PostgreSQL Database within a PostgreSQL Server
resource "azurerm_postgresql_database" "db" {
  for_each            = local.databases
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.instance.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Sets a PostgreSQL Configuration value on a PostgreSQL Server.
resource "azurerm_postgresql_configuration" "config" {
  for_each            = local.postgresql_config
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.instance.name
  value               = each.value
}

data "azurerm_client_config" "current" {}

# Adding AD Admin to PostgresSQL Server - Default is "false"
resource "azurerm_postgresql_active_directory_administrator" "aduser1" {
  count               = var.enable_postgresql_ad_admin ? 1 : 0
  server_name         = azurerm_postgresql_server.instance.name
  resource_group_name = var.resource_group_name
  login               = var.ad_admin_login_name 
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

# PostgreSQL Service Endpoints
resource "azurerm_postgresql_virtual_network_rule" "service_endpoint" {
  for_each            = var.service_endpoints
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.instance.name
  subnet_id           = each.value
}

# PostgreSQL Access List
resource "azurerm_postgresql_firewall_rule" "access_list" {
  for_each            = var.access_list
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.instance.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}
