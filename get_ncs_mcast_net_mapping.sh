#!/bin/bash

NCS_IP="172.20.98.246"
NCS_PORT="8888"
NCS_USERNAME="admin"
NCS_PASSWORD='Cisco123$'

# Store the results to files
#curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}/api/operational/vni-allocator?deep=true -o ncs_vni_net_mapping.tmp 
curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}/api/operational/multicast-allocator?deep=true -o ncs_mcast_net_mapping.tmp

ORIGINAL_IFS=$IFS
IFS=\>
cat << EOA
+-----------------+--------------------------------------+
|    MULTICAST    |            NETWORK_UUID              |
+-----------------+--------------------------------------+
EOA

while read -d \< KEY VALUE
do
    if [[ $KEY = "name" ]]; then
        MCAST_POOL_NAME=$VALUE
    elif [[ $KEY = "allocation" ]]; then
        echo "" > /dev/null
    elif [[ $KEY = "address" ]]; then
        MCAST_ALLOC=$VALUE
    elif [[ $KEY = "owner_name" ]]; then
        NETWORK_ID=$(echo $VALUE | cut -d "{" -f2 | cut -d "}" -f1)
        printf "| %15s | %s |\n" $MCAST_ALLOC $NETWORK_ID
    fi
done < ncs_mcast_net_mapping.tmp

echo "+-----------------+--------------------------------------+"

# Cleanup
IFS=$ORIGINAL_IFS
rm ncs_mcast_net_mapping.tmp
