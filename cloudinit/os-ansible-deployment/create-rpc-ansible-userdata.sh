#!/bin/bash

apt-get update
apt-get install -y vim git at

cat <<'EOF' >> /root/init.sh
#!/bin/bash
{
  set -x

  cd /root
  git clone https://github.com/sacharya/os-ansible-deployment 
  cd os-ansible-deployment
  git checkout install-sahara-master

  export DEPLOY_SWIFT=no
  export RUN_TEMPEST=no

  ./scripts/gate-check-commit.sh

} 2>&1 >> /root/init-log
EOF

chmod o+x /root/init.sh
at -f /root/init.sh now + 1 minute
