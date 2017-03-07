for net in $(neutron net-list | grep '^| [0-9a-f]' | cut -d "|" -f2)
do 
    neutron net-delete $net
done
