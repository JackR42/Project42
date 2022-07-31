provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

#data "azurerm_key_vault" "project42" {
#  name                = "S2-DevOps42-KeyVault42"
#  resource_group_name = "S2-RG-DevOps42"
#}
#data "azurerm_key_vault_secret" "secret1" {
#  name         = "SqlAdminUserName"
#  key_vault_id = data.azurerm_key_vault.project42.id
#}
#data "azurerm_key_vault_secret" "secret2" {
#  name         = "SqlAdminPassword"
#  key_vault_id = data.azurerm_key_vault.project42.id
#}


resource "azurerm_resource_group" "project42" {
  name = "S2-RG-Project42"
  location = "westeurope"
}

resource "azurerm_mssql_server" "project42" {
  name                         = "sqlserver42x679e6e9"
  resource_group_name          = azurerm_resource_group.project42.name
  location                     = azurerm_resource_group.project42.location
  version                      = "12.0"
#  administrator_login          = data.azurerm_key_vault_secret.secret1.value
#  administrator_login_password = data.azurerm_key_vault_secret.secret2.value
  administrator_login          = "admindba"
  administrator_login_password = "ABCabc123."
}

resource "azurerm_mssql_database" "project42" {
  name                = "dba42"
  server_id           = azurerm_mssql_server.project42.id
  license_type        = "LicenseIncluded"
}

# Create FW rule to allow access from own IP address to the SQL Instance
resource "azurerm_mssql_firewall_rule" "project42" {
  name                = "FirewallRule1"
  server_id           = azurerm_mssql_server.project42.id
  start_ip_address    = "91.205.194.1"
  end_ip_address      = "91.205.194.1"
}
