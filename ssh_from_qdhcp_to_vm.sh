#ip netns exec qdhcp-decfacc7-e425-4076-8ccd-6ba5a8a1369f ping -c 3 192.168.7.2

VM_NAME=$1
#VM_NAME=vm-c1-net1-01

if [ $# -ne 1 ]
then
    echo "The script only takes in 1 argument."
    echo "Usage: $0 <VM_NAME>"
    exit 1
fi

if [ $(nova list | egrep -c "[ ]$VM_NAME[ ]") -eq 0 ]
then
    echo "VM name '$VM_NAME' is not found."
    exit 1
elif [ $(nova list | egrep -c "[ ]$VM_NAME[ ]") -gt 1 ]
then
    echo "There are more than 1 VM with '$VM_NAME' found."
    exit 2
fi

NETWORK_NAME=$(nova show $VM_NAME | egrep -o '^.* network' | awk '{print $2}' | tr -d [:space:])
echo "Network Name: $NETWORK_NAME"

if [ $(echo "$NETWORK_NAME" | egrep -c "$NETWORK_NAME") -eq 0 ]
then
    echo "Network name '$NETWORK_NAME' is not found."
    exit 3
elif [ $(echo "$NETWORK_NAME" | egrep -c "$NETWORK_NAME") -gt 1 ]
then
    echo "There are more than 1 network with Network '$NETWORK_NAME' found."
    exit 4
fi

VM_IP=$(nova show $VM_NAME | egrep '^.* network' | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
echo "VM NAME: $VM_NAME"
echo "VM IP Address: $VM_IP"
NETWORK_ID=$(neutron net-list | egrep "[ ]${NETWORK_NAME}[ ]" | cut -d "|" -f2 | tr -d [:space:])

# Execute ping from namespace
#cat <<EOA
echo "executing command 'sudo ip netns exec qdhcp-${NETWORK_ID} '"

KNOWN_HOST_FILE="/root/.ssh/known_hosts"
LINE_NUM=$(cat $KNOWN_HOST_FILE | grep -n $REMOTE_IP | cut -d ':' -f1)
[ "$LINE_NUM" != "" ] && sed -i "${LINE_NUM}d" $KNOWN_HOST_FILE

COMMAND="sudo ip netns exec qdhcp-${NETWORK_ID} ssh -i /home/admin/ken/admin.pem ${VM_IP} -l cirros -o StrictHostKeyChecking=no "
echo "executing command '$COMMAND'"
$COMMAND
#EOA
