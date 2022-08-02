#!/bin/bash
export PATH="$HOME/.flame/bin:$PATH"

flamectl create design medmnist -d "MedMNIST" --insecure
flamectl create schema ./flame/examples/medmnist/medschema.json --design medmnist --insecure
flamectl create code ./flame/examples/medmnist/medmnist.zip --design medmnist --insecure

for i in {1..10}
do
    flamectl create dataset ./flame/examples/medmnist/dataset$i.json --insecure
done

readarray -t datasetIds <<< "$(flamectl get datasets --insecure | grep MedMNIST | awk '{print $2}'  | awk 'NR%2==1')"
cat job.json | jq '.dataSpec.fromSystem |= []' | sponge job.json

i=0
for datasetId in "${datasetIds[@]}"
do
  cat job.json | jq --arg datasetId $datasetId --argjson i "$i" '.dataSpec.fromSystem[$i] |= . + $datasetId' | sponge job.json
  i=$((i+1))
done

flamectl create job job.json --insecure
#flamectl start job 62e351821066002808f0adef --insecure
#printf '%s\n' "${datasetIds[@]}"