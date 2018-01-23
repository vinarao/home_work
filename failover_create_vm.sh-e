#!/bin/bash

REMOTE_IP="172.20.98.241"
#REMOTE_IP="172.20.98.242"

LINE_NUM=$(cat /home/admin/.ssh/known_hosts | grep -n $REMOTE_IP | cut -d ':' -f1)
[ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" /home/admin/.ssh/known_hosts

FUNC_DATE() {
TIME=$(date)
echo "Local Time: $TIME"
}

ssh -t $REMOTE_IP -l cisco -o StrictHostKeyChecking=no "
    date
    sudo reboot
"

for i in {1..4}
do
FUNC_DATE
./create_vm_single.sh ha-c${i}-net1-13
done
