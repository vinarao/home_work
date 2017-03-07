for vm in $(nova list | egrep -i 'error' | cut -d "|" -f2)
do
    nova delete $vm
done
