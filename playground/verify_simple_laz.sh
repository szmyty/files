#!/bin/bash

# Download and configure the MinIO client if not already installed
if ! command -v mc &> /dev/null; then
    echo "Installing MinIO client..."
    curl -sO https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x mc
    sudo mv mc /usr/local/bin/
fi

# Set up MinIO client alias with credentials
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Define the bucket and file name
BUCKET_NAME="input-bucket"
FILE_NAME="simple.laz"

# List the contents of the bucket and check if the file exists
echo "Checking if ${FILE_NAME} exists in ${BUCKET_NAME}..."

if mc ls myminio/${BUCKET_NAME} | grep -q "${FILE_NAME}"; then
    echo "✅ File ${FILE_NAME} found in ${BUCKET_NAME}."
else
    echo "❌ File ${FILE_NAME} not found in ${BUCKET_NAME}."
fi
