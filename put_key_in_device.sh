#!/bin/bash

#*******************************************************************************
# Script to put the key to a remote server for key-based login. 
# It also sets the user 'cisco' to execute sudo without needing to enter the
# password.
#
# Created by:   Vinay Rao
# Last Updated: Mar 28, 2015
#*******************************************************************************

# Change the filename as you please.
SUDOERS_FILENAME="AddedSudoers"

# Modify VTC IP. List multiple VTC IP 
#VTC_IP="172.20.98.241 172.20.98.242"
#VTC_IP="172.20.98.198"
USERNAME="cisco"
VTC_IP=$1

if [ $# -eq 0 ]
then
    echo The script requires at least 1 argument.
    exit 1
fi

for each in $VTC_IP
do
    REMOTE_IP=$each
    PUB_KEY=$(cat /home/admin/.ssh/id_rsa.pub) 

# The sudoers part below may not work for RHEL. This works for Ubuntu.
    ssh -t $REMOTE_IP -l $USERNAME "
    [ ! -d ~/.ssh ] && mkdir ~/.ssh
    echo $PUB_KEY | tee -a ~/.ssh/authorized_keys > /dev/null
    chmod 600 ~/.ssh/authorized_keys
    echo "$USERNAME	ALL=NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${SUDOERS_FILENAME}
    sudo chmod 0440 /etc/sudoers.d/${SUDOERS_FILENAME}
    "
done

