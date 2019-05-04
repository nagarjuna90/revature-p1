
resourcegroup=$1
blobStorageAccount=$2

az group create -n $resourcegroup -l southcentralus

az storage account create --name $blobStorageAccount \
--location southcentralus --resource-group $resourcegroup \
--sku Standard_LRS --kind blobstorage --access-tier hot

blobStorageAccountKey=$(az storage account keys list -g $resourcegroup \
-n $blobStorageAccount --query [0].value --output tsv)

az storage container create -n images --account-name $blobStorageAccount \
--account-key $blobStorageAccountKey --public-access container 



