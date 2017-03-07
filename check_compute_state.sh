
LIST_OF_COMPUTE="soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"

for each in $LIST_OF_COMPUTE
do
    echo ""
    echo "---START OF $each---"
    ssh -t $each '
    sudo service openstack-nova-compute status | grep -i "active:"
    sudo service neutron-vts-agent status | grep -i "active:"
    sudo service neutron-openvswitch-agent status | grep -i "active:"
'
    echo "---END OF $each---"
done
