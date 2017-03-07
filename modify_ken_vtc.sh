#!/bin/bash


#NEED TO ADD ROOT CHECK

CONFIG_FILE="/opt/cisco/package/vtc/bin/cluster.conf"
CLUSTER_CONF_DATA=$(cat $CONFIG_FILE)
MASTER_INTERFACE=$(echo "$CLUSTER_CONF_DATA" | grep 'master_network_interface' | cut -d '=' -f2 | tr -d [:space:])
SLAVE_INTERFACE=$(echo "$CLUSTER_CONF_DATA" | grep 'slave_network_interface' | cut -d '=' -f2 | tr -d [:space:])
MASTER_IP=$(echo "$CLUSTER_CONF_DATA" | grep 'master_ip' | cut -d '=' -f2 | tr -d [:space:])
SLAVE_IP=$(echo "$CLUSTER_CONF_DATA" | grep 'slave_ip' | cut -d '=' -f2 | tr -d [:space:])
MASTER_HOSTNAME=$(echo "$CLUSTER_CONF_DATA" | grep 'master_name' | cut -d '=' -f2 | tr -d [:space:])
SLAVE_HOSTNAME=$(echo "$CLUSTER_CONF_DATA" | grep 'slave_name' | cut -d '=' -f2 | tr -d [:space:])
VALID_HOSTNAME="(^[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$)"
[[ ! $MASTER_HOSTNAME =~ $VALID_HOSTNAME ]] && echo "[ERROR] Please enter a valid hostname for master_name <[a-z,A-Z,0-9,-]>"
[[ ! $SLAVE_HOSTNAME =~ $VALID_HOSTNAME ]] && echo "[ERROR] Please enter a valid hostname for slave_name <[a-z,A-Z,0-9,-]>"

echo "Checking own interface IP address if I'm defined as Master or Slave"
FUNC_NODE_ROLE() {
if [[ $MY_IP =~ $MASTER_IP ]]
then
    NODE_ROLE="master"
    echo "I'm master!!!"
elif [[ $MY_IP =~ $SLAVE_IP ]]
then
    NODE_ROLE="slave"
    echo "I'm slave!!!"
else
    NODE_ROLE="unknown"
fi
}

NODE_ROLE=""
MY_IP=$(ip -4 addr show $MASTER_INTERFACE | grep -o 'inet .* brd' | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
# echo will be removed
echo MY IP IS $MY_IP
FUNC_NODE_ROLE
if [ "$NODE_ROLE" = "unknown" ]
then
    MY_IP=$(ip -4 addr show $SLAVE_INTERFACE | grep -o 'inet .* brd' | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    FUNC_NODE_ROLE
fi
[ "$NODE_ROLE" = "unknown" ] && \
echo "Node role can't be determined. Please check the $CONFIG_FILE and make sure the intended IP address is configured on the node" && \
exit 1

FUNC_MODIFY_HOSTS_AND_HOSTNAME() {
sed -i.bak "s/vtc$/$VTC_HOSTNAME/" /etc/hostname && hostname $VTC_HOSTNAME && \
sed -i.bak "s/vtc$/$VTC_HOSTNAME/" /etc/hosts && \
echo "$MASTER_IP $MASTER_HOSTNAME " | sudo tee -a /etc/hosts && \
echo "$SLAVE_IP $SLAVE_HOSTNAME " | sudo tee -a /etc/hosts
}

if [ "$NODE_ROLE" = "master" ]
then
    VTC_HOSTNAME=$MASTER_HOSTNAME
    FUNC_MODIFY_HOSTS_AND_HOSTNAME
elif [ "$NODE_ROLE" = "slave" ]
then
    VTC_HOSTNAME=$SLAVE_HOSTNAME
    FUNC_MODIFY_HOSTS_AND_HOSTNAME
fi
