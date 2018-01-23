source ~/openstack-configs/openrc
for vm in $(nova list | egrep -i '(error|active)' | cut -d "|" -f2)
do
    nova delete $vm
done
