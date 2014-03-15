neutron router-create router

neutron router-gateway-set $router_id $public_net_id

neutron router-interface-add $router_id $private_subnet1_id

neutron router-interface-add $router_id $private_subnet2_id

# might need to set the gateway on the private_subnet too

# fix the gateway within the instance
# route del default gw $ip_bad
# route add default gw $ip_good

