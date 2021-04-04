#!/bin/bash

# ns creation

declare -a NUM=(1 2 4 8 10 20 30 40 50 60 70 80 90 100)
loop=10

for num in ${NUM[@]}
do
    echo "Profiling $num instance(s)"
    for((i=1;i<=$loop;i++)); do {
        ./ns_creation_test.sh $num add && wait && ./ns_creation_test.sh $num del
    } done
    wait
    ./ns_creation_test.sh $num add
    wait
    for((i=1;i<=$loop;i++)); do {
        ./veth_creation_test.sh $num add && wait && ./veth_creation_test.sh $num del
    } done
    wait
    ./veth_creation_test.sh $num add
    wait
    for((i=1;i<=$loop;i++)); do {
        ./veth_movement_test.sh $num add && wait && ./veth_movement_test.sh $num del
    } done
    wait
    ./veth_movement_test.sh $num add
    wait
    for((i=1;i<=$loop;i++)); do {
        ./set_veth_ip_test.sh $num add && wait && ./set_veth_ip_test.sh $num del
    } done
    wait
    ./veth_creation_test.sh $num del
    ./ns_creation_test.sh $num del
done