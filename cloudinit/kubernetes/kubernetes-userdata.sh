#!/bin/bash
apt-get update
apt-get install -y python-dev
apt-get install -y python-pip
easy_install pip
apt-get install python-novaclient
pip install rackspace-novaclient

export OS_USERNAME=privateclouddevs
export OS_PASSWORD=0e688a460988337e0e759524a2ccfc33
export OS_TENANT_NAME=714479
export OS_AUTH_SYSTEM=rackspace
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
export OS_REGION_NAME=IAD
export OS_NO_CACHE=1

cat > ~/openrc << EOF
export OS_USERNAME=$OS_USERNAME
# api key actually
export OS_PASSWORD=$OS_PASSWORD
export OS_TENANT_NAME=$OS_TENANT_NAME
export OS_AUTH_SYSTEM=$OS_AUTH_SYSTEM
export OS_AUTH_URL=$OS_AUTH_URL
export OS_REGION_NAME=$OS_REGION_NAME
export OS_NO_CACHE=$OS_NO_CACHE
EOF
nova list

pip install swiftly
cat > ~/swiftly.conf << EOF
[swiftly]
auth_url = $OS_AUTH_URL
auth_user = $OS_USERNAME
auth_key = $OS_PASSWORD
auth_tenant = $OS_TENANT_NAME
region = $OS_REGION_NAME
EOF

swiftly -A $OS_AUTH_URL -U $OS_USERNAME -K $OS_PASSWORD -T $OS_TENANT_NAME
--region=$OS_REGION_NAME get

# Install docker
apt-get -y install linux-image-generic-lts-raring
linux-headers-generic-lts-raring curl
curl -s https://get.docker.io/ubuntu/ | sudo sh

nova keypair-delete id_kubernetes

# Get kubernetes from source
cd ~
apt-get install -y git
git clone https://github.com/GoogleCloudPlatform/kubernetes
cd kubernetes
git checkout v0.19.0

# Build and run Kubernetes
export KUBERNETES_PROVIDER=rackspace
bash hack/dev-build-and-up.sh

