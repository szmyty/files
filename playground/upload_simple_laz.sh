#!/bin/bash

# Set up MinIO client alias with credentials (no prompt)
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Create the bucket if it doesn't already exist (optional safety check)
mc mb myminio/input-bucket || true

# Upload simple.laz file to the MinIO bucket
mc cp simple.laz myminio/input-bucket/
