# Following # http://blog.aaronorosen.com/implementing-high-availability-instances-with-neutron-using-vrrp/
# Create two vms and enable vrrp, and a shared VIP between them
source openrc admin admin admin

wget http://uec-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
glance image-create --name="Ubuntu-trusty-server" --disk-format=qcow2 --container-format=bare < trusty-server-cloudimg-amd64-disk1.img
nova image-list
nova keypair-add sudakey > sudakey.pem
chmod 600 sudakey.pem

neutron ext-list
neutron net-list
neutron net-create vrrp-net
neutron subnet-create  --name vrrp-subnet --allocation-pool start=10.10.13.2,end=10.10.13.200 vrrp-net 10.10.13.0/24
neutron router-create vrrp-router
neutron router-interface-add vrrp-router vrrp-subnet 
neutron net-list
neutron router-gateway-set vrrp-router public

neutron security-group-rule-create  --protocol icmp vrrp-sec-group
neutron security-group-rule-create  --protocol tcp  --port-range-min 80 --port-range-max 80 vrrp-sec-group
neutron security-group-rule-create  --protocol tcp  --port-range-min 22 --port-range-max 22 vrrp-sec-group

UBUNTU_IMAGE_ID=`nova image-list | grep "Ubuntu-trusty-server" | awk '{print $2}'`
VRRP_NET_ID=`neutron net-list | grep vrrp-net | awk '{print $2}'`
nova boot --num-instances 2 --image $UBUNTU_IMAGE_ID --flavor 2 --nic net-id=$VRRP_NET_ID vrrp-node --security_groups vrrp-sec-group --key-name sudakey

neutron port-create --fixed-ip ip_address=10.10.13.201 --security-group vrrp-sec-group vrrp-net
FIXED_PORT_ID=`neutron port-list -- --network_id=$VRRP_NET_ID | grep 10.10.13.201 | awk '{print $2}'`
neutron floatingip-create --port-id=$FIXED_PORT_ID public

VIP=`neutron floatingip-list | grep $FIXED_PORT_ID | awk '{print $6}'`

VRRP_NET_ID=`neutron net-list | grep vrrp-net | awk '{print $2}'`
neutron port-list -- --network_id=$VRRP_NET_ID
VM1_PORT_ID=`neutron port-list -- --network_id=$VRRP_NET_ID | grep 10.10.13.3 | awk '{print $2}'`
neutron port-update $VM1_PORT_ID --allowed_address_pairs list=true type=dict ip_address=10.10.13.201
VM2_PORT_ID=`neutron port-list -- --network_id=$VRRP_NET_ID | grep 10.10.13.4 | awk '{print $2}'`
neutron port-update $VM2_PORT_ID --allowed_address_pairs list=true type=dict ip_address=10.10.13.201
neutron port-show $VM1_PORT_ID
neutron port-show $VM2_PORT_ID

ROUTER_ID=`neutron router-list | grep vrrp-router | awk '{print $2}'`
sudo ip netns exec qrouter-$ROUTER_ID ssh -i sudakey.pem ubuntu@10.10.13.3

# on each vm
cat /etc/resolv.conf 
nameserver 8.8.8.8

sudo apt-get update
sudo apt-get install keepalived

$ cat  /etc/keepalived/keepalived.conf
vrrp_instance vrrp_group_1 {
 state MASTER
 interface eth0
 virtual_router_id 1
 priority 100
 authentication {
  auth_type PASS
  auth_pass password
 }
 virtual_ipaddress {
  10.10.13.201/24 brd 10.10.13.255 dev eth0
 }
}

sudo service keepalived restart

sudo apt-get install apache2
sudo echo "VRRP-node1" > /var/www/http/index.html


sudo ip netns exec qrouter-$ROUTER_ID ssh -i sudakey.pem ubuntu@10.10.13.4
vrrp_instance vrrp_group_1 {
 state BACKUP
 interface eth0
 virtual_router_id 1
 priority 50
 authentication {
 auth_type PASS
 auth_pass password
}
 virtual_ipaddress {
  10.10.13.201/24 brd 10.10.13.255 dev eth0
 }
}

sudo service keepalived restart

curl $VIP
VRRP-node1

neutron port-update $VM1_PORT_ID --admin_state_up=False

curl $VIP
VRRP-node2

neutron port-update $VM1_PORT_ID --admin_state_up=True
neutron port-update $VM2_PORT_ID --admin_state_up=False
curl $VIP
VRRP-node1
