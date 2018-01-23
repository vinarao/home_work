for vm in $(nova list | egrep -i 'build' | cut -d "|" -f2)
do
    nova delete $vm
done
