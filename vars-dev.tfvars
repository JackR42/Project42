# vars-dev.tfvars

# Generic variables
env = "dev"
location-name = "westeurope"
resource-group-name = "$(ARM-RG-Project)-$(env)"

# Database variables
database-instance-name = "$(sqlserver-instancename)-$(env)"
database-instance-name-fqdn = "$(database-instance-name).database.windows.net"
database-database1-name = "dba"

## Static website variables
##web-storage-account-name = "website42x679e6e9dev"
##web-index-document = "index.html"
##web-source-content = "<h1><center>Hello Website42 - DEV!</center></h1>"
### https://website42x679e6e9dev.z6.web.core.windows.net


# https://thomasthornton.cloud/2020/09/22/deploying-terraform-from-develop-to-production-consecutively-using-azure-devops/
# https://www.erwinstaal.nl/posts/azure-terraform-example-pipeline/
# https://jamesrcounts.com/2021/07/07/terraform-pipelines-with-azure-devops.html
# https://github.com/Azure/eu-digital-covid-certificates-reference-architecture
