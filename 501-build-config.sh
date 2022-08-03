#!/bin/bash

#  Creating flame config
cd FederatedLearning/latestFlame/flame/fiab
./build-config.sh

cd FederatedLearning/latestFlame/flame
make install

export PATH="$HOME/.flame/bin:$PATH"
