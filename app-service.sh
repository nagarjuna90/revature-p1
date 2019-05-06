#!/bin/bash

gitrepo=https://github.com/nagarjuna90/revature-p1
resourcegroup=$1
planname=$2
webappname=$3
blobStorageAccount=$4
accountName=$5
databaseName=$6
containerName=$7

az group create \
  --name $resourcegroup \
  --location southcentralus

# Create an App Service plan in B tier.
az appservice plan create \
--name $planname \
--resource-group $resourcegroup \
--sku B1 \
--number-of-workers 3 

# Create a web app.
az webapp create \
  --name $webappname \
  --resource-group $resourcegroup \
  --plan $planname \
  --runtime "node|10.14"

# Webapp configaration

blobStorageAccountKey=$(az storage account keys list -g $resourcegroup \
 -n $blobStorageAccount --query [0].value --output tsv)

primaryKey=$(az cosmosdb list-keys --name $accountName \
 -g $resourcegroup --query primaryMasterKey -o tsv)

az webapp config appsettings set \
  --name $webappname \
  --resource-group $resource_group \
  --settings AZURE_STORAGE_ACCOUNT_NAME=$blob_storage_account \
  AZURE_STORAGE_ACCOUNT_ACCESS_KEY=$blob_storage_account_key \
  AZURE_COSMOS_ACCOUNT_ACCESS_KEY=$primaryKey \
  AZURE_COSMOS_ACCOUNT_NAME=https://${accountName}.documents.azure.com:443/ \
  DB_NAME=$databaseName 


# Configure continuous deployment from GitHub. 
# --git-token parameter is required only once per Azure account (Azure remembers token).
az webapp deployment source config \
  --name $webappname \
  --resource-group $resourcegroup \
  --repo-url $gitrepo \
  --branch master 

#blob

az storage account create \
  --name $blobStorageAccount \
  --location southcentralus \
  --resource-group $resourcegroup \
  --sku Standard_LRS \
  --kind blobstorage \
  --access-tier hot \

az storage container create -n images \
  --account-name $blobStorageAccount \
  --account-key $blobStorageAccountKey \
  --public-access container 

#DB

# Create a SQL API Cosmos DB account with session consistency and multi-master enabled
az cosmosdb create \
    --resource-group $resourceGroupName \
    --name $accountName \
    --kind GlobalDocumentDB \
    --locations "South Central US"=0 "North Central US"=1 \
    --default-consistency-level "Session" \
    --enable-multiple-write-locations true


# Create a database
az cosmosdb database create \
    --resource-group $resourceGroupName \
    --name $accountName \
    --db-name $databaseName


# Create a SQL API container with a partition key and 1000 RU/s
az cosmosdb collection create \
    --resource-group $resourceGroupName \
    --collection-name $containerName \
    --name $accountName \
    --db-name $databaseName \
    --partition-key-path /mypartitionkey \
    --throughput 1000

# Copy the result of the following command into a browser to see the web app.
echo http://$webappname.azurewebsites.net
