#!/bin/bash

if [ $EUID -ne 0 ]
then
    echo "Need to run as root.."
    echo "Exiting.."
    exit 1
fi

# Source directory
DIR_PATH="/home/admin/ken_vts_to_use"

service neutron-vts-agent stop
cp ${DIR_PATH}/host-agent/cisco-vts-agent /usr/bin/cisco-vts-agent
cp ${DIR_PATH}/host-agent/neutron-vts-agent.service /usr/lib/systemd/system/neutron-vts-agent.service
systemctl daemon-reload
service neutron-openvswitch-agent stop
systemctl enable neutron-vts-agent.service
service neutron-vts-agent start
