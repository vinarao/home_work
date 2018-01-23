#!/bin/bash

sudo ntpdate ntp.esl.cisco.com

LIST_OF_SERVER="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4 172.20.98.241 172.20.98.242"

for each in $LIST_OF_SERVER
do
    echo ""
    echo "--- START OF $each ---"
    ssh -t $each '
    sudo ntpdate ntp.esl.cisco.com
    '
    echo "--- END OF $each ---"
done
