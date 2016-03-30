from keystoneauth1 import loading
from keystoneauth1 import session
from neutronclient.v2_0 import client as neutronclient
from novaclient import client as novaclient

loader = loading.get_plugin_loader('password')
auth = loader.load_from_options(
    auth_url="http://localhost:5000/v2.0",
    username="admin",
    password="admin",
    tenant_name="admin"
    )
session = session.Session(auth=auth)
neutron = neutronclient.Client(session=session)
nova = novaclient.Client("2.1", session=session)

instance1_id="46357f54-1141-4ff4-a214-b57871a67a4e"
instance1=nova.servers.get(instance1_id)
instance1_ip = instance1.networks['vrrp-net'][0]

instance2_id='7591651c-c916-4d81-8e66-1184bbc2afe6'
instance2=nova.servers.get(instance2_id)
instance2_ip = instance2.networks['vrrp-net'][0]

vrrp_net_id='e099e670-12ba-4174-9b16-bdc58e2d15dc'
ext_net_id='5fce8f30-4a6c-4edc-8889-661ca1666738'
instance1_port =''
instance2_port = ''
for port in neutron.list_ports({'device_id': instance1_id, 'network_id': vrrp_net_id}).get('ports'):
    for ips in port.get('fixed_ips'):
        if ips.get('ip_address') == instance1_ip:
            instance1_port = port.get('id')
            print instance1_port
        elif ips.get('ip_address') == instance2_ip:
            instance2_port = port.get('id')
            print instance2_port
print "Instance %s is on port %s " % (instance1_ip, instance1_port)
print "Instance %s is on port %s " % (instance2_ip, instance2_port)

body_value = {
  "port": {
    "name": "my_fixedip_port",
    "network_id": vrrp_net_id #vrrp-net
  }
}
port = neutron.create_port(body=body_value)
fixedip_port_id=port['port']['id']
fixedip=port['port']['fixed_ips'][0]['ip_address']
print "Port id is %s " % fixedip_port_id
print "Fixed ip on the port is %s " % fixedip

floatingip_params={
    'floatingip': {
      'floating_network_id': ext_net_id,
      'port_id': fixedip_port_id
    }
  }
floatingip=neutron.create_floatingip(floatingip_params)
print floatingip
floatingip_id=floatingip['floatingip']['id']
floatingip=floatingip['floatingip']['floating_ip_address']
print "Floatingip id is %s " % floatingip_id
print "Floatingip is %s " % floatingip

entry = {'ip_address':fixedip}
allowed_address_pairs = []
allowed_address_pairs.append(dict(entry))
body = {
    "port": {
      "allowed_address_pairs": allowed_address_pairs
      }
    }
neutron.update_port(instance1_port,body)
neutron.update_port(instance2_port, body)
