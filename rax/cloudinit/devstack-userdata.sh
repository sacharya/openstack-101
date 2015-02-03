#!/bin/bash

# Source: https://github.com/absalon-james/devstork

useradd stack -d /home/stack -s /bin/bash -g sudo
mkdir -p /home/stack
chown -R stack /home/stack
echo "# User rules for root" >> /etc/sudoers.d/90-stack-user
echo "stack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-stack-user
chmod 440 /etc/sudoers.d/90-stack-user

apt-get update
apt-get install -y git at

cat <<'EOF' >> /home/stack/init.sh
#!/bin/bash
{
  set -x

  cd /home/stack
  ssh-keygen -t rsa -N "" -f /home/stack/.ssh/id_rsa

  git clone https://github.com/openstack-dev/devstack.git
  cd devstack

  # Write contents of local.conf file
  echo "[[local|localrc]]" >> local.conf
  echo "ADMIN_PASSWORD=secrete" >> local.conf
  echo "DATABASE_PASSWORD=\$ADMIN_PASSWORD" >> local.conf
  echo "RABBIT_PASSWORD=\$ADMIN_PASSWORD" >> local.conf
  echo "SERVICE_PASSWORD=\$ADMIN_PASSWORD" >> local.conf
  echo "SERVICE_TOKEN=c324b782-43a9-24c1-c2c4-d513c4041b42" >> local.conf
  echo "disable_service n-net" >> local.conf
  echo "enable_service q-svc" >> local.conf
  echo "enable_service q-agt" >> local.conf
  echo "enable_service q-dhcp" >> local.conf
  echo "enable_service q-l3" >> local.conf
  echo "enable_service q-meta" >> local.conf
  echo "enable_service neutron" >> local.conf
  HOST_IP=$(ifconfig eth0 | awk '/inet addr/{print substr($2,6)}') 
  echo "HOST_IP=$HOST_IP" >> local.conf

  ./stack.sh

  #source openrc admin admin secrete

  export OS_USERNAME=admin
  export OS_TENANT_NAME=admin
  export OS_PASSWORD=secrete
  export OS_AUTH_URL=http://$HOST_IP:5000/v2.0

  # add keypair
  nova keypair-add heat-key --pub-key /home/stack/.ssh/id_rsa.pub

  # add ssh and ping to default security rules
  nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
  nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
  glance image-create --name "Ubuntu 12.04 software config" --disk-format qcow2 --location http://ab031d5abac8641e820c-98e3b8a8801f7f6b990cf4f6480303c9.r33.cf1.rackcdn.com/ubuntu-softwate-config.qcow2 --is-public True --container-format bare
} 2>&1 >> /home/stack/init-log
EOF

chmod o+x /home/stack/init.sh
chown stack /home/stack/init.sh
su stack -c "at -f /home/stack/init.sh now + 1 minute"
