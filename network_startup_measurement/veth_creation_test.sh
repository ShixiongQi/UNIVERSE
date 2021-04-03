#!/bin/bash

num_veth=$1
action=$2
# echo $num_ns
# echo $action

if [[ $action == 'add' ]]
then # if/then branch
    echo "add $num_veth veths"
    START=$(($(date +%s%N)))

    for((i=1;i<=$num_veth;i++)); do {
        sudo ip link add veth_host-$i type veth peer name veth_pod-$i &
    } done
    
    END=$(($(date +%s%N)))
    DIFF=$(( $END - $START ))
    echo "It took $DIFF ns"
else # else branch
    echo "delete $num_veth veths"
    for((i=1;i<=$num_veth;i++)); do {
        sudo ip link delete veth_host-$i &
    } done
fi

# ip link show