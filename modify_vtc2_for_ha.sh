#!/bin/bash

VTC1_EXT_IP="172.20.98.241"
VTC2_EXT_IP="172.20.98.242"
VTC1_INT_IP="101.1.1.4"
VTC2_INT_IP="102.1.1.4"

scp cluster.conf_l3 cisco@${VTC2_EXT_IP}:/opt/cisco/package/vtc/bin/cluster.conf 

ssh -t ${VTC2_EXT_IP} -l cisco "
sudo sed -i.bak 's/vtc$/vtc2/' /etc/hostname
sudo sed -i.bak 's/vtc$/vtc2/' /etc/hosts
echo \"${VTC1_INT_IP} vtc1 \" | sudo tee -a /etc/hosts
echo \"${VTC2_INT_IP} vtc2 \" | sudo tee -a /etc/hosts
sudo mv /home/cisco/gui/ssl_conf/server.xml /opt/cisco/apache/apache-tomcat-7.0.57/conf/
sudo cp /etc/corosync/corosync.conf /etc/corosync/corosync.conf.template
sudo reboot
"
