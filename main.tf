provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

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

variable "SqlInstanceName" {
  description = "SqlInstanceName"
  default     = "sqlserver42x679e6e9"
}
variable "SqlDatabaseName" {
  description = "SqlDatabaseName"
  default     = "dba42"
}

resource "azurerm_resource_group" "project42" {
  name = "S2-RG-Project42"
  location = "westeurope"
}

resource "azurerm_mssql_server" "project42" {
# name                         = "sqlserver42x679e6e9"
 name                         = "$(var.SqlInstanceName)"
 version                      = "12.0"
 resource_group_name          = azurerm_resource_group.project42.name
 location                     = azurerm_resource_group.project42.location
 administrator_login          = data.azurerm_key_vault_secret.secret1.value
 administrator_login_password = data.azurerm_key_vault_secret.secret2.value
}

resource "azurerm_mssql_database" "project42" {
#  name                = "dba42"
  name                = "$(var.SqlDatabaseName)"
  server_id           = azurerm_mssql_server.project42.id
#  license_type        = "LicenseIncluded"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb         = 20
  sku_name                    = "GP_S_Gen5_1"
  zone_redundant              = false
  auto_pause_delay_in_minutes = 60
  min_capacity                = 0.5
  storage_account_type        = "Local"
}

# Create FW rule to allow access from OFFICE
resource "azurerm_mssql_firewall_rule" "project42-fw1" {
  name                = "FirewallRule1"
  server_id           = azurerm_mssql_server.project42.id
  start_ip_address    = "91.205.194.1"
  end_ip_address      = "91.205.194.1"
}
# Create FW rule to allow access from HOME
resource "azurerm_mssql_firewall_rule" "project42-fw2" {
  name                = "FirewallRule2"
  server_id           = azurerm_mssql_server.project42.id
  start_ip_address    = "94.209.108.55"
  end_ip_address      = "94.209.108.55"
}
