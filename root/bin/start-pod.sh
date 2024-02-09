#!/bin/bash

echo "start pod"

echo "setting up pod"
. /home/root/bin/setup-pod.sh

echo "launching bootstrap"

/home/root/bin/bootstrap.sh &

echo "entering loop"

/home/root/bin/loop.sh
