#!/bin/bash

LIST_OF_SERVER="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"
HOST_AGENT_DIR="/home/admin/ken_vts_to_use/host-agent"

for each in $LIST_OF_SERVER
do
    scp ${HOST_AGENT_DIR}/* ${each}:

    ssh -t $each -o StrictHostKeyChecking=no "
        date
        sudo service neutron-vts-agent stop
        sudo cp cisco-vts-agent /usr/bin/cisco-vts-agent
        sudo cp neutron-vts-agent.service /usr/lib/systemd/system/neutron-vts-agent.service
        sudo systemctl daemon-reload
        sudo service neutron-openvswitch-agent stop
        sudo service neutron-vts-agent start
        sudo systemctl enable neutron-vts-agent.service
    "
done
