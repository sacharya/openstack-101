from nova import compute
from nova.api.openstack import extensions

class UtsaserverController(object):
    """the Utsaservers API controller """

    def __init__(self):
        self.compute_api = compute.API()

    def index(self,req, deleted=True):
        """return a list of servers """
        context = req.environ['nova.context']
        search_opts = {'deleted': deleted}
        instances = self.compute_api.get_all(context, search_opts=search_opts)
        servers = []

        for instance in instances:
            server = {'id': instance.get('uuid'),
                      'local_id': instance.get('id'),
                      'name': instance.get('display_name'),
                      'status': instance.get('vm_state'),
                      'host': instance.get('host'),
                      'deleted': instance.get('deleted'),
                      'deleted_at':instance.get('deleted_at'),
                      'tenant_id': instance.get('project_id')}
            servers.append(server)
        return {'servers': servers}

    def create(self,req, body):
        """create a server """
        pass
    def show(self,req, id):
        """ read the details of a server given its id"""
        pass
    def update(self, req, id, body):
        """updates a server given its id and content"""
        pass
    def delete(self,req, id):
        """removes a server given its id"""
        pass

class Utsaservers(extensions.ExtensionDescriptor):
    """ExtensionDescriptor implementation"""
    name = "Utsaservers"
    alias ="os-utsaservers"
    namespace = "http://docs.openstack.org/compute/ext/utsaservers/api/v1.1"
    updated = "2011-12-23T00:00:00+00:00"

    def get_resources(self):
        """ register the new Utsaservers RESTful resource """
        resources = [extensions.ResourceExtension('os-utsaservers',UtsaserverController())]
        return resources
