variable "location" {
  description = "The name of the Azure Region in which all resources should be created."
}

variable "rg-name" {
    description = "The name of the resource group"
}

variable "storage-account-name" {
  description = "The name of the storage account"
}

variable "index_document" {
  description = "The index document of the website"
}

variable "source_content" {
  description = "This is the source content for the static website"
}
