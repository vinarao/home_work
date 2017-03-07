for port in $(neutron port-list | grep '^| [0-9a-f]' | cut -d "|" -f2)
do 
    neutron port-delete $port
done
