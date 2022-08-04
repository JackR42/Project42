# Generic variables
variable "env" {
    description = "The name of the environment"
    default = "env-default"
}
variable "resource-group-name" {
    description = "The name of the resource group"
    default = "rg-default"
}
variable "location-name" {
  description = "The name of the Azure Region in which all resources should be created."
  default = "location-default"
}

# Database variables
variable "database-instance-name" {
  description = "This is the name for the SQL Server Instance"
  default = "database-instance-default"
}
variable "database-instance-name-fqn" {
  description = "This is the FQDNname for the SQL Server Instance"
  default = "database-instance-fqdn-default"
}
variable "database-database1-name" {
  description = "This is the name for the database"
  default = "database-database1-default"
}

# Static website variables
variable "web-storage-account-name" {
  description = "The name of the storage account"
  default = "web-storage-account-default"
}
variable "web-index-document" {
  description = "The index document of the website"
  default = "index.html"
}
variable "web-source-content" {
  description = "This is the source content for the static website"
  default = "<h1>Hello Website42!</h1>"
}
