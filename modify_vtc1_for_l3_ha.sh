#!/bin/bash

VTC_EXT_IP="172.20.98.241 172.20.98.242"

for each in $VTC_EXT_IP
do
VTC_IP=$each
scp cluster.conf_l3 cisco@${VTC_IP}:/opt/cisco/package/vtc/bin/cluster.conf 
scp modify_ken_vtc.sh cisco@${VTC_IP}: 

ssh -t ${VTC_IP} -l cisco "
sudo cp /home/cisco/modify_ken_vtc.sh /opt/cisco/package/vtc/bin/
sudo sed -i.bak 's/N9K/ASR9K/g' /opt/cisco/apache/apache-tomcat-7.0.57/webapps/VTS/WEB-INF/classes/vts.properties
sudo /opt/cisco/package/vtc/bin/modify_ken_vtc.sh
sudo chmod 755 /etc/init.d/corosync
sudo reboot
"
done
