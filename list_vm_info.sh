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

# Get latest NCS VLAN, VNI, Multicast Mapping
./get_ncs_vlan_port_mapping.sh > ncs_vlan_port_mapping.txt
./get_ncs_mcast_net_mapping.sh > ncs_mcast_net_mapping.txt
./get_ncs_vni_net_mapping.sh > ncs_vni_net_mapping.txt

# Putting the show command results into variables for later use
NOVA_LIST=$(nova list --all-tenants)
NET_LIST=$(neutron net-list)
PORT_LIST=$(neutron port-list)
VM_UUID_LIST=$(echo "$NOVA_LIST" | egrep 'ACTIVE' | cut -d '|' -f2)

cat << EOA
+----------------------+-----------------+----------------------+-----------------+------+----------+-----------------+---------------------------+
|        VM_NAME       |      VM_IP      |     COMPUTE_NODE     |  NETWORK_NAME   | VLAN |    VNI   | MULTICAST_ADDR  |        TOR(s)_NAME        |
+----------------------+-----------------+----------------------+-----------------+------+----------+-----------------+---------------------------+
EOA

for each in $VM_UUID_LIST
do
    VM_UUID=$each
    VM_NAME=$(echo "$NOVA_LIST" | egrep "$VM_UUID" | cut -d '|' -f3 | tr -d [:space:])
    NETWORK_NAME=$(echo "$NOVA_LIST" | egrep "$VM_UUID" | cut -d '|' -f7 | cut -d '=' -f1 | tr -d [:space:])
    VM_IP=$(echo "$NOVA_LIST" | egrep "$VM_UUID" | cut -d '|' -f7 | cut -d '=' -f2 | tr -d [:space:])
    NETWORK_ID=$(echo "$NET_LIST" | egrep "[ ]${NETWORK_NAME}[ ]" | cut -d "|" -f2 | tr -d [:space:])
    VM_PORT_ID=$(echo "$PORT_LIST" | grep "$VM_IP" | cut -d "|" -f2 | tr -d [:space:])
    #COMPUTE_NODE=$(sudo cat /var/log/nova/nova-scheduler.log | grep $VM_UUID | grep 'Choosing host' | grep -o '\[host: .*,' | cut -d ',' -f1 | awk '{print $2}')
    COMPUTE_NODE="script-not-working" 

    NCS_VLAN=$(cat ncs_vlan_port_mapping.txt | grep $VM_PORT_ID | cut -d '|' -f3 | sort | uniq | tr -d [:space:])
    NCS_TOR=$(cat ncs_vlan_port_mapping.txt | grep $VM_PORT_ID | cut -d '|' -f2 | sort | uniq | tr -d [:space:])
    NCS_VNI=$(cat ncs_vni_net_mapping.txt | grep $NETWORK_ID | cut -d '|' -f2 | tr -d [:space:])
    NCS_MCAST=$(cat ncs_mcast_net_mapping.txt | grep $NETWORK_ID | cut -d '|' -f2 | tr -d [:space:])
    # Just verifying the values for the variables above :)
    printf "| %-20s | %-15s | %-20s | %-15s | %-4s | %-8s | %-15s | %-25s |\n" $VM_NAME $VM_IP $COMPUTE_NODE $NETWORK_NAME $NCS_VLAN $NCS_VNI $NCS_MCAST $NCS_TOR
done

cat << EOA
+----------------------+-----------------+----------------------+-----------------+------+----------+-----------------+---------------------------+
EOA

# Cleanup
rm ncs_vlan_port_mapping.txt
rm ncs_mcast_net_mapping.txt
rm ncs_vni_net_mapping.txt
