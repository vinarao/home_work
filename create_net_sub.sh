#!/bin/bash

#*******************************************************************************
# Script to create multiple networks and subnets in OpenStack using CLI.
# Uses 192.168.1.0/24 for net1/subnet1
#
# Added multi-tenant network and subnet creation
#
# Created by: Ken Go
# Last Update: Apr 08, 2015
#*******************************************************************************

FUNC_USAGE() {
    echo "Usage: $0 <start> <end>"
    echo "or"
    echo "Usage: $0 tenant<1 or 2 digit number> <start> <end>"
}

if [ $# -eq 3 ]
then
    OPTION=1
    TENANT=$1
    START=$2
    END=$3
    [ ! $(echo $TENANT | egrep 'tenant[0-9]{1,2}') ] && \
    echo "Incorrect tenant name. Use tenant<1 or 2 digit number>" && \
    FUNC_USAGE && exit 2
elif [ $# -eq 2 ]
then
    OPTION=2
    TENANT=""
    START=$1
    END=$2
else
    FUNC_USAGE
    exit 1
fi

[ ! $(echo $START | egrep '[0-9]{1,2}') ] || [ ! $(echo $END | egrep '[0-9]{1,2}') ] && echo "Enter valid number for <start> <end>" && exit 2
[ $END -lt $START ] && echo "Start Net should be smaller then End Net" && exit 2

NETMASK="24"

FUNC_NET_DEFAULT() {
for i in $(eval echo {${START}..${END}})
do
neutron net-create net${i}
neutron subnet-create --name subnet${i} net${i} 192.168.${i}.0/${NETMASK}
done
}

FUNC_NET_TENANT() {
for i in $(eval echo {${START}..${END}})
do
neutron --os-tenant-name $TENANT net-create ${TENANT}-net${i}
neutron --os-tenant-name $TENANT subnet-create --name ${TENANT}-subnet${i} ${TENANT}-net${i} 192.168.${i}.0/${NETMASK}
done
}

if [ $OPTION -eq 1 ]
then
    FUNC_NET_TENANT
elif [ $OPTION -eq 2 ]
then
    FUNC_NET_DEFAULT
fi
