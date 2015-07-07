if [ ! -f sahara-juno-hdp-2.0.6-centos-6.5.qcow2 ]; then
  wget http://sahara-files.mirantis.com/sahara-juno-hdp-2.0.6-centos-6.5.qcow2
fi
glance image-create --name=sahara-juno-hdp-2.0.6-centos-6.5.qcow2 --disk-format=qcow2 --container-format=bare < ./sahara-juno-hdp-2.0.6-centos-6.5.qcow2

IMAGE_ID=`nova image-list | grep "sahara-juno-hdp-2.0.6-centos-6.5.qcow2" | cut -d ' ' -f 2`
sahara image-register --id $IMAGE_ID --username cloud-user
sahara image-add-tag --id $IMAGE_ID --tag hdp
sahara image-add-tag --id $IMAGE_ID --tag 2.0.6

sahara node-group-template-create --json hdp/node_group_template_master.json
sahara node-group-template-create --json hdp/node_group_template_worker.json
sahara node-group-template-list


sahara cluster-template-create --json hdp/cluster_template.json
sahara cluster-template-list

nova keypair-add stack > stack.pem
chmod 600 stack.pem

NET_ID=`neutron net-list | grep "private" | cut -d ' ' -f 2`
CLUSTER_TEMPLATE_ID=`sahara cluster-template-list | grep "dp-cluster" | cut -d ' ' -f 2`
cat >> hdp/cluster_create.json << EOF
{
  "name": "cluster-1",
  "plugin_name": "hdp",
  "hadoop_version": "2.0.6",
  "cluster_template_id": "$CLUSTER_TEMPLATE_ID",
  "user_keypair_id": "stack",
  "default_image_id": "$IMAGE_ID"
  "neutron_management_network": "$NET_ID"
}
EOF

sahara cluster-create --json hdp/cluster_create.json
