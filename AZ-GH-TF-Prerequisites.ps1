## AZ-GH-TF-Pre-Reqs.ps1
## https://4bes.nl/2019/07/11/step-by-step-manually-create-an-azure-devops-service-connection-to-azure/

#Log into Azure
#az login

# Setup Variables
$ProjectName = "FortyTwo"

$randomInt = Get-Random -Maximum 999999
#$randomInt = 977542
Write-Output "Service Connection Name (SPN): $randomInt"

$subscriptionId=$(az account show --query id -o tsv)
$subscriptionName = "S2-Visual Studio Ultimate with MSDN"
$resourceGroupNameProject = "S2-RG-$ProjectName"
$resourceGroupNameCore = "$ResourceGroupNameProject-CORE"
$storageName = "storagecr$ProjectName$randomInt".ToLower()
$kvName = "keyvault$ProjectName$randomInt"
$spnName="SPN-$ProjectName" #AppName=SpnName
$region = "westeurope"
$websiteStorageName = "web$ProjectName$randomInt".ToLower()
$SQLServerInstanceName = "sql$ProjectName$randomInt".ToLower()
$dwp = Read-Host -Prompt "Dwp?"

# Create a CORE resource group
az group create --name "$resourceGroupNameCore" --location "$region"
#az group delete --name "$resourceGroupNameCore" --no-wait --yes

# Create a Key Vault
az keyvault create `
    --name "$kvName" `
    --resource-group "$resourceGroupNameCore" `
    --location "$region" `
    --enable-rbac-authorization

# Authorize the operation to create a few secrets - Signed in User (Key Vault Secrets Officer)
az ad signed-in-user show --query id -o tsv | foreach-object {
    az role assignment create `
        --role "Key Vault Secrets Officer" `
        --assignee "$_" `
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupNameCore/providers/Microsoft.KeyVault/vaults/$kvName"
    }

# Create an azure storage account - Terraform Backend Storage Account
az storage account create `
    --name "$storageName" `
    --location "$region" `
    --resource-group "$resourceGroupNameCore" `
    --sku "Standard_LRS" `
    --kind "StorageV2" `
    --https-only true `
    --min-tls-version "TLS1_2"

#az storage account list

# Authorize the operation to create the container - Signed in User (Storage Blob Data Contributor Role)
az ad signed-in-user show --query id -o tsv | foreach-object {
    az role assignment create `
        --role "Storage Blob Data Contributor" `
        --assignee "$_" `
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupNameCore/providers/Microsoft.Storage/storageAccounts/$storageName"
    }

#Create Upload container in storage account to store terraform state files
Start-Sleep -s 60
az storage container create `
    --account-name "$storageName" `
    --name "tfstate" `
    --auth-mode login

# Create Terraform Service Principal and assign RBAC Role on Key Vault
$spnJSON = az ad sp create-for-rbac --name $spnName `
    --role "Key Vault Secrets Officer" `
    --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroupNameCore/providers/Microsoft.KeyVault/vaults/$kvName
# az ad sp list

# Save new Terraform Service Principal details to key vault
$spnObj = $spnJSON | ConvertFrom-Json
foreach($object_properties in $spnObj.psobject.properties) {
    If ($object_properties.Name -eq "appId") {
        $null = az keyvault secret set --vault-name $kvName --name "ARM-CLIENT-ID" --value $object_properties.Value
    }
    If ($object_properties.Name -eq "password") {
        $null = az keyvault secret set --vault-name $kvName --name "ARM-CLIENT-SECRET" --value $object_properties.Value
    }
    If ($object_properties.Name -eq "tenant") {
        $null = az keyvault secret set --vault-name $kvName --name "ARM-TENANT-ID" --value $object_properties.Value
    }
}
$null = az keyvault secret set --vault-name $kvName --name "ARM-SUBSCRIPTION-ID" --value $subscriptionId
$null = az keyvault secret set --vault-name $kvName --name "ARM-SPN" --value $spnObj.displayName
$null = az keyvault secret set --vault-name $kvName --name "ARM-RND" --value $randomInt 
$null = az keyvault secret set --vault-name $kvName --name "ARM-RG-Project" --value $resourceGroupNameProject
$null = az keyvault secret set --vault-name $kvName --name "SQLServer-InstanceName" --value $SQLServerInstanceName 
$null = az keyvault secret set --vault-name $kvName --name "SQLServer-InstanceAdminUserName" --value 'admindba'
$null = az keyvault secret set --vault-name $kvName --name "SQLServer-InstanceAdminPassword" --value $dwp
$null = az keyvault secret set --vault-name $kvName --name "SQLServer-Database1Name" --value "dba"
$null = az keyvault secret set --vault-name $kvName --name "WebSite-StorageName" --value $websiteStorageName


# Assign additional RBAC role to Terraform Service Principal Subscription as Contributor and access to backend storage
az ad sp list --display-name $spnName --query [].appId -o tsv | ForEach-Object {
    az role assignment create --assignee "$_" `
        --role "Contributor" `
        --subscription $subscriptionId

    az role assignment create --assignee "$_" `
        --role "Storage Blob Data Contributor" `
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupNameCore/providers/Microsoft.Storage/storageAccounts/$storageName" `
    }

#####

write-Output "SPN properties from Azure to Create Service Connection in Azure DevOps AzDO"
Write-Output "Subscription ID: $subscriptionId"
Write-Output "Subscription Name: $subscriptionName"
foreach($object_properties in $spnObj.psobject.properties) {
    If ($object_properties.Name -eq "appId") {
        Write-Output "Service Principal ID (AppId): $object_properties"
    }
    If ($object_properties.Name -eq "password") {
        Write-Output "Service Principal Key (Password): $object_properties"
    }
    If ($object_properties.Name -eq "tenant") {
        Write-Output "Tenant: $object_properties"
    }
}
Write-Output "Service Connection Name (SPN): $spnName"
Write-Output "CORE Resource Group: $resourceGroupNameCore "
Write-Output "CORE KeyVault: $kvName"
Write-Output "CORE StorageName TFState: $storageName"
Write-Output "SQLServer: $ProjectName$randomInt"
Write-Output "WebSite: $websiteStorageName"



## https://dev.to/pwd9000/multi-environment-azure-deployments-with-terraform-and-github-2450
## https://subhankarsarkar.com/simple-way-to-create-spn-and-service-connection-for-azure-devops-pipelines/
## https://github.com/Ba4bes/New-AzDoServiceConnection/blob/main/NewAzDoServiceConnection/NewAzDoServiceConnection.psm1

## Static Web App: https://www.tatvasoft.com/blog/serverless-web-application-in-azure/
## https://github.com/subhankars/StaticWebApp
## https://docs.microsoft.com/en-us/aspnet/web-pages/overview/data/5-working-with-data

## Create SPN: https://rozemuller.com/prepare-azure-devops-for-wvd-deployment-create-a-service-connection/
