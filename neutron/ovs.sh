for br in `ovs-vsctl list-br`; do ovs-ofctl show $br; done

for br in `ovs-vsctl list-br`; do ovs-vsctl list-ports $br; done

for br in `ovs-vsctl list-br`; do ovs-ofctl dump-flows $br; done
