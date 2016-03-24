#!/bin/bash

nova list

VRRP_NET_ID=`neutron net-list | grep vrrp-net | awk '{print $2}'`
echo "VRRP Network ID is $VRRP_NET_ID"

VM1_IP="10.10.13.3"
VM1_PORT_ID=`neutron port-list -- --network_id=$VRRP_NET_ID | grep $VM1_IP | awk '{print $2}'`
echo "Port for VM on $VM1_IP is $VM1_PORT_ID"

VM2_IP="10.10.13.4"
VM2_PORT_ID=`neutron port-list -- --network_id=$VRRP_NET_ID | grep $VM2_IP | awk '{print $2}'`
echo "Port for VM on $VM2_IP is $VM2_PORT_ID"

SHARED_FIXED_IP="10.10.13.201"
FIXED_PORT_ID=`neutron port-list -- --network_id=$VRRP_NET_ID | grep $SHARED_FIXED_IP | awk '{print $2}'`
echo "Port for Shared Fixed IP 10.10.13.201 is $FIXED_PORT_ID"

VIP=`neutron floatingip-list | grep $FIXED_PORT_ID | awk '{print $6}'`
echo "Shared VIP is $VIP"

echo -e '\n===============================================\n'
echo "VM1 UP"
neutron port-update $VM1_PORT_ID --admin_state_up=True
echo "VM2 UP"
neutron port-update $VM2_PORT_ID --admin_state_up=True
sleep 5
neutron port-show $VM1_PORT_ID | grep admin_state_up
neutron port-show $VM2_PORT_ID | grep admin_state_up
echo "This should resolve to VM1"
curl $VIP

echo -e '\n===============================================\n'
echo "VM1 DOWN"
neutron port-update $VM1_PORT_ID --admin_state_up=False
echo "VM2 UP"
neutron port-update $VM2_PORT_ID --admin_state_up=True
sleep 5
neutron port-show $VM1_PORT_ID | grep admin_state_up
neutron port-show $VM2_PORT_ID | grep admin_state_up
echo "This should resolve to VM2"
curl $VIP

echo -e '\n===============================================\n'
echo "VM1 UP"
neutron port-update $VM1_PORT_ID --admin_state_up=True
echo "VM2 DOWN"
neutron port-update $VM2_PORT_ID --admin_state_up=False
sleep 5
neutron port-show $VM1_PORT_ID | grep admin_state_up
neutron port-show $VM2_PORT_ID | grep admin_state_up
echo "This should resolve to VM1"
curl $VIP
