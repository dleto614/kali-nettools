#!/usr/bin/env bash

echo "[*] Starting docker in the background"

CERTS_FOLDER="certs/generated" # Specify the directory for generated certs

mkdir -p "$CERTS_FOLDER"

sudo docker run -it --rm \
  --net=host \
  --privileged \
  -t -d \
  -v $(pwd)/"$CERTS_FOLDER":/opt/"$CERTS_FOLDER" \
  -v "$(pwd)/logs:/opt/eaphammer/logs" \
  kali-nettools

echo "[*] Done"