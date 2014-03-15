neutron net-create --shared --router:external=true floating-net

neutron subnet-create floating-net 10.10.10.0/24 --name floating-subnet --enable_dhcp false

neutron net-external-list

nrutron net-list

nova list

neutron port-list 

neutron floatingip-list

neutron floatingip-associate $floatingip_id $instance_port_id

ping $instance_floating_ip
