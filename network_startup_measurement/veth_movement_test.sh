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

    echo "move $num_veth veths"
    START=$(($(date +%s%N)))

    for((i=1;i<=$num_veth;i++)); do {
        sudo ip link set veth_pod-$i netns test-ns-$i &
    } done
    
    END=$(($(date +%s%N)))
    DIFF=$(( $END - $START ))
    echo "It took $DIFF ns"
else # else branch
    echo "delete $num_veth veths"
    for((i=1;i<=$num_veth;i++)); do {
        sudo ip link delete veth_host-$i &
    } done

    echo "delete $num_ns netns"
    for((i=1;i<=$num_ns;i++)); do {
        sudo ip netns delete test-ns-$i &
    } done
fi

# ip link show