nova boot --image $image_id --flavor 2 --key-name keyname --nic net-id=$MY_NET_ID myvm1
  
ip netns

ip netns exec $qdhcp_id ssh $ip -i my.key
