#!/bin/bash
# Two stacks  with two VMS behind a VIP each. Swap the VIPs. 
STACK1_VIP="10.180.204.155"
STACK2_VIP="10.180.204.158"

STACK1_FIXED_IP=`neutron floatingip-list | grep $STACK1_VIP | awk '{print $4}'`
STACK2_FIXED_IP=`neutron floatingip-list | grep $STACK2_VIP | awk '{print $4}'`

STACK1_FLOATING_IP_ID=`neutron floatingip-list | grep $STACK1_VIP | awk '{print $2}'`
STACK2_FLOATING_IP_ID=`neutron floatingip-list | grep $STACK2_VIP | awk '{print $2}'`

STACK1_FIXED_IP_PORT=`neutron port-list | grep $STACK1_FIXED_IP | awk '{print $2}'`
STACK2_FIXED_IP_PORT=`neutron port-list | grep $STACK2_FIXED_IP | awk '{print $2}'`

neutron floatingip-list | grep $STACK1_FLOATING_IP_ID
neutron floatingip-list | grep $STACK2_FLOATING_IP_ID
neutron floatingip-disassociate $STACK1_FLOATING_IP_ID
neutron floatingip-disassociate $STACK2_FLOATING_IP_ID

neutron floatingip-associate $STACK1_FLOATING_IP_ID $STACK2_FIXED_IP_PORT
neutron floatingip-associate $STACK2_FLOATING_IP_ID $STACK1_FIXED_IP_PORT
neutron floatingip-list | grep $STACK1_FLOATING_IP_ID
neutron floatingip-list | grep $STACK2_FLOATING_IP_ID
