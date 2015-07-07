#nova keypair-add sudakey > sudakey.pem
IMAGE_ID=`nova image-list | grep "Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)" | awk '{print $2}'`
FLAVOR_ID="performance1-8"
nova boot --image $IMAGE_ID --flavor $FLAVOR_ID --user-data kubernetes-userdata.sh --config-drive true suda-k8s

#nova boot --image 1f097471-f0f4-4c3b-ac24-fdb1d897b8c0 --flavor onmetal-io1 --key-name sudakey --user-data devstack-userdata-ironic.sh suda-devstack1
