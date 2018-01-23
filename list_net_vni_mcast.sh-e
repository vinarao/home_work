#!/bin/bash

NCS_IP="172.20.98.246"
NCS_PORT="8888"
NCS_USERNAME="admin"
NCS_PASSWORD='Cisco123$'

# Store the results to files
curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}/api/operational/vni-allocator?deep=true -o debug_network_vni.tmp
curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}/api/operational/multicast-allocator?deep=true -o debug_network_multicast.tmp
neutron net-list > debug_network_net-list.tmp

while read -r line || [[ -n $line ]]
do
    NETWORK_NAME=`echo $line | grep '| [0-9a-f]' | cut -d "|" -f3 | tr -d [:space:]`
    NETWORK_ID=`echo $line | grep '| [0-9a-f]' | cut -d "|" -f2 | tr -d [:space:]`
    SUBNET=`echo $line | grep '| [0-9a-f]' | cut -d "|" -f4`
    VNI_ALLOC=`cat debug_network_vni.tmp | grep -B2 "$NETWORK_ID" | grep 'id' | egrep -o '[1-9]{1}[0-9]{0,7}'`
    MCAST_ALLOC=`cat debug_network_multicast.tmp | grep -B3 "$NETWORK_ID" | grep 'address' | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
    if [ "$NETWORK_NAME" = "" ]
    then
        echo ""
    else
        printf "| %-7s " $NETWORK_NAME
        echo "| $NETWORK_ID | $VNI_ALLOC | $MCAST_ALLOC | $SUBNET |"
    fi
done < debug_network_net-list.tmp

# Cleanup
rm debug_network_vni.tmp
rm debug_network_net-list.tmp
rm debug_network_multicast.tmp
