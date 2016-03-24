# Instances on two subnets on a private tenant network talking to each other
source devstack/openrc admin admin admin
neutron net-list
neutron net-create 'test1-network'
neutron subnet-create e3eed5bc-23b6-4e52-873f-538dc2302be3 10.10.11.0/24 --name test1-subnet --enable-dhcp --ip-version 4 --gateway '10.10.11.1'
neutron router-create test0-router
neutron net-list
neutron router-gateway-set <router id> <external network id>
neutron router-gateway-set 12bbd282-4c8e-4036-90b3-3cab6bd08594 5fce8f30-4a6c-4edc-8889-661ca1666738
neutron router-interface-add <router id> <subnet id>
neutron router-interface-add 12bbd282-4c8e-4036-90b3-3cab6bd08594 117552d2-225f-4f0f-8576-3f34eedd68da

neutron subnet-create e3eed5bc-23b6-4e52-873f-538dc2302be3 10.10.12.0/24 --name test2-subnet --enable-dhcp --ip-version 4 --gateway '10.10.12.1'
neutron router-interface-add 12bbd282-4c8e-4036-90b3-3cab6bd08594 901c6a22-899d-4177-9b49-35747816e1f2

neutron port-create --fixed-ip subnet_id=$SUBNET_ID,ip_address=$IP $NET_ID
neutron port-create --fixed-ip subnet_id=117552d2-225f-4f0f-8576-3f34eedd68da e3eed5bc-23b6-4e52-873f-538dc2302be3
nova boot --image a7769cad-8900-486e-91a6-500054ffff49 --flavor m1.tiny --nic port-id=3c8e2473-8c76-40c6-b20b-8303104adaab test11

neutron port-create --fixed-ip subnet_id=901c6a22-899d-4177-9b49-35747816e1f2 e3eed5bc-23b6-4e52-873f-538dc2302be3
nova boot --image a7769cad-8900-486e-91a6-500054ffff49 --flavor m1.tiny --nic port-id=ab5de5ef-b0f3-46a6-9e63-f59a92b90d78 test12
ip netns
neutron router-list
sudo ip netns exec qrouter-12bbd282-4c8e-4036-90b3-3cab6bd08594 ssh cirros@10.10.11.3
