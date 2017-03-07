#!/bin/bash

LIST_OF_SERVER="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"

# PASSWORD is used inside sed. Escape special characters.
#PASSWORD='admin'
#PASSWORD='Cisco123\$'
PASSWORD='Cisco123$'
# Change Password in the following files.
sudo sed -i.bak "s/password = .*/password = $PASSWORD/" /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
sudo sed -i.bak "s/password = .*/password = $PASSWORD/" /etc/neutron/plugin.ini

# URL is used inside sed. Escape special characters.
URL='https:\/\/172.20.98.246:8888\/api\/running\/openstack'
#URL='http:\/\/172.20.98.198:8080\/api\/running\/openstack'
#URL='https:\/\/172.20.98.198:8888\/api\/running\/openstack'
# Change URL in the following files.
sudo sed -i.bak "s/^url = .*/url = $URL/" /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
sudo sed -i.bak "s/^url = .*/url = $URL/" /etc/neutron/plugin.ini

for each in $LIST_OF_SERVER
do
    ssh -t $each "
        date
        sudo sed -i.bak \"s/password = .*/password = $PASSWORD/\" /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
        sudo sed -i.bak \"s/^url = .*/url = $URL/\" /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
    "
done
