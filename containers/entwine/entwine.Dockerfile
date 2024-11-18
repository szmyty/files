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
ENV PDAL_DIR=${PDAL_DATA_HOME}/lib/cmake

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

######################################################################
# Stage 2: Build PDAL
# This stage clones the PDAL repository, builds, and installs it.
# PDAL is a C++ library for translating and processing point cloud data.
#
# @References:
#   - https://github.com/PDAL/PDAL/blob/master/scripts/docker/ubuntu/Dockerfile
######################################################################
FROM base AS pdal

# Set labels for the pdal stage.
LABEL stage="pdal"
LABEL description="Stage to build PDAL from source."

# Set the PDAL version to build.
ARG PDAL_VER_MAJOR=2
ARG PDAL_VER_MINOR=8
ARG PDAL_VER_PATCH=1
ARG PDAL_REPO_URL="https://github.com/PDAL/PDAL.git"

# Set the PDAL version to use as an environment variable.
ENV PDAL_VERSION="${PDAL_VER_MAJOR}.${PDAL_VER_MINOR}.${PDAL_VER_PATCH}"

# Set the installation prefix.
ARG CMAKE_INSTALL_PREFIX=${PDAL_DATA_HOME}
ARG PDAL_LIB_PREFIX="$CMAKE_INSTALL_PREFIX/lib"

# Set the build shared libraries option.
ARG BUILD_SHARED_LIBS="ON"

# Set the CXXFLAGS options environment variable.
ARG CXXFLAGS="-Werror=strict-aliasing"

# Set the LDFLAGS options environment variable.
ARG LDFLAGS="-Wl,-rpath-link,$PDAL_LIB_PREFIX"

# Set the number of processors to use for the build.
ARG PDAL_BUILD_PROC=2
ENV PDAL_BUILD_PROC=${PDAL_BUILD_PROC}

# PDAL build options.
ARG BUILD_PLUGIN_CPD=OFF
ARG BUILD_PLUGIN_PGPOINTCLOUD=ON
ARG BUILD_PLUGIN_NITF=OFF
ARG BUILD_PLUGIN_ICEBRIDGE=OFF
ARG BUILD_PLUGIN_HDF=OFF
ARG BUILD_PLUGIN_ARROW=OFF
ARG BUILD_PLUGIN_DRACO=OFF
ARG BUILD_PLUGIN_TILEDB=OFF
ARG BUILD_PLUGIN_E57=OFF
ARG BUILD_PGPOINTCLOUD_TESTS=OFF
ARG BUILD_PLUGIN_MBIO=OFF
ARG WITH_ZSTD=ON

# Switch to the pdal directory.
WORKDIR ${APP_HOME}/pdal

# Clone the PDAL repository and configure the build.
RUN git clone \
    --quiet \
    --depth 1 \
    --branch ${PDAL_VERSION} \
    ${PDAL_REPO_URL} . \
    && mkdir build \
    && cd build  \
    && \
    CXXFLAGS=${CXXFLAGS} \
    LDFLAGS=${LDFLAGS} \
    cmake .. \
    -GNinja \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_C_COMPILER=$(which ${CC}) \
    -DCMAKE_CXX_COMPILER=$(which ${CXX}) \
    -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS} \
    -DCMAKE_PREFIX_PATH:FILEPATH=${PDAL_LIB_PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
    -DBUILD_PLUGIN_CPD=${BUILD_PLUGIN_CPD} \
    -DBUILD_PLUGIN_PGPOINTCLOUD=${BUILD_PLUGIN_PGPOINTCLOUD} \
    -DBUILD_PLUGIN_NITF=${BUILD_PLUGIN_NITF} \
    -DBUILD_PLUGIN_ICEBRIDGE=${BUILD_PLUGIN_ICEBRIDGE} \
    -DBUILD_PLUGIN_HDF=${BUILD_PLUGIN_HDF} \
    -DBUILD_PLUGIN_ARROW=${BUILD_PLUGIN_ARROW} \
    -DBUILD_PLUGIN_DRACO=${BUILD_PLUGIN_DRACO} \
    -DBUILD_PLUGIN_TILEDB=${BUILD_PLUGIN_TILEDB} \
    -DBUILD_PLUGIN_E57=${BUILD_PLUGIN_E57} \
    -DBUILD_PGPOINTCLOUD_TESTS=${BUILD_PGPOINTCLOUD_TESTS} \
    -DBUILD_PLUGIN_MBIO=${BUILD_PLUGIN_MBIO} \
    -DWITH_ZSTD=${WITH_ZSTD} \
    && ninja --verbose -j${PDAL_BUILD_PROC} \
    && ctest -V \
    && ninja --verbose -j${PDAL_BUILD_PROC} install \
    && ldconfig

# Switch back to the app directory.
WORKDIR ${APP_HOME}

######################################################################
# Stage 3: Build Entwine
# This stage clones the Entwine repository and builds it.
######################################################################
FROM base AS entwine

# Set labels for the entwine stage.
LABEL stage="entwine"
LABEL description="Stage to build Entwine from source."

# Set the Entwine version to build.
ARG ENTWINE_VER_MAJOR=3
ARG ENTWINE_VER_MINOR=1
ARG ENTWINE_VER_PATCH=1
ARG ENTWINE_REPO_URL="https://github.com/connormanning/entwine.git"

# Set the Entwine version to use as an environment variable.
ENV ENTWINE_VERSION="${ENTWINE_VER_MAJOR}.${ENTWINE_VER_MINOR}.${ENTWINE_VER_PATCH}"

# Copy PDAL binary and libraries.
COPY --from=pdal ${PDAL_DATA_HOME}/bin ${PDAL_DATA_HOME}/bin/
COPY --from=pdal ${PDAL_DATA_HOME}/lib/libpdal* ${PDAL_DATA_HOME}/lib/
COPY --from=pdal ${PDAL_DATA_HOME}/include/pdal ${PDAL_DATA_HOME}/include/pdal

# Set the installation prefix.
ARG CMAKE_INSTALL_PREFIX=${ENTWINE_DATA_HOME}
ARG ENTWINE_LIB_PREFIX="$CMAKE_INSTALL_PREFIX/lib"
ARG PDAL_LIB_PREFIX="$PDAL_DATA_HOME/lib"

# Set the build shared libraries option.
ARG BUILD_SHARED_LIBS="ON"

# Set the CXXFLAGS options environment variable.
ARG CXXFLAGS="-Werror=strict-aliasing"

# Set the LDFLAGS options environment variable.
ARG LDFLAGS="-Wl,-rpath-link,$ENTWINE_LIB_PREFIX"

# Set the number of processors to use for the build.
ARG ENTWINE_BUILD_PROC=2
ENV ENTWINE_BUILD_PROC=${ENTWINE_BUILD_PROC}

# Switch to the entwine directory.
WORKDIR ${APP_HOME}/entwine

# Clone the Entwine repository and configure the build.
RUN git clone \
    --quiet \
    --depth 1 \
    --shallow-submodules \
    --recurse-submodules \
    --branch ${ENTWINE_VERSION} \
    ${ENTWINE_REPO_URL} . \
    && mkdir build \
    && cd build \
    && \
    CXXFLAGS=${CXXFLAGS} \
    LDFLAGS=${LDFLAGS} \
    cmake .. \
    -GNinja \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_C_COMPILER=$(which gcc) \
    -DCMAKE_CXX_COMPILER=$(which g++) \
    -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS} \
    -DCMAKE_PREFIX_PATH:FILEPATH="${ENTWINE_LIB_PREFIX};${PDAL_LIB_PREFIX}" \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
    && ninja --verbose -j${ENTWINE_BUILD_PROC} \
    && ninja install \
    && ldconfig

# Switch back to the app directory.
WORKDIR ${APP_HOME}

# Final stage
FROM base AS final

# Copy PDAL binary and libraries from entwine stage.
COPY --from=entwine ${PDAL_DATA_HOME}/bin ${PDAL_DATA_HOME}/bin/
COPY --from=entwine ${PDAL_DATA_HOME}/lib/libpdal* ${PDAL_DATA_HOME}/lib/
COPY --from=entwine ${PDAL_DATA_HOME}/include/pdal ${PDAL_DATA_HOME}/include/pdal

# Copy Entwine binary and libraries.
COPY --from=entwine ${ENTWINE_DATA_HOME}/bin ${ENTWINE_DATA_HOME}/bin/
COPY --from=entwine ${ENTWINE_DATA_HOME}/lib/libentwine* ${ENTWINE_DATA_HOME}/lib/
COPY --from=entwine ${ENTWINE_DATA_HOME}/include/entwine ${ENTWINE_DATA_HOME}/include/entwine

# Copy Entwine configuration file
# COPY entwine-config.json /etc/entwine/config.json

# Install runtime dependencies
RUN apt-get update && apt-get install --yes \
    libcurl4 \
    libtiff5 \
    libgeotiff2 \
    libboost-system1.71.0 \
    libjsoncpp1 \
    libgdal26 \
    && rm -rf /var/lib/apt/lists/*

# # Set environment variables
# ENV PROJ_LIB=/usr/share/proj
# ENV LD_LIBRARY_PATH=/usr/local/lib

# # Set entrypoint
# ENTRYPOINT ["entwine"]

# # Default command to use the configuration file
# CMD ["build", "-c", "/etc/entwine/config.json"]

# Hack to work around problems with Proj.4 in Docker
# ENV PROJ_LIB ${CONDAENV}/share/proj
# ENV PROJ_NETWORK=TRUE
# ENV DTED_APPLY_PIXEL_IS_POINT=TRUE
# ENV GTIFF_POINT_GEO_IGNORE=TRUE
# ENV GTIFF_REPORT_COMPD_CS=TRUE
# ENV REPORT_COMPD_CS=TRUE
# ENV OAMS_TRADITIONAL_GIS_ORDER=TRUE
# ENV XDG_DATA_HOME=${CONDAENV}/share
# ENV PROJ_NETWORK=TRUE
# ENV PROJ_DATA="${CONDAENV}/share/proj"
# ENV GDAL_DATA="${CONDAENV}/share/gdal"
# ENV PDAL_DRIVER_PATH="${CONDAENV}/lib:${CONDAENV}/lib/python3.12/site-packages/pdal/"
# ENV GEOTIFF_CSV="${CONDAENV}/share/epsg_csv"
# ENV GDAL_DRIVER_PATH="${CONDAENV}/lib/gdalplugins"
# ENV PATH="$PATH:${CONDAENV}/bin"
# ENV GTIFF_REPORT_COMPD_CS=TRUE
# ENV REPORT_COMPD_CS=TRUE
# ENV OAMS_TRADITIONAL_GIS_ORDER=TRUE
