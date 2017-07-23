#!/bin/bash

#*******************************************************************************
# Script to put the key to a remote server for key-based login. 
# It also sets the user 'cisco' to execute sudo without needing to enter the
# password.
#
# Created by:   Vinay Rao
# Last Updated: Apr 07, 2015
#*******************************************************************************

# Change the filename as you please.
SUDOERS_FILENAME="AddedSudoers"

# Modify VTC IP. List multiple VTC IP 
VTC_IP="172.20.98.241 172.20.98.242"
#VTC_IP="172.20.98.198"
USERNAME="cisco"

for each in $VTC_IP
do
    REMOTE_IP=$each
    #PUB_KEY=$(cat /home/admin/.ssh/id_rsa.pub) 
    PUB_KEY1=$(cat /home/admin/.ssh/id_rsa.pub) 
    PUB_KEY2=$(cat /home/admin/ken/kego-mac-keypair.txt) 
    LINE_NUM=$(cat /home/admin/.ssh/known_hosts | grep -n $REMOTE_IP | cut -d ':' -f1)
    [ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" /home/admin/.ssh/known_hosts

# The sudoers part below may not work for RHEL. This works for Ubuntu.
    ssh -t $REMOTE_IP -l $USERNAME -o StrictHostKeyChecking=no "
    echo $PUB_KEY1 | tee -a ~/.ssh/authorized_keys > /dev/null
    echo $PUB_KEY2 | tee -a ~/.ssh/authorized_keys > /dev/null
    chmod 600 ~/.ssh/authorized_keys
    echo "$USERNAME	ALL=NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${SUDOERS_FILENAME}
    sudo chmod 0440 /etc/sudoers.d/${SUDOERS_FILENAME}
    "
done

LIST_OF_SERVERS="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"
USERNAME="admin"

for each in $LIST_OF_SERVERS
do
    REMOTE_IP=$each

# The sudoers part below may not work for RHEL. This works for Ubuntu.
    ssh -t $REMOTE_IP -l $USERNAME "
    echo "$USERNAME	ALL=NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${SUDOERS_FILENAME}
    sudo chmod 0440 /etc/sudoers.d/${SUDOERS_FILENAME}
    "
done
