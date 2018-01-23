#!/bin/bash

curl -X GET -u admin:admin -s http://172.20.98.198:8080/api/operational/vlan-allocator?deep=true -o ncs_vlan_port_mapping.tmp > /dev/null
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
    elif [[ $KEY = "id" ]]; then
        VLAN_ID=$VALUE
    elif [[ $KEY = "owner_name" ]]; then
        PORT_ID=$(echo $VALUE | cut -d "{" -f2 | cut -d "}" -f1)
        printf "| %-15s | %4s " $TOR_NAME $VLAN_ID
        echo "| $PORT_ID |"
    fi
done < ncs_vlan_port_mapping.tmp

echo "+-----------------+------+--------------------------------------+"

IFS=$ORIGINAL_IFS
rm ncs_vlan_port_mapping.tmp
