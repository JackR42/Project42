provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

### BEGIN KeyVault
data "azurerm_key_vault" "project" {
  name                = "keyvaultProject42690593"
  resource_group_name = "S2-RG-Project42-CORE"
}
data "azurerm_key_vault_secret" "secret0" {
  name         = "ARM-RG-Project"
  key_vault_id = data.azurerm_key_vault.project.id
}
data "azurerm_key_vault_secret" "secret1" {
  name         = "SQLServer-InstanceName"
  key_vault_id = data.azurerm_key_vault.project.id
}
data "azurerm_key_vault_secret" "secret2" {
  name         = "SQLServer-InstanceAdminUserName"
  key_vault_id = data.azurerm_key_vault.project.id
}
data "azurerm_key_vault_secret" "secret3" {
  name         = "SQLServer-InstanceAdminPassword"
  key_vault_id = data.azurerm_key_vault.project.id
}
data "azurerm_key_vault_secret" "secret4" {
  name         = "SQLServer-Database1Name"
  key_vault_id = data.azurerm_key_vault.project.id
}
data "azurerm_key_vault_secret" "secret5" {
  name         = "WebSite-StorageName"
  key_vault_id = data.azurerm_key_vault.project.id
}

### END KeyVault

### BEGIN MAIN
resource "azurerm_resource_group" "project" {
  name = data.azurerm_key_vault_secret.secret0.value
  location = "westeurope"
}
resource "azurerm_mssql_server" "project" {
 name  = data.azurerm_key_vault_secret.secret1.value
 version = "12.0"
 resource_group_name = azurerm_resource_group.project.name
 location = azurerm_resource_group.project.location
 administrator_login = data.azurerm_key_vault_secret.secret2.value
 administrator_login_password = data.azurerm_key_vault_secret.secret3.value
}
# Create FW rule to allow access from AZURE SERVICES, e.g. PowerApp
resource "azurerm_mssql_firewall_rule" "project-fw0" {
  name = "FirewallRule0"
  server_id = azurerm_mssql_server.project.id
  start_ip_address = "0.0.0.0"
  end_ip_address = "0.0.0.0"
}
# Create FW rule to allow access from OFFICE
resource "azurerm_mssql_firewall_rule" "project-fw1" {
  name = "FirewallRule1"
  server_id = azurerm_mssql_server.project.id
  start_ip_address = "91.205.194.1"
  end_ip_address = "91.205.194.1"
}
# Create FW rule to allow access from HOME
resource "azurerm_mssql_firewall_rule" "project-fw2" {
  name = "FirewallRule2"
  server_id = azurerm_mssql_server.project.id
  start_ip_address = "94.209.108.55"
  end_ip_address = "94.209.108.55"
}
resource "azurerm_mssql_database" "project" {
  name = data.azurerm_key_vault_secret.secret4.value
  server_id = azurerm_mssql_server.project.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 2
  sku_name = "GP_S_Gen5_1"
  zone_redundant = false
  auto_pause_delay_in_minutes = 60
  min_capacity = 0.5
  storage_account_type = "Local"
# license_type = "LicenseIncluded"
}
#WebSite
#Create Storage account
resource "azurerm_storage_account" "project" {
  name = data.azurerm_key_vault_secret.secret5.value
  resource_group_name = azurerm_resource_group.project.name
 
  location = azurerm_resource_group.project.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
 
  static_website {
     index_document = "index.html"
  }
}

#Add index.html to blob storage
resource "azurerm_storage_blob" "project" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.project.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "<H1><center>Hello project42 - DEV!</center></H1>"
}
# https://<WebSite-StorageName>.z6.web.core.windows.net
### END MAIN
