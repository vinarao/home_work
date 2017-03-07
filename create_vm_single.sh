#!/bin/bash
source ~/openstack-configs/openrc
#*******************************************************************************
# Short script to create networks and subnets in OpenStack using CLI.
# Uses 192.168.1.0/24 for net1/subnet1
#
# Supports VM creation for various tenants, although a bit rigid at the moment.
# The script assumes tenant names are in the form of 'tenant1', 'tenant24', etc.
#
# Created by: Ken Go
# Last Updated: Apr 03, 2015
#*******************************************************************************

VM_NAME=$1

if [ $# -ne 1 ]
then
    echo "The script only takes in 1 argument."
    echo "Usage: $0 <vm_name>"
    exit 1
elif [ $(echo $VM_NAME | egrep -c '^(vm|ha|t[0-9]{1,2})-c[0-9]{1,2}-net[0-9]{1,2}-[0-9]{2}$') -eq 0 ]
then
    echo "Usage: $0 vm-c1-net1-01"
    echo ""
    echo "c1 means instantiate this VM in Compute1"
    echo "net1 means connect this VM to net1"
    echo "01 is simply an arbitrary 2-digit number"
    exit 2 
fi

FLAVOR="m1.tiny"
IMAGE="cirros"
SEC_GROUP="default"
TENANT_NAME="tenant$(echo $VM_NAME | egrep -o '^t[0-9]{1,2}' | cut -c 2-)"
COMPUTE_NODE="c42-compute-$(echo $VM_NAME | cut -d "-" -f2 | cut -c 2-)"
NETWORK_NAME=$(echo $VM_NAME | cut -d "-" -f3)

if [ $(neutron net-list | egrep -c "[ ]$NETWORK_NAME[ ]") -eq 0 ]
then
    echo "Network name '$NETWORK_NAME' is not found."
    echo "Not creating the VM"
    exit 3
elif [ $(neutron net-list | egrep -c "[ ]$NETWORK_NAME[ ]") -gt 1 ]
then
    echo "There are more than 1 network with Network '$NETWORK_NAME' found."
    echo "Not creating the VM"
    exit 4
fi

NETWORK_ID=$(neutron net-list | egrep "[ ]$NETWORK_NAME[ ]" | cut -d "|" -f2 | tr -d [:space:]) 

boot= nova boot --flavor ${FLAVOR} --image ${IMAGE} --availability-zone nova:${COMPUTE_NODE} $VM_NAME --nic net-id=${NETWORK_ID}
echo $boot
