neutron net-create --shared --router:external=true floating-net

neutron subnet-create floating-net --gateway 10.10.10.1 10.10.10.0/24 --name floating-subnet --enable_dhcp false

neutron net-external-list

nrutron net-list

nova list

neutron port-list 

neutron port-list  -- --device_id=$intance_id

neutron floatingip-create  --port-id $instance_port_id floating-net

neutron floatingip-list

# Creating another floating-ip and associate it to an instance
neutron floatingip-create floating-net
neutron floatingip-associate $floatingip_id $instance_port_id

ping $instance_floating_ip
