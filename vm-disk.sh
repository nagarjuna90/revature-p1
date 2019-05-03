#!/bin/bash
vmname=$1
resourcegroup=$2
username=$3
diskname=$4
scaleset=$5
image=$6
snapname=$7
newdiskname=$8
newdiskname1=$9
#Checking group exists or not through if condition 
if [ "$( az group exists --name $resourcegroup )" = "false" ]; then
  az group create -n $resourcegroup -l southcentralus
fi
#disk Creation
az disk create -g $resourcegroup --name $diskname --size-gb 10 --os-type Linux
#VM Creation
az vm create -g $resourcegroup -n $vmname --image UbuntuLTS  --size standard_B1s --custom-data './provision.txt' --generate-ssh-keys --admin-username $username --attach-data-disks $diskname 

#snapshot
az vm disk detach -n $diskname -g $resourcegroup --vm-name $vmname
az snapshot create -n $snapname -g $resourcegroup --size-gb 10 --source $diskname
az disk create -g $resourcegroup --name $newdiskname --source $snapname --size-gb 10 --os-type Linux
az disk create -g $resourcegroup --name $newdiskname1 --source $snapname --size-gb 10 --os-type Linux
#image
az vm stop -g $resourcegroup -n $vmname 
az vm deallocate -g $resourcegroup -n $vmname
az vm generalize -g $resourcegroup -n $vmname
az image create -g $resourcegroup -n $image --source $vmname
#defining port
az vm open-port -g $resourcegroup -n $vmname --port 8080
#getting IP
id=$(az vm show -g $resourcegroup -n $vmname -d --query publicIps | sed 's/"//g' )
echo $id
#Transferring app files
scp -o "StrictHostKeyChecking=no" -r ./index.html $username@$id:/home/$username
scp -o "StrictHostKeyChecking=no" -r ./index.js $username@$id:/home/$username
scp -o "StrictHostKeyChecking=no" -r ./style.css $username@$id:/home/$username
scp -o "StrictHostKeyChecking=no" -r ./server.js $username@$id:/home/$username
#Making VMSS
az vmss create -g $resourcegroup --name $scaleset  --image $image --upgrade-policy-mode automatic --admin-username $username  --generate-ssh-keys --instance-count 3
