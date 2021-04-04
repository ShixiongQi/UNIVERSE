#!/bin/bash

num_ns=$1
action=$2
# echo $num_ns
# echo $action

if [[ $action == 'add' ]]
then # if/then branch
    # echo "add $num_ns netns"
    START=$(($(date +%s%N)))
    for((i=1;i<=$num_ns;i++)); do {
        sudo ip netns add test-ns-$i
    } done
    wait
    END=$(($(date +%s%N)))
    DIFF=$(( $END - $START ))
    # echo "It took $DIFF ns"
    ts=`echo "scale=2; $DIFF/1000000" | bc`
    echo "Serialization took $ts ms"
else # else branch
    # echo "delete $num_ns netns"
    for((i=1;i<=$num_ns;i++)); do {
        sudo ip netns delete test-ns-$i &
    } done
    wait
fi

# sudo ip netns list