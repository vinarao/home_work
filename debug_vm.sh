#!/bin/bash

#*******************************************************************************
# Basic debugging script to run for VTS 1.5.
# Checks the following:
#   - Network Node has received DHCP Discover from VM.
#   - Tag used for the tap interface for DHCP port in the Network Node.
#   - Tag used for the tap interface for the VM port in the Compute Node.
#   - Checks the VLAN, VNI, and Multicast allocation in NCS.
#   - Checks that the VNI and VLAN are configured in TOR using 'show nve vni'.
#
# Requires:
#   - User run the script with root privileges
#   - Run the script from the Network Node.
#   - Proper DNS entries are setup for TORs and Compute Nodes. (If you don't,
#     add entries to /etc/hosts file for local Name to IP mapping.)
# 
# Limitations:
#   - VM is only connected to a single network
#
# Created by:   Ken Go
# Last Updated: Apr 07, 2015
#*******************************************************************************

# Basic input checking
if [ $# -ne 1 ]
then
    echo "The script only takes in 1 argument."
    echo "Usage: $0 <INPUT_FOR_VM>"
    exit 2
fi
INPUT_FOR_VM=$1

# Basic error checking
if [ $(nova list | egrep -c "\b$INPUT_FOR_VM\b") -eq 0 ]
then
    echo "VM name '$INPUT_FOR_VM' is not found."
    exit 3
elif [ $(nova list | egrep -c "\b$INPUT_FOR_VM\b") -gt 1 ]
then
    echo "There are more than 1 VM with '$INPUT_FOR_VM' found."
    exit 4
fi

# Get latest NCS VLAN, VNI, Multicast Mapping
./get_ncs_vlan_port_mapping.sh > ncs_vlan_port_mapping.txt
./get_ncs_mcast_net_mapping.sh > ncs_mcast_net_mapping.txt
./get_ncs_vni_net_mapping.sh > ncs_vni_net_mapping.txt

# Putting the show command results into variables for later use
NOVA_SHOW=$(nova show $INPUT_FOR_VM)
NET_LIST=$(neutron net-list)
PORT_LIST=$(neutron port-list)

VM_NAME=$(echo "$NOVA_SHOW" | egrep '^\|[ ]name[ ]' | cut -d '|' -f3 | tr -d [:space:]) 
VM_UUID=$(echo "$NOVA_SHOW" | egrep '^\|[ ]id[ ]' | cut -d '|' -f3 | tr -d [:space:]) 
NETWORK_NAME=$(echo "$NOVA_SHOW" | egrep -o '^.* network' | awk '{print $2}')
VM_IP=$(echo "$NOVA_SHOW" | egrep '^.* network' | egrep "$NETWORK_NAME" | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
VM_MAC=$(echo "$PORT_LIST" | grep "$VM_IP" | cut -d "|" -f4 | tr -d [:space:])
NETWORK_ID=$(echo "$NET_LIST" | egrep "[ ]${NETWORK_NAME}[ ]" | cut -d "|" -f2 | tr -d [:space:])
VM_PORT_ID=$(echo "$PORT_LIST" | grep "$VM_IP" | cut -d "|" -f2 | tr -d [:space:])
COMPUTE_NODE=$(echo "$NOVA_SHOW" | egrep 'OS-EXT-SRV-ATTR:host' | cut -d "|" -f3 | tr -d [:space:])

DHCP_IP=$(sudo ip netns exec qdhcp-$NETWORK_ID ip addr | grep tap | grep -v '169.254.169.254' | awk '{print $2}' | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
DHCP_PORT_ID=$(echo "$PORT_LIST" | grep "$DHCP_IP" | cut -d "|" -f2 | tr -d [:space:])

# Just verifying the values for the variables above :)
echo -e "| $VM_NAME | $VM_IP | $COMPUTE_NODE | $NETWORK_NAME | $NETWORK_ID | $VM_PORT_ID | $VM_MAC |"
echo -e "| DHCP | $DHCP_IP | $DHCP_PORT_ID |\n"

# Check if VM got IP thru DHCP"
cat << EOA
===============================================================
Checking if Network Node received DHCP Discover Message from VM
===============================================================
EOA
DHCP_MESSAGE=$(sudo grep "$(echo $VM_MAC)" /var/log/messages)

if [ "$DHCP_MESSAGE" = "" ]
then
    echo "[ERROR] VM didn't get IP from DHCP Server"
else
    echo "$DHCP_MESSAGE" #Enclose variable in quotes to preserve newline.
fi

# Check if DHCP tap interface has correct VLAN
cat <<EOA

===========================================================
Checking if DHCP tap interface is assigned the correct VLAN
===========================================================
EOA
sudo ovs-vsctl show | grep -B1 $(echo $DHCP_PORT_ID | cut -c -11) | grep -B1 -i 'interface "'
NCS_VLAN=$(cat ncs_vlan_port_mapping.txt | grep $DHCP_PORT_ID | cut -d '|' -f3 | tr -d [:space:])
echo -e "\n[RESULT] VLAN ID allocated by NCS is \033[5m$NCS_VLAN\033[0m"

NCS_TOR_NAME=$(cat ncs_vlan_port_mapping.txt | grep $DHCP_PORT_ID | cut -d '|' -f2 | tr -d [:space:])
echo -e "[INFO] This port is connected to $NCS_TOR_NAME"
echo -e "\n[INFO] Checking the TOR for VNI/VLAN mapping for verification..."
echo -e "[INFO] Logging in to $NCS_TOR_NAME\n"
ssh ${NCS_TOR_NAME} -l lab "
    show nve vni | i $NCS_VLAN|VNI|---
"

# Check if tap interface of VM has correct VLAN
# SSH to the compute node the VM is hosted
cat << EOA

=========================================================
Checking if VM tap interface is assigned the correct VLAN
=========================================================
EOA

echo -e "[INFO] Connecting to Compute Node ${COMPUTE_NODE}...\n"
ssh -t ${COMPUTE_NODE} "
   sudo ovs-vsctl show | grep -B1 $(echo $VM_PORT_ID | cut -c -11) | grep -A1 -i 'tag'
" 
NCS_VLAN=$(cat ncs_vlan_port_mapping.txt | grep $VM_PORT_ID | cut -d '|' -f3 | tr -d [:space:])
echo -e "\n[RESULT] VLAN ID allocated by NCS is \033[5m$NCS_VLAN\033[0m"

NCS_TOR_NAME=$(cat ncs_vlan_port_mapping.txt | grep $VM_PORT_ID | cut -d '|' -f2 | tr -d [:space:])
echo -e "[INFO] This VM is in Compute Node $COMPUTE_NODE which is connected to $NCS_TOR_NAME."
echo -e "\n[INFO] Checking the TOR for VNI/VLAN mapping for verification..."
echo -e "[INFO] Logging in to $NCS_TOR_NAME\n"

ssh ${NCS_TOR_NAME} -l lab "
    show nve vni | i ${NCS_VLAN}|VNI|---
"

NCS_VNI=$(cat ncs_vni_net_mapping.txt | grep $NETWORK_ID | cut -d '|' -f2 | tr -d [:space:])
NCS_MCAST=$(cat ncs_mcast_net_mapping.txt | grep $NETWORK_ID | cut -d '|' -f2 | tr -d [:space:])

echo -e "\n[RESULT] VNI and Multicast allocated by NCS for the network the VM is connected to are VNI: \033[5m${NCS_VNI}\033[0m and Multicast: \033[5m${NCS_MCAST}\033[0m"

echo -e "\n========================================================="
GET_VNC=$(nova get-vnc-console $INPUT_FOR_VM novnc)
echo -e "$GET_VNC"

# Cleanup

rm ncs_vlan_port_mapping.txt
rm ncs_mcast_net_mapping.txt
rm ncs_vni_net_mapping.txt
