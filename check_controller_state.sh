echo "Checking if existing router, network, subnet, or port exist..."
[[ ! $(neutron port-list) ]] && [[ ! $(neutron net-list) ]] && [[ ! $(neutron router-list) ]] && [[ ! $(neutron subnet-list) ]] && echo 'All Clean! No router, network, subnet, port found!' || echo 'Testbed not in clean state!'

echo ""
echo "Checking Status of Neutron Agents"
neutron agent-list

echo ""
echo "Checking Status of Nova Services"
nova service-list
