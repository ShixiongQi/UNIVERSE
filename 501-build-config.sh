#!/bin/bash

#  Creating flame config
cd FederatedLearning/latestFlame/flame/fiab
./build-config.sh

cd ..
make install

export PATH="$HOME/.flame/bin:$PATH"
