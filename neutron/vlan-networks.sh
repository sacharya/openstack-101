neutron net-create --provider:physical_network=ph-bond0 --provider:network_type=vlan --provider:segmentation_id=500 --shared  MY_NET

neutron subnet-create MY_NET 172.25.1.0/24 --name MY_SUBNET --no-gateway --host-route destination=0.0.0.0/0,nexthop=172.25.1.13 --allocation-pool start=172.25.1.11,end=172.25.1.20

