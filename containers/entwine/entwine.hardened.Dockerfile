# syntax=docker/dockerfile:1.3
# check=error=true
# escape=\
######################################################################
# @Project      : app
# @File         : Dockerfile
# @Description  : Multi-stage Dockerfile for building Entwine.
#
# @Author       : Alan Szmyt
# @References   :
#   - https://github.com/connormanning/entwine
#   - https://github.com/mundialis/docker-pdal
#   - https://wiki.osgeo.org/wiki/DockerImages
######################################################################

######################################################################
# Stage 1: Base Setup
# This stage sets up the base environment with necessary packages and dependencies.
######################################################################
# Project name.
ARG PROJECT_NAME=${COMPOSE_PROJECT_NAME}

# Image name to use.
ARG BASE_IMAGE_NAME=base

# Image version to use.
ARG BASE_IMAGE_VERSION=latest

# Use a base image.
FROM ${PROJECT_NAME}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION} AS base

# Set labels for the base stage.
LABEL stage="base"
LABEL description="Base stage with necessary dependencies for building Entwine."

# Installation prefix for PDAL to be installed at.
ARG PDAL_DATA_HOME=${APP_DATA}/pdal
ENV PDAL_DATA_HOME=${PDAL_DATA_HOME}
ENV PDAL_DIR=${PDAL_DATA_HOME}/lib/cmake/PDAL

# Installation prefix for Entwine to be installed at.
ARG ENTWINE_DATA_HOME=${APP_DATA}/entwine
ENV ENTWINE_DATA_HOME=${ENTWINE_DATA_HOME}

# Set the PATH and LD_LIBRARY_PATH environment variables.
ENV PATH="${ENTWINE_DATA_HOME}/bin:${PDAL_DATA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${ENTWINE_DATA_HOME}/lib:${PDAL_DATA_HOME}/lib:${LD_LIBRARY_PATH}"

# Setting the compilers to use.
ARG CC=gcc
ENV CC=${CC}
ARG CXX=g++
ENV CXX=${CXX}

# Set the build type.
ARG CMAKE_BUILD_TYPE="Release"
ENV CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

# Switch to root user to install required dependencies.
USER root

# Install required dependencies for the build.
RUN apt-get update && apt-get install --yes \
    build-essential \
    gcc \
    g++ \
    cmake \
    git \
    libcurl4-openssl-dev \
    libtiff-dev \
    libgeotiff-dev \
    libboost-all-dev \
    libjsoncpp-dev \
    libgdal-dev \
    wget \
    ca-certificates \
    proj-bin \
    hdf4-tools \
    geotiff-bin \
    gdal-bin \
    netcdf-bin \
    && rm -rf /var/lib/apt/lists/*


# TODO
# 1. execute hardening scripts.
# 2. Remove harden.sh script after applying hardening.
# 3. Still allow for any arguments to be passed to the image that is built so that the image can be customized and is essentially the same image to the user.
