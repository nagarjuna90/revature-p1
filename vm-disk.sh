#!/bin/bash
vmname=$1
resourcegroup=$2
username=$3
diskname=$4
command=$5

if [ "$( az group exists --name $resourcegroup )" = "false" ]; then
  az group create -n $resourcegroup -l southcentralus
fi

az disk create -g $resourcegroup --name $diskname --size-gb 10 --os-type Linux
az vm create -g $resourcegroup -n $vmname --image UbuntuLTS  --size standard_B1s --custom-data './provision.txt' --generate-ssh-keys --admin-username $username --attach-data-disks $diskname 


case $command in
image ) 
image=$6
newVM=$7
newVM1=$8
  az vm disk detach -n $diskname -g $resourcegroup --vm-name $vmname
  az vm stop -g $resourcegroup -n $vmname 
  az vm deallocate -g $resourcegroup -n $vmname
  az vm generalize -g $resourcegroup -n $vmname
  az image create -g $resourcegroup -n $image --source $vmname
  az vm create -n $newVM -g $resourcegroup --image $image 
  az vm create -n $newVM1 -g $resourcegroup --image $image
  ;;
snapshot ) 
snapname=$6
newdiskname=$7
namediskname1=$8
 az vm disk detach -n $diskname -g $resourcegroup --vm-name $vmname
 az snapshot create -n $snapname -g $resourcegroup --size-gb 10 --source $diskname
 az disk create -g $resourcegroup --name $newdiskname --source $snapname --size-gb 10 --os-type Linux
 az disk create -g $resourcegroup --name $newdiskname1 --source $snapname --size-gb 10 --os-type Linux
 ;;
esac

az vm open-port -g $resourcegroup -n $vmname --port 8080

id=$(az vm show -g $resourcegroup -n $vmname -d --query publicIps)
echo $id

