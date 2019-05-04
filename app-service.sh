#!/bin/bash

gitrepo=https://github.com/nagarjuna90/revature-p1
resourcegroup=$1
planname=$2
webappname=$3

az group create -n $resourcegroup -l southcentralus

# Create an App Service plan in B tier.
az appservice plan create --name $planname --resource-group $resourcegroup  --sku B1 --number-of-workers 3

# Create a web app.
az webapp create --name $webappname --resource-group $resourcegroup  --plan $planname -r "node|10.14"

# Configure continuous deployment from GitHub. 
# --git-token parameter is required only once per Azure account (Azure remembers token).
az webapp deployment source config --name $webappname --resource-group $resourcegroup \
--repo-url $gitrepo --branch master 

# Copy the result of the following command into a browser to see the web app.
echo http://$webappname.azurewebsites.net


