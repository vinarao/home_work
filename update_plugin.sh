#!/bin/bash

if [ $EUID -ne 0 ]
then
    echo "Need to run as root.."
    echo "Exiting.."
    exit 1
fi

DIR_PATH="/home/admin/ken_vts_to_use"

cp ${DIR_PATH}/openstack-plugin/mechanism_ncs.py /usr/lib/python2.7/site-packages/neutron/plugins/ml2/drivers/mechanism_ncs.py 
cp ${DIR_PATH}/openstack-plugin/cisco_vts_plugin.py /usr/lib/python2.7/site-packages/neutron/plugins/cisco/service_plugins/cisco_vts_plugin.py
service neutron-server restart
