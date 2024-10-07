# syntax=docker/dockerfile:1
# escape=\

# Project name.
ARG PROJECT_NAME=${PROJECT_NAME}

# Define ARG variables
ARG TARGETPLATFORM=linux/amd64
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG BUILDPLATFORM=linux/amd64
ARG BUILDOS=linux
ARG BUILDARCH=amd64
ARG BUILDVARIANT=
ARG BASE_IMAGE_ID=sha256:0

# Use a base image.
FROM --platform=linux/amd64 registry@${BASE_IMAGE_ID} AS BASE

LABEL stage="registry"
LABEL description="Docker registry stage with necessary dependencies."
