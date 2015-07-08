if [ ! -f sahara-juno-hdp-2.0.6-centos-6.5.qcow2 ]; then
  wget http://sahara-files.mirantis.com/sahara-juno-hdp-2.0.6-centos-6.5.qcow2
fi
function cleanup {
  glance image-delete sahara-juno-hdp-2.0.6-centos-6.5.qcow2
  CLUSTER_ID=`sahara cluster-list | grep "hdp-cluster-1" | cut -d ' ' -f 4`
  sahara cluster-delete --id $CLUSTER_ID

  CLUSTER_TEMPLATE_ID=`sahara cluster-template-list | grep "hdp-cluster-template" | cut -d ' ' -f 5`
  sahara cluster-template-delete --id $CLUSTER_TEMPLATE_ID

  NODE_GROUP_MASTER_TEMPLATE_ID=`sahara node-group-template-list | grep "hdp-master"| cut -d ' ' -f 4`
  NODE_GROUP_WORKER_TEMPLATE_ID=`sahara node-group-template-list | grep "hdp-worker"| cut -d ' ' -f 4`
  sahara node-group-template-delete --id $NODE_GROUP_MASTER_TEMPLATE_ID
  sahara node-group-template-delete --id $NODE_GROUP_WORKER_TEMPLATE_ID
}

cleanup

glance image-create --name=sahara-juno-hdp-2.0.6-centos-6.5.qcow2 --disk-format=qcow2 --container-format=bare < ./sahara-juno-hdp-2.0.6-centos-6.5.qcow2

IMAGE_ID=`nova image-list | grep "sahara-juno-hdp-2.0.6-centos-6.5.qcow2" | cut -d ' ' -f 2`
sahara image-register --id $IMAGE_ID --username cloud-user
sahara image-add-tag --id $IMAGE_ID --tag hdp
sahara image-add-tag --id $IMAGE_ID --tag 2.0.6

sahara node-group-template-create --json hdp/node_group_master_template.json
sahara node-group-template-create --json hdp/node_group_worker_template.json
sahara node-group-template-list

NODE_GROUP_MASTER_TEMPLATE_ID=`sahara node-group-template-list | grep "hdp-master"| cut -d ' ' -f 4`
NODE_GROUP_WORKER_TEMPLATE_ID=`sahara node-group-template-list | grep "hdp-worker"| cut -d ' ' -f 4`
cat > hdp/cluster_template.json << EOF
{
  "name": "hdp-cluster-template",
  "plugin_name": "hdp",
  "hadoop_version": "2.0.6",
  "node_groups": [
    {
      "name": "master",
      "node_group_template_id": "$NODE_GROUP_MASTER_TEMPLATE_ID",
      "count": 1
    },
    {
      "name": "workers",
      "node_group_template_id": "$NODE_GROUP_WORKER_TEMPLATE_ID",
      "count": 3
    }
  ]
}
EOF
sahara cluster-template-create --json hdp/cluster_template.json
sahara cluster-template-list

nova keypair-delete stack
nova keypair-add stack > stack.pem
chmod 600 stack.pem

NET_ID=`neutron net-list | grep "private" | cut -d ' ' -f 2`
CLUSTER_TEMPLATE_ID=`sahara cluster-template-list | grep "hdp-cluster-template" | cut -d ' ' -f 4`
cat > hdp/cluster_create.json << EOF
{
  "name": "hdp-cluster-1",
  "plugin_name": "hdp",
  "hadoop_version": "2.0.6",
  "cluster_template_id": "$CLUSTER_TEMPLATE_ID",
  "user_keypair_id": "stack",
  "default_image_id": "$IMAGE_ID",
  "neutron_management_network": "$NET_ID"
}
EOF

sahara cluster-create --json hdp/cluster_create.json
