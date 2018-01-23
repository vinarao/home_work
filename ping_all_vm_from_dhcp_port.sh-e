#!/bin/bash

[ -e ken_testing.log ] && rm ken_testing.log

for vm in $(nova list | egrep -i '(active)' | cut -d "|" -f3)
do
    VM_NAME=$vm
    LOG=$(./ping_from_qdhcp_to_vm.sh $VM_NAME | tee -a ken_testing.log)
    PACKET_RECEIVED=$(echo "$LOG" | egrep received | awk '{print $4}')
    PACKET_TRANSMIT=$(echo "$LOG" | egrep -o '.*transmitted' | awk '{print $1}')
    if [ "$PACKET_RECEIVED" = "0" ]
    then
        echo "$VM_NAME: [FAILED] $PACKET_RECEIVED of $PACKET_TRANSMIT Packets Received"
    elif [ "$PACKET_RECEIVED" = "$PACKET_TRANSMIT" ]
    then
        echo "$VM_NAME: [OK] $PACKET_RECEIVED of $PACKET_TRANSMIT Packets Received"
    else
        echo "$VM_NAME: [WARNING] Only $PACKET_RECEIVED of $PACKET_TRANSMIT Packets Received"
    fi
done
