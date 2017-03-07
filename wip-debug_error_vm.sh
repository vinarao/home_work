#!/bin/bash

#*******************************************************************************
# Basic debugging script to run for VTS 1.5.
# Checks the following:
#   - Network Node has received DHCP Discover from VM.
#   - Tag used for the tap interface for DHCP port in the Network Node.
#   - Tag used for the tap interface for the VM port in the Compute Node.
#
# Requires:
#   - User run the script with root privileges
#   - Run the script from the Network Node.
# 
# Limitations:
#   - VM is only connected to a single network
#
# Created by:   Ken Go
# Last Updated: Apr 01, 2015
#*******************************************************************************

# Basic input checking
if [ $# -ne 1 ]
then
    echo "The script only takes in 1 argument."
    echo "Usage: $0 <VM_NAME>"
    exit 2
fi
VM_NAME=$1

# Basic error checking
if [ $(nova list | egrep -c "\b$VM_NAME\b") -eq 0 ]
then
    echo "VM name '$VM_NAME' is not found."
    exit 3
elif [ $(nova list | egrep -c "\b$VM_NAME\b") -gt 1 ]
then
    echo "There are more than 1 VM with '$VM_NAME' found."
    exit 4
fi

# Get latest NCS VLAN to PORT Mapping
./get_ncs_vlan_port_mapping.sh > ncs_vlan_port_mapping.txt

# Populating the values for the variables
VM_IP=$(nova show $VM_NAME | egrep '^.* network' | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
VM_UUID=$(nova show $VM_NAME | egrep '^\| id' | cut -d '|' -f3 | tr -d [:space:])
echo "VM UUID: $VM_UUID"
NETWORK_NAME=$(nova show $VM_NAME | egrep -o '^.* network' | awk '{print $2}')
NETWORK_ID=$(neutron net-list | egrep "\b$NETWORK_NAME\b" | cut -d "|" -f2 | tr -d [:space:])
#VM_PORT_ID=$(neutron port-list | grep "$VM_IP" | cut -d "|" -f2 | tr -d [:space:])
#VM_MAC=$(neutron port-list | grep "$VM_IP" | cut -d "|" -f4 | tr -d [:space:])
COMPUTE_NODE=$(nova show $VM_NAME | egrep 'OS-EXT-SRV-ATTR:host' | cut -d "|" -f3 | tr -d [:space:])


# Next block
cat << EOA

======================================
Did Nova schedule the VM successfully?
======================================

EOA

sudo grep "$VM_UUID" /var/log/nova/nova-scheduler.log

# Next block
cat << EOA

==================================
Did Neutron send a request to NCS?
==================================

EOA
# Execute
echo -e "Checking '/var/log/neutron/server.log' for request made from Neutron to NCS"
NEUTRON_NCS_REQ=$(sudo grep "$VM_UUID" /var/log/neutron/server.log | grep mechanism_ncs)

if [ "$NEUTRON_NCS_REQ" = "" ]
then
    echo ""
    echo "No match for $VM_UUID found in the logs."
    echo "Looks like Neutron did not send the request to NCS"
else
    echo "$NEUTRON_NCS_REQ"
fi

# Next block
cat << EOA

=====================================
Did NCS get the request from Neutron?
=====================================

EOA
VM_PORT_UUID=$(sudo grep "$VM_UUID" /var/log/neutron/server.log | grep mechanism_ncs | awk -F "'id': u'" '{print $2}' | cut -d "'" -f1)

if [ "$VM_PORT_UUID" = "" ]
then
    echo "No request has been made to NCS"
    echo "VM_PORT is not created from Neutron"
else
# Get the VTC_IP from the ML2 Plugin config
VTC_IP=$(sudo grep '^url' /etc/neutron/plugin.ini | awk -F 'https://' '{print $2}' | cut -d ':' -f1)

LINE_NUM=$(cat /home/admin/.ssh/known_hosts | grep -n $REMOTE_IP | cut -d ':' -f1)
[ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" ~/.ssh/known_hosts

USERNAME="cisco"
ssh -t ${VTC_IP} -l $USERNAME -o StrictHostKeyChecking=no "
    cat /var/log/ncs/localhost.access | grep $VM_PORT_UUID
    echo -e '\nChecking if ncs-java-vm.log'
    echo -e '---------------------------\n'
    cat /var/log/ncs/ncs-java-vm.log | grep $VM_PORT_UUID
"
fi

# Next block
cat << EOA

=====================================
Checking Nova Compute Logs for the VM
=====================================

EOA
USERNAME="admin"
ssh -t ${COMPUTE_NODE} -l $USERNAME "
    sudo cat /var/log/nova/nova-compute.log | grep \"$VM_UUID\" | egrep -i '(error|ConnectionFailed)'
"
echo -e "\n-----END OF DEBUG-----"
