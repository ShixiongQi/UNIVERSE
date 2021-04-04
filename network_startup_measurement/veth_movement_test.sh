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
    wait
    # echo "moving..."
    # :
    # :
    END=$(($(date +%s%N)))
    DIFF=$(( $END - $START ))
    # echo "It took $DIFF ns"
    ts=`echo "scale=2; $DIFF/1000000" | bc`
    echo "It took $ts ms"
else # else branch
    # echo "delete $num_veth veths"
    # for((i=1;i<=$num_veth;i++)); do {
    #     sudo ip link delete veth_host-$i &
    # } done

    # echo "delete $num_ns netns"
    # for((i=1;i<=$num_ns;i++)); do {
    #     sudo ip netns delete test-ns-$i &
    # } done
    START=$(($(date +%s%N)))
    for((i=1;i<=$num_ns;i++)); do {
        # sudo ip netns delete test-ns-$i &
        sudo ip netns exec test-ns-$i ip link set veth_pod-$i netns 1 &
    } done
    wait
    echo "deleting..."
    # :
    END=$(($(date +%s%N)))
    DIFF=$(( $END - $START ))
    ts=`echo "scale=2; $DIFF/1000000" | bc`
    echo "delete latency $ts ms"
fi

# ip link show