#nova keypair-add sudakey > sudakey.pem
IMAGE_ID=`nova image-list | grep "Ubuntu 14.04 LTS (Trusty Tahr) (PV)" | awk '{print $2}'`
FLAVOR_ID="performance1-4"
nova boot --image $IMAGE_ID --flavor $FLAVOR_ID --key-name sudakey --user-data devstack-userdata.sh --config-drive true suda-devstack1

#nova boot --image 1f097471-f0f4-4c3b-ac24-fdb1d897b8c0 --flavor onmetal-io1 --key-name sudakey --user-data devstack-userdata-ironic.sh suda-devstack1
