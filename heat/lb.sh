#!/bin/bash
source lbrc
heat stack-delete $STACK_NAME
sleep 20
heat stack-create $STACK_NAME --template-file=$TEMPLATE_FILE -P app_name="$APP_NAME" -P image="$IMAGE_ID" -P listeners="$LISTENERS" -P keyname="$KEY_NAME" -P public_network="$PUBLIC_NET" -P private_network="$PRIVATE_NET" -P algorithm="$ALGORITHM" -P flavor="$FLAVOR_ID" -P backend_servers="$BACKEND_SERVERS"

#watch heat stack-show $STACK_NAME
#heat stack-create $LB_NAME --template-file haproxy-heat-template.yml --parameters "app_name=$APP_NAME;image=$IMAGE_ID;keyname=$KEY_NAME;flavor=$FLAVOR_ID;private_network=$PRIVATE_NET;public_network=$PUBLIC_NET;algorithm=$ALGORITHM;backend_servers=$BACKEND_SERVERS;listeners=$LISTENERS"
