#!/bin/bash

if [ $EUID -ne 0 ]
then
    echo "Need to run as root.."
    echo "Exiting.."
    exit 1
fi
virsh destroy VTC1
virsh destroy VTC2

rm -f /var/lib/libvirt/images/vtc1.qcow2
rm -f /var/lib/libvirt/images/vtc2.qcow2

qemu-img create -f qcow2 -b /var/lib/libvirt/images/vtc1_backing.qcow2 /var/lib/libvirt/images/vtc1.qcow2
qemu-img create -f qcow2 -b /var/lib/libvirt/images/vtc2_backing.qcow2 /var/lib/libvirt/images/vtc2.qcow2

virsh create VTC1.xml
virsh create VTC2.xml
