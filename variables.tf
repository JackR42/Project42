variable "rg-name" {
    description = "The name of the resource group"
}

variable "rg-location" {
  description = "The name of the Azure Region in which all resources should be created."
}

variable "storage-account-name" {
  description = "The name of the storage account"
}

variable "web-index" {
  description = "The index document of the website"
}

variable "web-content" {
  description = "This is the source content for the static website"
}

variable "database-instance-name" {
  description = "This is the name for the SQL Server Instance"
}

variable "database-name" {
  description = "This is the name for the database"
}
