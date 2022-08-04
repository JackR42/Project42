# Generic variables
variable "env" {
    description = "The name of the environment"
}
variable "resource-group-name" {
    description = "The name of the resource group"
}
variable "location-name" {
  description = "The name of the Azure Region in which all resources should be created."
}

# Database variables
variable "database-instance-name" {
  description = "This is the name for the SQL Server Instance"
}
variable "database-instance-name-fqdn" {
  description = "This is the FQDNname for the SQL Server Instance"
}
variable "database-name" {
  description = "This is the name for the database"
}

# Static website variables
variable "storage-account-name" {
  description = "The name of the storage account"
}
variable "web-index" {
  description = "The index document of the website"
}
variable "web-content" {
  description = "This is the source content for the static website"
}
