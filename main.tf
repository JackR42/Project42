provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

### BEGIN KeyVault
data "azurerm_key_vault" "project42" {
  name                = "S2-KeyVault42"
  resource_group_name = "S2-RG-DevOps42"
}
data "azurerm_key_vault_secret" "secret1" {
  name         = "DatabaseAdminUserName"
  key_vault_id = data.azurerm_key_vault.project42.id
}
data "azurerm_key_vault_secret" "secret2" {
  name         = "DatabaseAdminPassword"
  key_vault_id = data.azurerm_key_vault.project42.id
}
### END KeyVault

### BEGIN VARs
variable "location" {
  description = "Location"
  default     = "westeurope"
}
variable "resource_group_main" {
  description = "ResourceGroupMain"
  default     = "S2-RG-Project42"
}
variable "sql_instance_name" {
  description = "SqlInstanceName"
  default     = "sqlserver42x679e6e9"
}
variable "sql_instance_name_fqdn" {
  description = "SqlInstanceNameFqdn"
  default     = "sqlserver42x679e6e9.database.windows.net"
}
variable "sql_database_name" {
  description = "SqlDatabaseName"
  default     = "dba42"
}

### END VARs

### BEGIN MAIN

resource "azurerm_resource_group" "project42" {
#  name = "${var.resource_group_main}"
#  location = "${var.location}"
  name = "${var.resource-group-name}"
  location = "${var.location-name}"
}

resource "azurerm_mssql_server" "project42" {
 name = "${var.sql_instance_name}"
 version = "12.0"
 resource_group_name = azurerm_resource_group.project42.name
 location = azurerm_resource_group.project42.location
 administrator_login = data.azurerm_key_vault_secret.secret1.value
 administrator_login_password = data.azurerm_key_vault_secret.secret2.value
}

resource "azurerm_mssql_database" "project42" {
  name = "${var.sql_database_name}"
  server_id = azurerm_mssql_server.project42.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 2
  sku_name = "GP_S_Gen5_1"
  zone_redundant = false
  auto_pause_delay_in_minutes = 60
  min_capacity = 0.5
  storage_account_type = "Local"
# license_type = "LicenseIncluded"
}

# Create FW rule to allow access from OFFICE
resource "azurerm_mssql_firewall_rule" "project42-fw1" {
  name = "FirewallRule1"
  server_id = azurerm_mssql_server.project42.id
  start_ip_address = "91.205.194.1"
  end_ip_address = "91.205.194.1"
}
# Create FW rule to allow access from HOME
resource "azurerm_mssql_firewall_rule" "project42-fw2" {
  name = "FirewallRule2"
  server_id = azurerm_mssql_server.project42.id
  start_ip_address = "94.209.108.55"
  end_ip_address = "94.209.108.55"
}

#WebSite
#Create Storage account
resource "azurerm_storage_account" "storage_account42" {
  name = "website42x679e6e9"
  resource_group_name = azurerm_resource_group.project42.name
 
  location = azurerm_resource_group.project42.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
 
  static_website {
    index_document = "index.html"
  }
}

#Add index.html to blob storage
resource "azurerm_storage_blob" "website42" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storage_account42.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "${var.web-source-content}"
}

# https://website42x679e6e9.z6.web.core.windows.net
# https://medium.com/bb-tutorials-and-thoughts/azure-building-different-environments-with-terraform-using-workspaces-66e1fb90f2d3
# https://medium.com/microsoftazure/creating-a-single-secure-azure-devops-yaml-pipeline-to-provision-multiple-environments-using-620900aae18
### END MAIN
