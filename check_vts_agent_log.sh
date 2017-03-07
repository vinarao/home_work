#!/bin/bash

UUID=$1

LIST_OF_COMPUTE="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"

for each in $LIST_OF_COMPUTE
do
    echo ""
    echo "---START OF $each---"
    ssh -t $each "
    sudo cat /var/log/neutron/ciscovts-agent.log | grep $UUID
    echo ""
    sudo ovs-vsctl show | grep -B1 $(echo $UUID | cut -c -11) | grep -v fail_mode
"
    echo "---END OF $each---"
done
