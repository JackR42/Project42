# vars-prd.tfvars

# Generic variables
env = "tst"
location-name = "westeurope"
resource-group-name = "$(ARM-RG-Project)-$(env)"

# Database variables
database-instance-name = "$(sqlserver-instancename)-$(env)"
database-instance-name-fqdn = "$(database-instance-name).database.windows.net"
database-database1-name = "dba"

## Static website variables
##web-storage-account-name = "website42x679e6e9dev"
##web-index-document = "index.html"
##web-source-content = "<h1><center>Hello Website42 - TST!</center></h1>"
### https://website42x679e6e9dev.z6.web.core.windows.net
