#!/bin/bash

#REMOTE_IP="172.20.98.241"
REMOTE_IP="172.20.98.242"

LINE_NUM=$(cat /home/admin/.ssh/known_hosts | grep -n $REMOTE_IP | cut -d ':' -f1)
[ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" /home/admin/.ssh/known_hosts

ssh -t $REMOTE_IP -l cisco -o StrictHostKeyChecking=no "
    sudo reboot
"
date

REMOTE_IP="172.20.98.246"
LINE_NUM=$(cat /home/admin/.ssh/known_hosts | grep -n $REMOTE_IP | cut -d ':' -f1)
[ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" /home/admin/.ssh/known_hosts

for i in {1..18}
do
ssh -t $REMOTE_IP -l cisco -o StrictHostKeyChecking=no "
    hostname
    date
"

if [ $? -eq 0 ]
then
    break
fi
sleep 1
done

for i in {1..3}
do
./check_ncs_ha_status.sh
sleep 1
done
