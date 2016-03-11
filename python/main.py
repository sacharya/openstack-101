from keystoneauth1 import loading
from keystoneauth1 import session
from cinderclient import client as cinderclient
from novaclient import client as novaclient


loader = loading.get_plugin_loader('password')
auth = loader.load_from_options(
      auth_url="http://localhost:5000/v2.0",
      username="demo",
      password="admin",
      project_id="9fdf63e7200f4d608d551fd5990f8593"
    )
session = session.Session(auth=auth)
version="2.1"
nova = novaclient.Client(version, session=session)

# create server
name="testvm"
meta = {}
instance = nova.servers.create(name=name, image =
"fcc1484b-a560-48d2-96bf-f4c41d9220bd", flavor="1", meta=meta)
tags = {"some": "metadata"}
sleep 20
nova.servers.set_meta(instance, tags)
instance.delete()

# list server details
servers = nova.servers.list()
for server in servers:
    print "Server is %s " % dir(server)
      for volume in server._info['os-extended-volumes:volumes_attached']:
              print "Volume is %s " % volume['id']

              # list volume
              cinder = cinderclient.Client("2", session=session)
              volume = cinder.volumes.create(name="testvol", size=1,
                  metadata={})
              print "Created volume %s " % volume

              cinder.volumes.delete(volume.id)
