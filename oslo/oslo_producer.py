from oslo_config import cfg
from oslo_context import context
import oslo_messaging
from oslo_utils import timeutils

import logging

logging.basicConfig()
log = logging.getLogger()

log.addHandler(logging.StreamHandler())
log.setLevel(logging.INFO)

transport_url ='rabbit://ceilometer:passwd@127.0.0.1:5672//ceilometer'
transport = oslo_messaging.get_transport(cfg.CONF, transport_url)

driver = 'messagingv2'

notifier = oslo_messaging.Notifier(transport, driver=driver,
    publisher_id='ceilometermiddleware', topic='notifications')

notifier.info({'some': 'context'}, 'test_event', {'key': 'value'})
