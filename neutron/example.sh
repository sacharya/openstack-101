source openrc admin admin admin
# grant external access to vms
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Use the source ip of the interface the packet is going out from
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -t nat -L -n -v

neutron net-list

neutron net-create 'test-network'

neutron subnet-create \
  $private_net_id \
  10.10.10.0/24 \
  --name test-subnet \
  --enable-dhcp --ip0version 4 \
  --gateway '10.10.10.1'

# In one cae, the subnet was not created by default on the public net, and I
# had to create it myself
#neutron subnet-create public --name public-subnet --gateway 172.24.4.1 172.24.4.0/24 --enable_dhcp false

neutron router-create test-router

# set external gateway of router
neutron router-gateway-set <router id> <external network id>

# add private subnet to routter interface
neutron router-interface-add <router id> <subnet id>

nova boot --image $image_id \
  --flavor $flavor_id \
  --nic net-id=$test_network_id \
  test

neutron net-list

ip netns
# get the qrouter id for the private network

nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

sudo ip netns exec $qrouter-id ssh cirros@test_ip

ping 8.8.8.8

exit

neutron port-list

neutron port-list  -- --device_id=$intance_id
 
neutron floatingip-create  --port-id $instance_port_id public
 
neutron floatingip-list

# ALternatively, you can do this too
#neutron floatingip-create public
#neutron floatingip-associate $floatingip_id $instance_port_id
 
ping $instance_floating_ip

