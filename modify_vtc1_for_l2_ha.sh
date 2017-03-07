#!/bin/bash

VTC1_EXT_IP="172.20.98.241"
VTC2_EXT_IP="172.20.98.242"
VTC1_INT_IP="$VTC1_EXT_IP"
VTC2_INT_IP="$VTC2_EXT_IP"
VTC1_HOSTNAME="vtc1"
VTC2_HOSTNAME="vtc2"

scp cluster.conf_l2 cisco@${VTC1_EXT_IP}:/opt/cisco/package/vtc/bin/cluster.conf 

ssh -t ${VTC1_EXT_IP} -l cisco "
sudo sed -i.bak "s/vtc$/$VTC1_HOSTNAME/" /etc/hostname
sudo sed -i.bak "s/vtc$/$VTC1_HOSTNAME/" /etc/hosts
echo \"${VTC1_INT_IP} $VTC1_HOSTNAME \" | sudo tee -a /etc/hosts
echo \"${VTC2_INT_IP} $VTC2_HOSTNAME \" | sudo tee -a /etc/hosts
sudo reboot
"
