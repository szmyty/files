# syntax=docker/dockerfile:1
# escape=\

######################################################################
# check=error=true
# Stage 1: Base Setup
# This stage sets up the base environment with necessary packages and dependencies.
######################################################################
# Project name.
ARG PROJECT_NAME=${PROJECT_NAME}

# Image name to use.
ARG BASE_IMAGE_NAME=base

# Image version to use.
ARG BASE_IMAGE_VERSION=latest

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
FROM --platform=linux/amd64 ${PROJECT_NAME}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION} AS base
# FROM --platform=linux/amd64 ${PROJECT_NAME}/${BASE_IMAGE_NAME}@${BASE_IMAGE_ID} AS BASE
# FROM ${BASE_IMAGE_ID} AS BASE

LABEL stage="base"
LABEL description="Base stage with necessary dependencies for building Matchering."

ARG MATCHERING_REPO_URL="https://github.com/sergree/matchering-web.git"

# Switch to root user to install required dependencies.
USER root

# Installation prefix for Matchering to be installed at.
ARG MATCHERING_DATA_HOME=${APP_DATA}/matchering

# Set environment variables.
ENV MATCHERING_DATA_HOME=${MATCHERING_DATA_HOME} \
    MATCHERING_SUPERVISOR_CONF=${APP_CONFIG}/supervisor.conf

# Install required dependencies for the build.
RUN apt-get update && apt-get install --yes \
    libsndfile1 \
    redis-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${MATCHERING_DATA_HOME}

RUN git clone \
    --quiet \
    --depth 1 \
    --shallow-submodules \
    --recurse-submodules \
    --branch master \
    ${MATCHERING_REPO_URL} . && \
    mkdir data && \
    chown --recursive ${APP_USER}:${APP_GROUP} data \
    && chmod --recursive 700 data

COPY --chown=${APP_USER}:${APP_GROUP} --chmod=644 config/.python-version .python-version

RUN pyenv install "$(cat .python-version)" && \
    pyenv use "$(cat .python-version)" && \
    pyenv rehash

COPY --chown=${APP_USER}:${APP_GROUP} --chmod=644 config/supervisor.conf ${MATCHERING_SUPERVISOR_CONF}

RUN pip3 install --no-cache-dir --requirement requirements.txt

# Copy the scripts from the local bin directory to overwrite the container's bin directory.
COPY --chown=${APP_USER}:${APP_GROUP} --chmod=500 bin ${APP_BIN}

FROM base AS final

ENTRYPOINT [ "/bin/bash", "-c", "${APP_BIN}/entrypoint.sh" ]
