#!/bin/bash

num_veth=$1
action=$2
num_ns=$1

if [[ $action == 'add' ]]
then # if/then branch
    # echo "add $num_ns netns"
    # for((i=1;i<=$num_ns;i++)); do {
    #     sudo ip netns add test-ns-$i &
    # } done

    # echo "add $num_veth veths"
    # for((i=1;i<=$num_veth;i++)); do {
    #     sudo ip link add veth_host-$i type veth peer name veth_pod-$i &
    # } done

    # echo "set ip address"
    START=$(($(date +%s%N)))

    for((i=1;i<=$num_veth;i++)); do {
        ip netns exec test-ns-$i ip addr add 10.244.0.$i/24 dev veth_pod-$i &
        # ip netns exec test-ns-$i ip link set dev veth_pod-$i up &
        # ip link set dev veth_host-$i up &
    } done
    # wait
    # for((i=1;i<=$num_veth;i++)); do {
    #     sudo ip link set dev veth_host-$i up &
    # } done
    wait
    END=$(($(date +%s%N)))
    DIFF=$(( $END - $START ))
    # echo "It took $DIFF ns"
    ts=`echo "scale=2; $DIFF/1000000" | bc`
    echo "It took $ts ms"
else # else branch
    # echo "remove ip address"
    for((i=1;i<=$num_veth;i++)); do {
        ip netns exec test-ns-$i ip addr del 10.244.0.$i/24 dev veth_pod-$i &
        # ip netns exec test-ns-$i ip link set dev veth_pod-$i down &
        # ip link set dev veth_host-$i down &
    } done
    wait
    # for((i=1;i<=$num_veth;i++)); do {
    #     sudo ip link delete veth_host-$i &
    # } done

    # echo "delete $num_ns netns"
    # for((i=1;i<=$num_ns;i++)); do {
    #     sudo ip netns delete test-ns-$i &
    # } done
fi

# ip link show