#!/bin/bash

NCS_IP="172.20.98.246"
NCS_PORT="8888"
NCS_USERNAME="admin"
NCS_PASSWORD='Cisco123$'

# Query NCS for VNI allocations and store the results to a temp file
curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}/api/operational/vni-allocator?deep=true -o ncs_vni_net_mapping.tmp 

ORIGINAL_IFS=$IFS
IFS=\>
cat << EOA
+----------+---------+--------------------------------------+
|   VNI    | OBJECT  |            NETWORK_UUID              |
+----------+---------+--------------------------------------+
EOA

while read -d \< KEY VALUE
do
    if [[ $KEY = "name" ]]; then
        VNI_POOL_NAME=$VALUE
    elif [[ $KEY = "allocation" ]]; then
        echo "" > /dev/null
    elif [[ $KEY = "id" ]]; then
        VNI_ALLOC=$VALUE
    elif [[ $KEY = "owner_name" ]]; then
        OBJECT=$(echo $VALUE | cut -d "{" -f1 | egrep -o '/[a-z]*$' | tr -d [/])
        NETWORK_ID=$(echo $VALUE | cut -d "{" -f2 | cut -d "}" -f1)
        printf "| %8s | %-7s | %s |\n" $VNI_ALLOC $OBJECT $NETWORK_ID
    fi
done < ncs_vni_net_mapping.tmp

cat << EOA
+----------+---------+--------------------------------------+
EOA

# Cleanup
IFS=$ORIGINAL_IFS
rm ncs_vni_net_mapping.tmp
