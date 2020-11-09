##
# Required parameters
##

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "name of the resource group to create the resource"
  type        = string
}

variable "names" {
  description = "names to be applied to resources"
  type        = map(string)
}

variable "tags" {
  description = "tags to be applied to resources"
  type        = map(string)
}

variable "server_id" {
  description = "identifier appended to server name for more info see https://github.com/openrba/python-azure-naming#azuredbforpostgresql"
  type        = string
}

variable "sku_name" {
    type        = string
    description = "Specifies the SKU Name for this PostgreSQL Server. The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen4_1, GP_Gen5_8)."
    default     = "GP_Gen5_2"
}

variable "storage_mb" {
    type        = number
    description = "Max storage allowed for a server."
    default     = "10240"
}

variable "postgresql_version" {
    type        = string
    description = "Specifies the version of PostgreSQL to use. Valid values are 9.5, 9.6, 10, 10.0, and 11."
    default     = "10.0"
}

variable "administrator_login" {
    type        = string
    description = "Database administrator login name"
    default     = "az_dbadmin"
}

variable "create_mode" {
    description = "Can be used to restore or replicate existing servers. Possible values are Default, Replica, GeoRestore, and PointInTimeRestore. Defaults to Default"
    type        = string
    default     = "Default"
}

variable "creation_source_server_id" {
  description = "the source server ID to use. use this only when creating a read replica server"
  type        = string
  default     = ""
}

variable "log_retention_days" {
    description = "Specifies the number of days to keep in the Threat Detection audit logs"
    default     = "7"
}

variable "ssl_enforcement_enabled" {
  description = "Specifies if SSL should be enforced on connections. Possible values are true and false."
  type        = bool
  default     = true
}

variable "infrastructure_encryption_enabled" {
    type        = string
    description = "Whether or not infrastructure is encrypted for this server. Defaults to false. Changing this forces a new resource to be created."
    default     = "false"
}

variable "auto_grow_enabled" {
    description = "Enable/Disable auto-growing of the storage."
    type        = bool
    default     = false
}

variable "service_endpoints" {
    description = "Creates a virtual network rule in the subnet_id (values are virtual network subnet ids)."
    type        = map(string)
    default     = {}
}

variable "access_list" {
    description = "Access list for PostgresSQL instance. Map off names to cidr ip start/end addresses"
    type        = map(object({ start_ip_address = string
                               end_ip_address   = string }))
    default     = {}
}

variable "enable_postgresql_ad_admin" {
  description = "Set a user or group as the AD administrator for an postgresql server in Azure"
  type        = bool
  default     = false
}

variable "ad_admin_login_name" {
  description = "The login name of the principal to set as the server administrator."
  type        = string
  default     = ""
}

variable "databases" {
  description = "Map of databases to create (keys are database names). Allowed values are the same as for database_defaults."
  type        = map
  default     = {}
}

variable "database_defaults" {
  description = "database default charset and collation (for TF managed databases)"
  type        = object({
                  charset   = string
                  collation = string
                })
  default     = {
                  charset   = "UTF8"
                  collation = "English_United States.1252"
                }
}

variable "enable_threat_detection_policy" {
    description = "Threat detection policy configuration, known in the API as Server Security Alerts Policy."
    type        = bool
    default     = false 
}

variable "storage_endpoint" {
    description = "This blob storage will hold all Threat Detection audit logs. Required if state is Enabled."
    type        = string
    default     = ""
}

variable "storage_account_access_key" {
    description = "Specifies the identifier key of the Threat Detection audit storage account. Required if state is Enabled."
    type        = string
    default     = ""
}

variable "storage_account_resource_group" {
    description = "Azure resource group where the storage account resides."
    type        = string
    default     = ""
}

variable "postgresql_logs" {
    description = "PostgreSQLLogs retention days"
    type        = number
    default     = 0
}

variable "query_store_runtime_statistics" {
    description = "QueryStoreRuntimeStatistics retention days"
    type        = number
    default     = 0
}

variable "query_store_wait_statistics" {
    description = "QueryStoreWaitStatistics retention days"
    type        = number
    default     = 0
}

variable "ds_allmetrics_rentention_days" {
    description = "All metrics retention days"
    type        = number
    default     = 0
}

##
# Optional Parameters
##

variable "backup_retention_days" {
    type        = number
    description = "Backup retention days for the server, supported values are between 7 and 35 days."
    default     = "7"
}

variable "geo_redundant_backup_enabled" {
    type        = string
    description = "Turn Geo-redundant server backups on/off. This allows you to choose between locally redundant or geo-redundant backup storage in the General Purpose and Memory Optimized tiers. When the backups are stored in geo-redundant backup storage, they are not only stored within the region in which your server is hosted, but are also replicated to a paired data center. This provides better protection and ability to restore your server in a different region in the event of a disaster. This is not supported for the Basic tier."
    default     = "true"
}

variable "threat_detection_policy" {
    type        = string
    description = "Threat detection policy configuration, known in the API as Server Security Alerts Policy. The threat_detection_policy block supports fields documented below."
    default     = "false"
}

##
# Required PostgreSQL Server Parameters
##

variable "track_utility" {
  type        = string
  description = "Selects whether utility commands are tracked by pg_qs."
  default     = "on"
}

variable "retention_period_in_days" {
  type        = string
  description = "Sets the retention period window in days for pg_qs - after this time data will be deleted."
  default     = "7"
}

variable "replace_parameter_placeholders" {
  type        = string
  description = "Selects whether parameter placeholders are replaced in parameterized queries."
  default     = "off"
}

variable "query_capture_mode" {
  type        = string
  description = "Selects whether parameter placeholders are replaced in parameterized queries."
  default     = "TOP"
}

variable "max_query_text_length" {
  type        = string
  description = "Sets the maximum query text length that will be saved; longer queries will be truncated."
  default     = "6000"
}

variable "postgresql_config" {
  type        = map(string)
  description = "A map of postgresql additional configuration parameters to values."
  default     = {}
}

locals {
  postgresql_config = merge({
    "pg_qs.track_utility"                   = var.track_utility
    "pg_qs.retention_period_in_days"        = var.retention_period_in_days
    "pg_qs.replace_parameter_placeholders"  = var.replace_parameter_placeholders
    "pg_qs.query_capture_mode"              = var.query_capture_mode
    "pg_qs.max_query_text_length"           = var.max_query_text_length
  }, var.postgresql_config)

  databases= zipmap(keys(var.databases), [ for database in values(var.databases): merge(var.database_defaults, database) ])
}

