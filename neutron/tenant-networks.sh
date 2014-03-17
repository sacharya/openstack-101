neutron net-create MY_NET

neutron subnet-create MY_NET 172.25.1.0/24 --name MY_SUBNET --no-gateway --host-route destination=0.0.0.0/0,nexthop=172.25.1.13 --allocation-pool start=172.25.1.11,end=172.25.1.20 --dns-nameservers list=true 8.8.8.7 8.8.8.8

