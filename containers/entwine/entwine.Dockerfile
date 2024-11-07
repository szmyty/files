# syntax=docker/dockerfile:1.3
# check=error=true
# escape=\
######################################################################
# @Project      : app
# @File         : Dockerfile
# @Description  : Multi-stage Dockerfile for building Entwine.
#
# @Author       : Alan Szmyt
# @Date         : 2024-11-05
# @Version      : 1.0
# @References   :
#   - https://github.com/connormanning/entwine
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
LABEL description="Base stage with necessary dependencies for building Entwine."

# Switch to root user to install required dependencies.
USER root

# Installation prefix for TileDB to be installed at.
# ARG TILEDB_DATA_HOME=${APP_DATA}/tiledb
# ARG TILEDB_PY_DATA_HOME=${TILEDB_DATA_HOME}/TileDB-Py
# ARG VIRTUAL_ENV=${TILEDB_PY_DATA_HOME}/.venv

# # Set environment variables.
# ENV TILEDB_DATA_HOME=${TILEDB_DATA_HOME} \
#     TILEDB_PY_DATA_HOME=${TILEDB_PY_DATA_HOME} \
#     VIRTUAL_ENV=${VIRTUAL_ENV}

# ENV PATH="${VIRTUAL_ENV}/bin:${TILEDB_DATA_HOME}/bin:${PATH}"
# ENV LD_LIBRARY_PATH="${TILEDB_DATA_HOME}/lib:${LD_LIBRARY_PATH}"

# Install required dependencies for the build.
RUN apt-get update && apt-get install --yes \
    build-essential \
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
    && rm -rf /var/lib/apt/lists/*

######################################################################
# Stage 2: Build Entwine
# This stage clones the Entwine repository and builds it.
######################################################################
FROM base AS build-entwine

LABEL stage="build-entwine"
LABEL description="Stage to build Entwine from source."

ARG ENTWINE_VER_MAJOR=3
ARG ENTWINE_VER_MINOR=1
ARG ENTWINE_VER_PATCH=1
ARG ENTWINE_REPO_URL="https://github.com/connormanning/entwine.git"

ENV ENTWINE_VERSION="${ENTWINE_VER_MAJOR}.${ENTWINE_VER_MINOR}.${ENTWINE_VER_PATCH}"

# WORKDIR ${TMPDIR}/entwine
WORKDIR ${APP_HOME}/entwine

# Clone the Entwine repository and configure the build.
RUN git clone \
    --quiet \
    --depth 1 \
    --shallow-submodules \
    --recurse-submodules \
    --branch ${ENTWINE_VERSION} \
    ${ENTWINE_REPO_URL} .

WORKDIR ${APP_HOME}

# Build Entwine
# WORKDIR /opt/entwine
# RUN mkdir build && cd build && \
#     cmake .. && \
#     make && \
#     make install

# Final stage
# FROM ${BASE_IMAGE}

# # Copy Entwine binary and libraries
# COPY --from=build /usr/local/bin/entwine /usr/local/bin/
# COPY --from=build /usr/local/lib/libentwine* /usr/local/lib/
# COPY --from=build /usr/local/include/entwine /usr/local/include/entwine

# # Copy Entwine configuration file
# COPY entwine-config.json /etc/entwine/config.json

# # Install runtime dependencies
# RUN apt-get update && apt-get install --yes \
#     libcurl4 \
#     libtiff5 \
#     libgeotiff2 \
#     libboost-system1.71.0 \
#     libjsoncpp1 \
#     libgdal26 \
#     && rm -rf /var/lib/apt/lists/*

# # Set environment variables
# ENV PROJ_LIB=/usr/share/proj
# ENV PROJ_NETWORK=TRUE
# ENV LD_LIBRARY_PATH=/usr/local/lib

# # Set entrypoint
# ENTRYPOINT ["entwine"]

# # Default command to use the configuration file
# CMD ["build", "-c", "/etc/entwine/config.json"]
















# ######################################################################
# # Stage 3: Build TileDB-Py
# # This stage clones the TileDB-Py repository and installs the Python bindings.
# ######################################################################
# FROM base AS build-tiledb-py

# LABEL stage="build-tiledb-py"
# LABEL description="Stage to build and install TileDB-Py with a virtual environment."

# # TODO: https://docs.tiledb.com/main/how-to/installation/building-from-source/python
# # https://docs.tiledb.com/main/how-to/installation/usage/python

# # TODO need to configure TileDB: https://docs.tiledb.com/main/how-to/configuration#basic-usage

# # https://packages.debian.org/bookworm/libtbb-dev

# ARG TILEDB_PY_VER_MAJOR=0
# ARG TILEDB_PY_VER_MINOR=31
# ARG TILEDB_PY_VER_PATCH=1
# ARG TILEDB_PY_REPO_URL="https://github.com/TileDB-Inc/TileDB-Py.git"

# ENV TILEDB_PY_VERSION="${TILEDB_PY_VER_MAJOR}.${TILEDB_PY_VER_MINOR}.${TILEDB_PY_VER_PATCH}"

# WORKDIR ${TMPDIR}/tiledb-py

# # Install Python3 venv package, clone the TileDB-Py repository, and install the Python bindings in a virtual environment.
# RUN apt-get update && apt-get install --yes python3-venv \
#     && python3 -m venv ${VIRTUAL_ENV} \
#     && git clone --quiet --recurse-submodules --branch ${TILEDB_PY_VERSION} ${TILEDB_PY_REPO_URL} . \
#     && pip3 install --upgrade pip \
#     && pip3 install --requirement requirements.txt \
#     && python3 setup.py install --tiledb=${TILEDB_DATA_HOME}

# # # Clean up APT when done.
# # RUN apt-get remove -y python3-venv && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# ######################################################################
# # Stage 4: Final Image
# # This stage copies the necessary files from the build stages and prepares the final image.
# ######################################################################
# # FROM base AS final
# FROM build-tiledb-py as final

# LABEL stage="final"
# LABEL description="Final stage with TileDB and TileDB-Py installed."

# # Copy TileDB and TileDB-Py installations from the build stages.
# COPY --from=build-tiledb ${TILEDB_DATA_HOME} ${TILEDB_DATA_HOME}
# COPY --from=build-tiledb-py ${TILEDB_DATA_HOME} ${TILEDB_DATA_HOME}

# # Copy the scripts from the local bin directory to overwrite the container's bin directory.
# COPY --chown=${APP_USER}:${APP_GROUP} --chmod=500 bin ${APP_BIN}

# # Set working directory.
# WORKDIR ${APP_HOME}

# # RUN ${APP_BIN}/post-install.sh

# # Need to switch to a non-root user to avoid running as root.

# # Default command (override as needed).
# CMD ["/bin/bash"]
