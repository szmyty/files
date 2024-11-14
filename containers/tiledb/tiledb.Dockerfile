# syntax=docker/dockerfile:1.3
# check=error=true
# escape=\
######################################################################
# @Project      : app
# @File         : Dockerfile
# @Description  : Multi-stage Dockerfile for building TileDB and its Python bindings.
#
# This Dockerfile is designed to build a secure and efficient container
# with TileDB and TileDB-Py installed. It breaks down the build process
# into multiple stages for better organization and smaller final image size.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-23
# @Version      : 1.0
# @References   :
#   - https://github.com/TileDB-Inc/TileDB-Docker/blob/master/release/Dockerfile
#   - https://github.com/TileDB-Inc/TileDB-Docker/blob/master/base/Dockerfile
#   - https://github.com/TileDB-Inc/TileDB/releases/tag/2.25.0
#   - https://github.com/microsoft/vcpkg/blob/master/scripts/bootstrap.sh
#   - https://github.com/GeorgeErickson/TileDB/blob/dev/doc/source/installation.rst
#   - https://github.com/TileDB-Inc/TileDB/blob/dev/examples/Dockerfile/Dockerfile
#   - https://github.com/microsoft/vcpkg
#   - https://medium.com/axops-academy/setting-up-aws-c-sdk-and-lambda-library-on-amazon-linux-2-3ab6cf6af23a
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

LABEL stage="base"
LABEL description="Base stage with necessary dependencies for building TileDB."

# Switch to root user to install required dependencies.
USER root

# Installation prefix for TileDB to be installed at.
ARG TILEDB_DATA_HOME=${APP_DATA}/tiledb
ARG TILEDB_PY_DATA_HOME=${TILEDB_DATA_HOME}/TileDB-Py
ARG VIRTUAL_ENV=${TILEDB_PY_DATA_HOME}/.venv

# Set environment variables.
ENV TILEDB_DATA_HOME=${TILEDB_DATA_HOME} \
    TILEDB_PY_DATA_HOME=${TILEDB_PY_DATA_HOME} \
    VIRTUAL_ENV=${VIRTUAL_ENV}

ENV PATH="${VIRTUAL_ENV}/bin:${TILEDB_DATA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${TILEDB_DATA_HOME}/lib:${LD_LIBRARY_PATH}"

# Install required dependencies for the build.
RUN apt-get update && apt-get install --yes \
    build-essential \
    cmake \
    git \
    wget \
    ninja-build \
    python3-pip \
    libsnappy-dev \
    libblosc-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libjemalloc-dev \
    libtbb-dev \
    libtiff-dev \
    libz-dev \
    libboost-all-dev \
    clang-format \
    clang-tidy \
    && rm -rf /var/lib/apt/lists/*

######################################################################
# Stage 2: Build TileDB
# This stage clones the TileDB repository and builds it.
# https://docs.tiledb.com/main/how-to/installation/building-from-source
######################################################################
FROM base AS build-tiledb

LABEL stage="build-tiledb"
LABEL description="Stage to build TileDB from source."

ARG TILEDB_VER_MAJOR=2
ARG TILEDB_VER_MINOR=25
ARG TILEDB_VER_PATCH=0
ARG TILEDB_REPO_URL="https://github.com/TileDB-Inc/TileDB.git"

# Setting the compilers to use.
ARG CC=gcc
ARG CXX=g++
ENV CC=${CC}
ENV CXX=${CXX}

ARG COMPILER_SUPPORTS_AVX2=FALSE
ARG CMAKE_BUILD_TYPE="Release"
ARG CMAKE_INSTALL_PREFIX=${TILEDB_DATA_HOME}
ARG TILEDB_REMOVE_DEPRECATIONS="OFF"
ARG TILEDB_VERBOSE="ON"
ARG TILEDB_S3="ON"
ARG TILEDB_AZURE="OFF"
ARG TILEDB_GCS="OFF"
ARG TILEDB_HDFS="OFF"
ARG TILEDB_WERROR="OFF"
ARG CMAKE_C_COMPILER=$(which ${CC})
ARG CMAKE_CXX_COMPILER=$(which ${CXX})
ARG TILEDB_ASSERTIONS="OFF"
ARG TILEDB_CPP_API="ON"
ARG TILEDB_STATS="ON"
ARG BUILD_SHARED_LIBS="ON"
ARG TILEDB_TESTS="ON"
ARG TILEDB_TOOLS="ON"
ARG TILEDB_SERIALIZATION="ON"
ARG TILEDB_CCACHE="ON"
ARG TILEDB_ARROW_TESTS="OFF"
ARG TILEDB_WEBP="ON"
ARG TILEDB_EXPERIMENTAL_FEATURES="OFF"
ARG TILEDB_TESTS_AWS_S3_CONFIG="OFF"
ARG TILEDB_DISABLE_AUTO_VCPKG="OFF"
ARG TILEDB_BUILD_PROC=2

ENV TILEDB_VERSION="${TILEDB_VER_MAJOR}.${TILEDB_VER_MINOR}.${TILEDB_VER_PATCH}"

WORKDIR ${TMPDIR}/tiledb

# Clone the TileDB repository and configure the build.
RUN git clone \
    --quiet \
    --depth 1 \
    --shallow-submodules \
    --recurse-submodules \
    --branch ${TILEDB_VERSION} \
    ${TILEDB_REPO_URL} . \
    && mkdir build \
    && cd build \
    && cmake .. \
    -GNinja \
    -DCOMPILER_SUPPORTS_AVX2=${COMPILER_SUPPORTS_AVX2} \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_INSTALL_PREFIX=${TILEDB_DATA_HOME} \
    -DTILEDB_REMOVE_DEPRECATIONS=${TILEDB_REMOVE_DEPRECATIONS} \
    -DTILEDB_VERBOSE=${TILEDB_VERBOSE} \
    -DTILEDB_S3=${TILEDB_S3} \
    -DTILEDB_AZURE=${TILEDB_AZURE} \
    -DTILEDB_GCS=${TILEDB_GCS} \
    -DTILEDB_HDFS=${TILEDB_HDFS} \
    -DTILEDB_WERROR=${TILEDB_WERROR} \
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} \
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} \
    -DTILEDB_ASSERTIONS=${TILEDB_ASSERTIONS} \
    -DTILEDB_CPP_API=${TILEDB_CPP_API} \
    -DTILEDB_STATS=${TILEDB_STATS} \
    -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS} \
    -DTILEDB_TESTS=${TILEDB_TESTS} \
    -DTILEDB_TOOLS=${TILEDB_TOOLS} \
    -DTILEDB_SERIALIZATION=${TILEDB_SERIALIZATION} \
    -DTILEDB_CCACHE=${TILEDB_CCACHE} \
    -DTILEDB_ARROW_TESTS=${TILEDB_ARROW_TESTS} \
    -DTILEDB_WEBP=${TILEDB_WEBP} \
    -DTILEDB_EXPERIMENTAL_FEATURES=${TILEDB_EXPERIMENTAL_FEATURES} \
    -DTILEDB_TESTS_AWS_S3_CONFIG=${TILEDB_TESTS_AWS_S3_CONFIG} \
    -DTILEDB_DISABLE_AUTO_VCPKG=${TILEDB_DISABLE_AUTO_VCPKG} \
    && ninja --verbose -j${TILEDB_BUILD_PROC} all \
    && ninja --verbose -j${TILEDB_BUILD_PROC} install-tiledb \
    && ninja --verbose -j${TILEDB_BUILD_PROC} check \
    && ninja --verbose -j${TILEDB_BUILD_PROC} examples \
    && ldconfig

WORKDIR ${APP_HOME}

######################################################################
# Stage 3: Build TileDB-Py
# This stage clones the TileDB-Py repository and installs the Python bindings.
######################################################################
FROM base AS build-tiledb-py

LABEL stage="build-tiledb-py"
LABEL description="Stage to build and install TileDB-Py with a virtual environment."

# TODO: https://docs.tiledb.com/main/how-to/installation/building-from-source/python
# https://docs.tiledb.com/main/how-to/installation/usage/python

# TODO need to configure TileDB: https://docs.tiledb.com/main/how-to/configuration#basic-usage

# https://packages.debian.org/bookworm/libtbb-dev

ARG TILEDB_PY_VER_MAJOR=0
ARG TILEDB_PY_VER_MINOR=31
ARG TILEDB_PY_VER_PATCH=1
ARG TILEDB_PY_REPO_URL="https://github.com/TileDB-Inc/TileDB-Py.git"

ENV TILEDB_PY_VERSION="${TILEDB_PY_VER_MAJOR}.${TILEDB_PY_VER_MINOR}.${TILEDB_PY_VER_PATCH}"

WORKDIR ${TMPDIR}/tiledb-py

# Install Python3 venv package, clone the TileDB-Py repository, and install the Python bindings in a virtual environment.
RUN apt-get update && apt-get install --yes python3-venv \
    && python3 -m venv ${VIRTUAL_ENV} \
    && git clone --quiet --recurse-submodules --branch ${TILEDB_PY_VERSION} ${TILEDB_PY_REPO_URL} . \
    && pip3 install --upgrade pip \
    && pip3 install --requirement requirements.txt \
    && python3 setup.py install --tiledb=${TILEDB_DATA_HOME}

# # Clean up APT when done.
# RUN apt-get remove -y python3-venv && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

######################################################################
# Stage 4: Final Image
# This stage copies the necessary files from the build stages and prepares the final image.
######################################################################
# FROM base AS final
FROM build-tiledb-py as final

LABEL stage="final"
LABEL description="Final stage with TileDB and TileDB-Py installed."

# Copy TileDB and TileDB-Py installations from the build stages.
COPY --from=build-tiledb ${TILEDB_DATA_HOME} ${TILEDB_DATA_HOME}
COPY --from=build-tiledb-py ${TILEDB_DATA_HOME} ${TILEDB_DATA_HOME}

# Copy the scripts from the local bin directory to overwrite the container's bin directory.
COPY --chown=${APP_USER}:${APP_GROUP} --chmod=500 bin ${APP_BIN}

# Set working directory.
WORKDIR ${APP_HOME}

# RUN ${APP_BIN}/post-install.sh

# Need to switch to a non-root user to avoid running as root.

# Default command (override as needed).
CMD ["/bin/bash"]
