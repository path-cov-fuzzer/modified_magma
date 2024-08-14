#!/bin/bash

docker build -t chenyinhua/path_fuzz_estimation --build-arg USER_ID=1002 \
--build-arg GROUP_ID=1002 --build-arg canaries=1 \
-f $(pwd)/docker/Dockerfile.for_docker $(pwd)
