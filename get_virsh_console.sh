#!/bin/bash

VM_NAME=$(virsh list | grep -v '^ Id' | awk '{print $2}')

FUNC_GET_CONSOLE() {
    for each in $(virsh list | grep -v '^ Id' | awk '{print $2}')
    do
	VM_NAME=$each
	echo "$VM_NAME"
	virsh dumpxml $VM_NAME | grep -A1 console | grep service
    done
}

if [[ $VM_NAME ]]
then
	echo "Console Port of Active VMs:"
	FUNC_GET_CONSOLE
else
	echo "[INFO] There are no VMs..."
	echo "Exiting..."
	exit 0
fi


