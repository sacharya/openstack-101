from keystoneauth1 import loading
from keystoneauth1 import session
from cinderclient import client as cinderclient
from novaclient import client as novaclient
from keystoneclient.v3 import client as keystoneclient
from heatclient import client as heatclient
from pprint import pprint

loader = loading.get_plugin_loader('password')
auth = loader.load_from_options(
    auth_url="http://localhost:5000/v2.0",
    username="admin",
    password="admin",
    tenant_name="admin"
    )
session = session.Session(auth=auth)

# Doesnt work without the service type
heat = heatclient.Client(version="1", service_type = 'orchestration', session=session)
for stack in heat.stacks.list():
  print stack
  print "\n"

keystone = keystoneclient.Client(session=session)
print keystone.projects.list()
print keystone.services.list()
for service in keystone.services.list():
  print service
  print "\n"
for endpoint in  keystone.endpoints.list():
  print endpoint
  print "\n"
version="2.1"
nova = novaclient.Client(version, session=session)

# create server
name="testvm-attachment"
meta = {}
nics = [{'net-id': 'c0acc95e-cff0-4405-945f-0e7e449631e1'}]
instance = nova.servers.create(name=name,
    image = "f4d1f0e2-6046-446a-a580-787d5bc00311",
    flavor="9215a033-425e-4591-8f17-e1c00a221a1b",
    key_name="suda-keypair", nics=nics,
    meta=meta)
tags = {"some": "metadata"}
import time
time.sleep(10)
nova.servers.set_meta(instance, tags)
#instance.delete()

# list server details
servers = nova.servers.list()
for server in servers:
  print "Server is %s " % dir(server)
for volume in server._info['os-extended-volumes:volumes_attached']:
  print "Volume is %s " % volume['id']

# list volume
cinder = cinderclient.Client("2", session=session)
volume = cinder.volumes.create(name="testvol", size=3, metadata={})
print "Created volume %s " % volume
time.sleep(20)
volume=cinder.volumes.get(volume.id)
print volume
print "Attach command"
print "nova volume-attach %s %s %s" %(instance.id, volume.id, "/dev/vdc")
print "Attaching volume"
nova.volumes.create_server_volume(instance.id, volume.id, "/dev/vdc")
time.sleep(20)
volume=cinder.volumes.get(volume.id)
pprint (vars(volume))
print "Detaching volume"
nova.volumes.delete_server_volume(instance.id, volume.id)
time.sleep(20)
print "Get volume"
volume=cinder.volumes.get(volume.id)
pprint (vars(volume))
print "Deleting volume"
cinder.volumes.delete(volume.id)
print "Delete instance"
instance.delete()
#res = cinder.volumes.attach(volume,instance.id, "/dev/vdc")
#print res
#time.sleep(20)
#cinder.volumes.delete(volume.id)
