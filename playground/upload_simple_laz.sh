#!/bin/bash

# Download simple.laz if it doesn't exist
if [ ! -f simple.laz ]; then
  curl -O https://raw.githubusercontent.com/mundialis/docker-pdal/master/simple.laz
fi

# Install MinIO client if not installed
if ! command -v mc &> /dev/null; then
  curl -sO https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  sudo mv mc /usr/local/bin/
fi

# Set MinIO alias
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Create the bucket if it doesn't exist
mc mb myminio/input-bucket || true

# Upload simple.laz to the bucket
mc cp simple.laz myminio/input-bucket/
