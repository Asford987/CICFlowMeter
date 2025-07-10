#!/bin/bash

# Get the current timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Compute a SHA256 hash from the timestamp
DATE_HASH=$(echo -n "$TIMESTAMP" | sha256sum | cut -d' ' -f1)

# Get the first 7 characters of the hash
SHORT_HASH=${DATE_HASH:0:7}

DOCKER_NAME=asford3000/cicflowmeter:v4.$(date +%Y%m%d)-$SHORT_HASH

docker build -t cicflowmeter:v4 .
docker tag cicflowmeter:v4 $DOCKER_NAME
docker push $DOCKER_NAME