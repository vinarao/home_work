#!/bin/bash

LIST_OF_COMPUTE="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"

for eachvm in $(nova list | egrep -i '(error)' | cut -d "|" -f2)
do
echo $eachvm
VM_UUID=$eachvm
for each in $LIST_OF_COMPUTE
do
    echo ""
    echo "---START OF $each---"
    ssh -t $each "
    sudo cat /var/log/nova/nova-compute.log | grep ${VM_UUID}
    sudo cat /var/log/neutron/ciscovts-agent.log | grep ${PORT_UUID}
    echo ""
    sudo ovs-vsctl show | grep -B1 $(echo $PORT_UUID | cut -c -11)
"
    echo "---END OF $each---"
done

done
