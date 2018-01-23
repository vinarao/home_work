#!/bin/bash

NCS_IP="172.20.98.246"
NCS_PORT="8888"
NCS_USERNAME="admin"
NCS_PASSWORD='Cisco123$'

# Query NCS for VLAN allocations and store the results to a temp file
curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}/api/operational/vlan-allocator?deep=true -o ncs_vlan_port_mapping.tmp > /dev/null
ORIGINAL_IFS=$IFS
IFS=\>
VLAN_ID=""
PORT_ID=""
cat << EOA
+-----------------+------+--------------------------------------+
|    TOR_NAME     | VLAN |              PORT_UUID               |
+-----------------+------+--------------------------------------+
EOA
while read -d \< KEY VALUE
do
    if [[ $KEY = "name" ]]; then
        TOR_NAME=$VALUE
    elif [[ $KEY = "allocation" ]]; then
        echo "" > /dev/null
    elif [[ $KEY = "id" ]]; then
        VLAN_ID=$VALUE
    elif [[ $KEY = "owner_name" ]]; then
        PORT_ID=$(echo $VALUE | cut -d "{" -f2 | cut -d "}" -f1)
        printf "| %-15s | %4s " $TOR_NAME $VLAN_ID
        echo "| $PORT_ID |"
    fi
done < ncs_vlan_port_mapping.tmp

echo "+-----------------+------+--------------------------------------+"

# Cleanup
IFS=$ORIGINAL_IFS
rm ncs_vlan_port_mapping.tmp
