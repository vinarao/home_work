#!/bin/bash

VTC_IP="172.20.98.241 172.20.98.242 172.20.98.246"
VTC_NODE="vtc1 vtc2"
NCS_PORT="8888"
NCS_USERNAME="admin"
#NCS_PASSWORD='Cisco123$'
NCS_PASSWORD='admin'


curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${NCS_IP}:${NCS_PORT}

cat << EOA

===============================
Checking HA Status on NCS Level
===============================
EOA


for eachIP in $VTC_IP
do
    echo -e "\nResponse from NCS ${eachIP}"
    echo "================================="
    TIME=$(date)
    echo "Local Time: $TIME"

cat << EOA
+-----------------+-----------------+--------------+-------------------------+
|  VTC HOSTNAME   |   VTC REAL IP   | DEFINED ROLE |  CURRENT/ACTUAL STATUS  |
+-----------------+-----------------+--------------+-------------------------+
EOA

    for eachVTC in $VTC_NODE
    do
        curl -k -X GET -u ${NCS_USERNAME}:${NCS_PASSWORD} -s https://${eachIP}:${NCS_PORT}/api/operational/ha-cluster/members/${eachVTC} -o ${eachVTC}_ha_response.tmp
        # Break out of loop if NCS is down
	[ $? -ne 0 ] && echo "No response from NCS" && break

        NODE_NAME=`cat ${eachVTC}_ha_response.tmp | grep name | cut -d ">" -f2 | cut -d "<" -f1` 
        NODE_IP=`cat ${eachVTC}_ha_response.tmp | grep address | cut -d ">" -f2 | cut -d "<" -f1` 
        ROLE=`cat ${eachVTC}_ha_response.tmp | grep role | cut -d ">" -f2 | cut -d "<" -f1`
        STATUS=`cat ${eachVTC}_ha_response.tmp | grep status | cut -d ">" -f2 | cut -d "<" -f1`

        # Present the output
        printf "| %-15s | %-15s | Role: %-6s | Current Status: %-7s |\n" $NODE_NAME $NODE_IP $ROLE $STATUS
	rm ${eachVTC}_ha_response.tmp
    done

cat << EOA
+-----------------+-----------------+--------------+-------------------------+
EOA

done

cat << EOB

==============================================
Checking HA Status on Corosync/Pacemaker Level
==============================================
EOB

for each in $VTC_IP
do
    REMOTE_IP=$each
    LINE_NUM=$(cat /home/admin/.ssh/known_hosts | grep -n $REMOTE_IP | cut -d ':' -f1)
    [ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" /home/admin/.ssh/known_hosts

    echo -e "\nVTC ${REMOTE_IP}"
    echo "================================="
    USERNAME="cisco"
    ssh -t ${REMOTE_IP} -l $USERNAME -o StrictHostKeyChecking=no "
        hostname
        sudo crm_mon -1 | egrep -i '(master|slave|online)'
    "
done
