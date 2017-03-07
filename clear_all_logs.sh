#!/bin/bash

# Constants
LIST_OF_COMPUTES="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"
COMPUTE_USERNAME="admin"
LIST_OF_VTC="172.20.98.241 172.20.98.242"
VTC_USERNAME="cisco"
LIST_OF_N9K="soltb1-tor1 soltb1-tor2 soltb1-tor3 soltb1-bleaf1 soltb1-spine1"
N9K_USERNAME="lab"

# Define functions
FUNC_RESPONSE() {
    if [ "$RESPONSE" = 'yes' ]
    then
        echo ""
    elif [ "$RESPONSE" = 'no' ]
    then
        echo ""
        echo "Logs are not cleared"
        echo "Exiting.."
        exit 0
    else 
        echo -n "[yes/no]"
        read RESPONSE
        FUNC_RESPONSE
    fi
}

FUNC_CLEAR_CONTROLLER_LOG() {
    sudo truncate -s 0 /var/log/neutron/server.log
    sudo truncate -s 0 /var/log/neutron/ciscovts-agent.log
    sudo truncate -s 0 /var/log/nova/nova-scheduler.log
    sudo truncate -s 0 /var/log/nova/nova-conductor.log
    sudo truncate -s 0 /var/log/nova/nova-api.log
}

FUNC_CLEAR_COMPUTE_LOG() {
    ssh -t $each -l $COMPUTE_USERNAME '
    sudo truncate -s 0 /var/log/neutron/ciscovts-agent.log
    sudo truncate -s 0 /var/log/nova/nova-compute.log
    '
}

FUNC_CLEAR_VTC_LOG() {
    ssh -t $each -l $VTC_USERNAME '
    sudo truncate -s 0 /var/log/ncs/ncs-java-vm.log
    sudo truncate -s 0 /var/log/ncs/localhost.access
    sudo truncate -s 0 /var/log/ncs/ned-cisco-nx-soltb1-tor1.trace
    sudo truncate -s 0 /var/log/ncs/ned-cisco-nx-soltb1-tor2.trace
    sudo truncate -s 0 /var/log/ncs/ned-cisco-nx-soltb1-tor3.trace
    '
}

FUNC_CLEAR_N9K_LOG() {
    COMMAND=$1
    ssh -t $each -l $N9K_USERNAME "
    $COMMAND
    "
}

cat << EOA
This will clear the contents of the following logs in the controller node / network node, compute nodes, and VTC/NCS.

[WARNING] The commands in the script will run as sudo.

EOA

echo -n "Do you want to continue? (You will NOT be prompted again.) [yes/no]: "

read RESPONSE
FUNC_RESPONSE

# If response is yes, continue executing.
# Start cleaning logs on controller/network node
echo "========================================================="
echo -e "\nClearing the logs on the controller/network node(s)..."
FUNC_CLEAR_CONTROLLER_LOG

# Start clearing logs on compute nodes
echo -e "\nClearing the logs on the compute node(s)..."
for each in $LIST_OF_COMPUTES
do
    echo ""
    echo "---Clearing logs on ***$each***---"
    FUNC_CLEAR_COMPUTE_LOG
    echo "---END OF ***$each***---"
done

# Start clearing logs on VTC nodes"
echo -e "\nClearing the logs on the VTC node(s)..."
for each in $LIST_OF_VTC
do
    echo ""
    echo "---Clearing logs on ***$each***---"
    FUNC_CLEAR_VTC_LOG
    echo "---END OF ***$each***---"
done

# Start clearing logs on the TORs"
echo -e "\nClearing the logs on the N9K TOR(s)..."
for each in $LIST_OF_N9K
do
    echo ""
    echo "---Clearing logs on ***$each***---"
    FUNC_CLEAR_N9K_LOG "clear accounting log"
    FUNC_CLEAR_N9K_LOG "clear logging logfile"
    echo "---END OF ***$each***---"
done
