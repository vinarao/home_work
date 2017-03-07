#!/bin/bash

validate_ip()
{
currentIP=$1
IFS="."
splitIp=($currentIP)


for (( x=0; x<${#splitIp[@]}; x++ ))
do
	#echo ${splitIp[$x]}
	if [[ ${splitIp[$x]} -gt 255 ]]
	then
		echo "$currentIP is invalid"
		exit 1
	fi
	if [[ $x -eq 0 ]]
	then
		if [[ ${splitIp[$x]} -gt 223 ]] && [[ ${splitIp[$x]} -lt 240 ]]
		then
			echo "$currentIP is invalid"
			exit 1
		fi
	fi
        if [[ $x -eq 3 ]]
        then
                if [[ ${splitIp[$x]} -gt 254 ]]
                then
                        echo "$currentIP is invalid"
			exit 1
                fi
        fi
done
return 0
}

if [ $EUID -ne 0 ]
then
    echo "Need to run as root.."
    echo "Exiting.."
    exit 1
fi

#valid_ip="(^22[0-3]\.|^2[0-1][0-3]\.|^1[0-9][0-9]\.|^[0-9]{1,2}\.)(2[0-5][0-5]\.|1[0-9][0-9]\.|[0-9]{1,2}\.)(2[0-5][0-5]\.|1[0-9][0-9]\.|[0-9]{1,2}\.)(2[0-5][0-5]$|1[0-9][0-9]$|[0-9]{1,2}$)"


###Read input from cluster.conf
setup_install_path="/opt/cisco/package/vtc/bin"


ncs_port=`cat $setup_install_path/cluster.conf | grep "^ncs_port" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
ncs_user=`cat $setup_install_path/cluster.conf | grep "^ncs_user" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
ncs_pass=`cat $setup_install_path/cluster.conf | grep "^ncs_pass" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`

vip=`cat $setup_install_path/cluster.conf | grep "^vip" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
#vip="240.255.255.254"
#[[ $vip =~ $valid_ip ]] || { echo "Vip is not a valid ip"; exit 1; }
validate_ip "$vip"

master_name=`cat $setup_install_path/cluster.conf | grep "^master_name" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
master_ip=`cat $setup_install_path/cluster.conf | grep "^master_ip" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
master_network_interface=`cat $setup_install_path/cluster.conf | grep "^master_network_interface" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
#[[ $master_ip =~ $valid_ip ]] || { echo "Master IP is not a valid ip"; exit 1; }
validate_ip "$master_ip"

slave_name=`cat $setup_install_path/cluster.conf | grep "^slave_name" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
slave_ip=`cat $setup_install_path/cluster.conf | grep "^slave_ip" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
slave_network_interface=`cat $setup_install_path/cluster.conf | grep "^slave_network_interface" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
#[[ $slave_ip =~ $valid_ip ]] || { echo "Slave IP is not a valid ip"; exit 1; }
validate_ip "$slave_ip"

vrf_name=`cat $setup_install_path/cluster.conf | grep "^vrf_name" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`

xrvr1_mgmt_ip=`cat $setup_install_path/cluster.conf | grep "^xrvr1_mgmt_ip" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
xrvr1_bgp_neighbors=`cat $setup_install_path/cluster.conf | grep "^xrvr1_bgp_neighbor" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
#[[ $xrvr1_mgmt_ip =~ $valid_ip ]] || { echo "XRVR1 management IP is not a valid ip"; exit 1; }
validate_ip "$xrvr1_mgmt_ip"

###Validate each neighbor in list
IFS=","
splitNeighbors=($xrvr1_bgp_neighbors)

for (( y=0; y<${#splitNeighbors[@]}; y++ ))
do
	validate_ip "${splitNeighbors[$y]}"
done


xrvr2_mgmt_ip=`cat $setup_install_path/cluster.conf | grep "^xrvr2_mgmt_ip" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
xrvr2_bgp_neighbors=`cat $setup_install_path/cluster.conf | grep "^xrvr2_bgp_neighbor" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
#[[ $xrvr2_mgmt_ip =~ $valid_ip ]] || { echo "XRVR2 management IP is not a valid ip"; exit 1; }
validate_ip "$xrvr2_mgmt_ip"

###Validate each neighbor in list
IFS=","
splitNeighbors=($xrvr2_bgp_neighbors)

for (( y=0; y<${#splitNeighbors[@]}; y++ ))
do
        validate_ip "${splitNeighbors[$y]}"
done

xrvr_user=`cat $setup_install_path/cluster.conf | grep "xrvr_user" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
xrvr_pass=`cat $setup_install_path/cluster.conf | grep "xrvr_pass" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`

remote_ASN=`cat $setup_install_path/cluster.conf | grep "remote_ASN" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
local_ASN=`cat $setup_install_path/cluster.conf | grep "local_ASN" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`

bgp_keepalive=`cat $setup_install_path/cluster.conf | grep "bgp_keepalive" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
bgp_hold=`cat $setup_install_path/cluster.conf | grep "bgp_hold" | cut -d "#" -f 1 | cut -d "=" -f 2 | tr -d " " | tr -d "\t"`
IFS=" "

#### local_ip=`ifconfig $master_network_interface | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1`

#echo "Inputs:$ncs_port,$ncs_user,$ncs_pass,$vip,$master_name,$master_ip,$master_network_interface,$slave_name,$slave_ip,$slave_network_interface,$vrf_name,$xrvr1_mgmt_ip,$xrvr1_bgp_neighbors,$xrvr2_mgmt_ip,$xrvr2_bgp_neighbors,$xrvr_user,$xrvr_pass,$remote_ASN,$local_ASN"

###Check if /etc/hosts has been configured
master_search=`cat /etc/hosts | grep "$master_name" | grep "$master_ip"`
slave_search=`cat /etc/hosts | grep "$slave_name" | grep "$slave_ip"`
if [ "$master_search" = "" ] || [ "$slave_search" = "" ]
then
	echo "/etc/hosts not configured with master and slave node information or the information is not correct. Please check to make sure both there are correct entries for the master node and slave node."
	exit 1
fi

if [ "$master_name" = "$slave_name" ]
then
	echo "Master node and slave node can not have the same hostname."
	exit 1
fi



###Configuring inject.py script
if [ -e "/usr/lib/ocf/resource.d/vts/inject_route.py.template" ]
then
        cp /usr/lib/ocf/resource.d/vts/inject_route.py.template /usr/lib/ocf/resource.d/vts/inject_route.py
else
	cp /usr/lib/ocf/resource.d/vts/inject_route.py /usr/lib/ocf/resource.d/vts/inject_route.py.template
fi



sed -i.bak "s/master_host=MASTER_HOST/master_host=\"$master_name\"/" /usr/lib/ocf/resource.d/vts/inject_route.py
sed -i.bak "s/vtc1_ip=VTC1_IP/vtc1_ip=\"$xrvr1_mgmt_ip\"/" /usr/lib/ocf/resource.d/vts/inject_route.py
sed -i.bak "s/vtc2_ip=VTC2_IP/vtc2_ip=\"$xrvr2_mgmt_ip\"/" /usr/lib/ocf/resource.d/vts/inject_route.py

sed -i.bak "s/xrvr_user=XRVR_USER/xrvr_user=\"$xrvr_user\"/" /usr/lib/ocf/resource.d/vts/inject_route.py
sed -i.bak "s/xrvr_pass=XRVR_PASS/xrvr_pass=\"$xrvr_pass\"/" /usr/lib/ocf/resource.d/vts/inject_route.py
sed -i.bak "s/vrf_name=VRF_NAME/vrf_name=\"$vrf_name\"/" /usr/lib/ocf/resource.d/vts/inject_route.py
sed -i.bak "s/vip=VIP/vip=\"$vip\"/" /usr/lib/ocf/resource.d/vts/inject_route.py

###Configuring check_router.py script
if [ -e "/usr/lib/ocf/resource.d/vts/check_router.py.template" ]
then
	cp /usr/lib/ocf/resource.d/vts/check_router.py.template /usr/lib/ocf/resource.d/vts/check_router.py
else
        cp /usr/lib/ocf/resource.d/vts/check_router.py /usr/lib/ocf/resource.d/vts/check_router.py.template
fi

sed -i.bak "s/XRVR1_NEIGHBORS/\"$xrvr1_bgp_neighbors\"/" /usr/lib/ocf/resource.d/vts/check_router.py
sed -i.bak "s/XRVR2_NEIGHBORS/\"$xrvr2_bgp_neighbors\"/" /usr/lib/ocf/resource.d/vts/check_router.py
sed -i.bak "s/XRVR1_IP/$xrvr1_mgmt_ip/" /usr/lib/ocf/resource.d/vts/check_router.py
sed -i.bak "s/XRVR2_IP/$xrvr2_mgmt_ip/" /usr/lib/ocf/resource.d/vts/check_router.py
sed -i.bak "s/VRF_NAME/$vrf_name/" /usr/lib/ocf/resource.d/vts/check_router.py
sed -i.bak "s/XRVR_USER/$xrvr_user/g" /usr/lib/ocf/resource.d/vts/check_router.py
sed -i.bak "s/XRVR_PASS/$xrvr_pass/g" /usr/lib/ocf/resource.d/vts/check_router.py



###Configuring NCS.conf
ncs_ha=`grep '<!-- <ha><enabled>true</enabled></ha> -->' /etc/ncs/ncs.conf`
if [ "$ncs_ha" != "" ]
then
	sed -i.bak "s/<!-- <ha><enabled>true<\/enabled><\/ha> -->/<ha><enabled>true<\/enabled><\/ha>/" /etc/ncs/ncs.conf

	###Compile Tailf HA Package

	source /etc/profile.d/ncs.sh

	cd /var/opt/ncs/packages/services/tailf-hcc/src
	make clean all



	###Restart NCS after making changes to conf file
	echo "Change made to ncs.conf file. Need to restart ncs"
	service ncs stop
	NCS_RELOAD_PACKAGES=true /etc/init.d/ncs start
fi

### Configuring the NCS HA Cluster
content="Content-Type:application/vnd.yang.data+xml"
cluster_data="<ha-cluster><auto-start>disable</auto-start><members><name>$master_name</name><address>$master_ip</address><role>master</role><transition-enabled>false</transition-enabled></members><members><name>$slave_name</name><address>$slave_ip</address><role>slave</role><transition-enabled>false</transition-enabled><master-capable>true</master-capable></members><master-ip><enable></enable><vip>$vip</vip><member><host>$master_name</host><interface>$master_network_interface</interface></member><member><host>$slave_name</host><interface>$slave_network_interface</interface></member></master-ip></ha-cluster>"

result=`curl -X PUT -u "$ncs_user":"$ncs_pass"  -H "$content" --data "$cluster_data" -s http://127.0.0.1:"$ncs_port"/api/running/ha-cluster`


if [ "$result" != "" ]
then
	echo "Failed to execute: $master_cmd"
	echo "Reason: $result"
fi



activate_cluster_cmd="/usr/bin/curl -X POST -u $ncs_user:$ncs_pass -s http://127.0.0.1:$ncs_port/api/running/ha-cluster/_operations/activate"
result=`$activate_cluster_cmd | grep "activated"`
if [ "$result" = "" ]
then
       	echo "Failed to execute: $activate_cluster_cmd"
       	echo "Reason: $result"
fi

### Configuring corosync.conf file
if [ -e "/etc/corosync/corosync.conf.template" ]
then
        cp /etc/corosync/corosync.conf.template /etc/corosync/corosync.conf
else
        cp /etc/corosync/corosync.conf /etc/corosync/corosync.conf.template
fi

sed -i.bak "s/MASTER_IP/$master_ip/" /etc/corosync/corosync.conf
sed -i.bak "s/SLAVE_IP/$slave_ip/" /etc/corosync/corosync.conf


###Configuring /etc/default/corosync
sed -i.bak "s/START=no/START=yes/" /etc/default/corosync


###Configuring the Pacemaker and Corosync services
update-rc.d pacemaker defaults
update-rc.d corosync defaults


###Update permissions
chmod 755 /usr/lib/ocf/resource.d/vts/vtc_ha


###Configuring the VTC resource agent
if [ -e "/usr/lib/ocf/resource.d/vts/vtc_ha.template" ]
then
	cp /usr/lib/ocf/resource.d/vts/vtc_ha.template /usr/lib/ocf/resource.d/vts/vtc_ha
else
        cp /usr/lib/ocf/resource.d/vts/vtc_ha /usr/lib/ocf/resource.d/vts/vtc_ha.template
fi

sed -i.bak "s/-u admin:admin/-u $ncs_user:$ncs_pass/g" /usr/lib/ocf/resource.d/vts/vtc_ha
sed -i.bak "s/127.0.0.1:NCS_PORT/127.0.0.1:$ncs_port/g" /usr/lib/ocf/resource.d/vts/vtc_ha
sed -i.bak "s/XRVR1/$xrvr1_mgmt_ip/g" /usr/lib/ocf/resource.d/vts/vtc_ha
sed -i.bak "s/XRVR2/$xrvr2_mgmt_ip/g" /usr/lib/ocf/resource.d/vts/vtc_ha
sed -i.bak "s/VTC1/\"$master_name\"/g" /usr/lib/ocf/resource.d/vts/vtc_ha
sed -i.bak "s/VTC2/\"$slave_name\"/g" /usr/lib/ocf/resource.d/vts/vtc_ha

### Create default state file
echo "slave" >/opt/cisco/package/vtc/bin/vtc_ha-vtc_ha.state
echo "slave" >/var/run/vtc_ha-vtc_ha.state #This is just used for recovery purposes


service corosync stop
service pacemaker stop
service corosync start
service pacemaker start

result=`crm status | grep "Current DC: NONE"`
while [ "$result" != "" ]
do
	result=`crm status | grep "Current DC: NONE"`
done


echo "HA cluster is installed"
