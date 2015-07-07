nova delete suda-rpc-ansible
nova keypair-delete sudakey
nova keypair-add sudakey > sudakey.pem
chmod 600 sudakey.pem
cp /dev/null ~/.ssh/known_hosts
#IMAGE_ID=`nova image-list | grep "OnMetal - Ubuntu 14.04 LTS (Trusty Tahr)" | awk '{print $2}'`
#FLAVOR_ID="onmetal-compute1"
IMAGE_ID=`nova image-list | grep "Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)" | awk '{print $2}'`
#FLAVOR_ID="8"
FLAVOR_ID="performance1-8"
nova boot --image $IMAGE_ID --flavor $FLAVOR_ID --key-name sudakey --user-data create-rpc-ansible-userdata.sh --config-drive true suda-rpc-ansible

#nova boot --image 1f097471-f0f4-4c3b-ac24-fdb1d897b8c0 --flavor onmetal-io1 --key-name sudakey --user-data devstack-userdata-ironic.sh suda-devstack1
