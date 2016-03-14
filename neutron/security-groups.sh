# http://blog.aaronorosen.com/building-a-multi-tier-application-with-openstack/

neutron security-group-rule-create --protocol icmp --direction ingress --remote-ip-prefix 0.0.0.0/0 default
neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress --remote-ip-prefix 0.0.0.0/0 default

neutron security-group-create ssh
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 ssh
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp ssh

neutron security-group-create database

neutron security-group-create web
neutron security-group-rule-create --direction ingress --protocol TCP --port-range-min 80 --port-range-max 80 web

neutron security-group-create database
# Allow database severs to be accessed from web servers
neutron security-group-rule-create --direction ingress --protocol TCP --port-range-min 3306 --port-range-max 3306 --remote-group-id web database

# Allow servers with ssh enabled to ssh into database servers and webservers
neutron security-group-rule-create --direction ingress --protocol TCP --port-range-min 22 --port-range-max 22 --remote-group-id ssh database
neutron security-group-rule-create --direction ingress --protocol TCP --port-range-min 22 --port-range-max 22 --remote-group-id ssh web

# Add security group during instance creation
nova boot --image $image_id --flavor $flavor_id --nic net-id=$private_net_id --key_name mykey --security_groups ssh server1
nova boot --image $image_id --flavor $flavor_id --nic net-id=$private_net_id --key_name mykey --security_groups web webserver1
nova boot --image $image_id --flavor $flavor_id --nic net-id=$private_net_id --key_name mykey --security_groups web webserver2
nova boot --image $image_id --flavor $flavor_id --nic net-id=$private_net_id --key_name mykey --security_groups database mysql

# Add security group to an existing instance
nova add-secgroup $instance_id default
