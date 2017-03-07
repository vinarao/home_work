#!/bin/bash

if [ $EUID -ne 0 ]
then
    echo "Need to run as root.."
    echo "Exiting.."
    exit 1
fi

echo "Destroying VTC VM"
virsh destroy VTC1

echo "Copying vtc.qcow2 to /var/lib/libvirt/images/"
cp /home/admin/ken_vts_to_use/vtc.qcow2 /var/lib/libvirt/images/vtc1.qcow2

echo "Checking MD5"
md5sum /home/admin/ken_vts_to_use/vtc.qcow2 /var/lib/libvirt/images/vtc1.qcow2

echo "Spawning VTC VM"
virsh create VTC1_L2.xml

sleep 60
./vtc1_l2.exp

