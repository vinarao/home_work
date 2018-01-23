#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Usage: $0 <start> <end>"
    exit 1
fi

START=$1
END=$2

[ $END -lt $START ] && echo "Start Net should be smaller then End Net" && exit 2

for i in $(eval echo {${START}..${END}})
do
    ./create_vm_single.sh vm-c1-net${i}-01
    ./create_vm_single.sh vm-c2-net${i}-02
    ./create_vm_single.sh vm-c3-net${i}-03
    ./create_vm_single.sh vm-c4-net${i}-04
done
