#!/bin/bash

LIST_ROUTER_UUID=$(neutron router-list | grep '^| [0-9a-f]' | cut -d "|" -f2)

for each in $LIST_ROUTER_UUID
do 
    ROUTER_UUID=$each
    LIST_SUBNET_UUID=$(neutron router-port-list $ROUTER_UUID | egrep -o '\{.*\}' | cut -d ':' -f2 | cut -d ',' -f1 | tr -d [\"])
    for each in $LIST_SUBNET_UUID
    do
         SUBNET_UUID=$each
         # dettached the subnets from the router
         COMMAND="neutron router-interface-delete $ROUTER_UUID $SUBNET_UUID"
         echo "[INFO] Executing '$COMMAND'"
         $COMMAND
    done
    # Delete the router after dettaching the subnets from the router
    COMMAND="neutron router-delete $ROUTER_UUID"
    echo "[INFO] Executing '$COMMAND'"
    $COMMAND
done
