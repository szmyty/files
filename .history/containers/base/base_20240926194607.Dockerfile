# syntax=docker/dockerfile:1
# check=error=true
# escape=\
######################################################################
# @Project      : app
# @File         : Dockerfile
# @Description  : Dockerfile for building a secure and efficient container.
#                 Includes custom APT and DPKG configurations, installs
#                 necessary packages from a package list, and sets up a
#                 non-root user for running applications.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-23
# @Version      : 1.0
#
# @References   :
#   - https://hub.docker.com/_/debian/
#   - https://repo1.dso.mil/dsop/opensource/debian/
#   - https://docs.docker.com/reference/dockerfile/
#   - https://docs.docker.com/build/building/best-practices/
#   - https://docs.docker.com/develop/develop-images/multistage-build/
######################################################################

# TODO for multi platform and reproducible builds, need to get sha256 of the exact images.
# Debian's supported architectures: https://wiki.debian.org/SupportedArchitectures
# amd64, arm32v5, arm32v7, arm64v8, i386, mips64le, ppc64le, riscv64, s390x

# Stage 1: Base Image Setup
ARG BASE_IMAGE_VERSION

# Use the official Debian image as the base image.
ARG DEBIAN_IMAGE_VERSION

# Define ARG variables
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG BUILDVARIANT

FROM debian:${DEBIAN_IMAGE_VERSION} AS setup
# FROM --platform=${BUILDPLATFORM} debian:${DEBIAN_IMAGE_VERSION} AS setup

RUN echo "Base image version: ${BASE_IMAGE_VERSION}"
RUN echo "Project name: ${COMPOSE_PROJECT_NAME}"
RUN echo "Building for platform: ${BUILDPLATFORM}"
RUN echo "Target platform: ${TARGETPLATFORM}"
RUN echo "Target OS: ${TARGETOS}"
RUN echo "Target architecture: ${TARGETARCH}"
RUN echo "Target variant: ${TARGETVARIANT}"
RUN echo "Build OS: ${BUILDOS}"
RUN echo "Build architecture: ${BUILDARCH}"
RUN echo "Build variant: ${BUILDVARIANT}"

# Set labels using OCI conventions and incorporating ARG variables
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md
# https://specs.opencontainers.org/image-spec/annotations/
# LABEL \
#     org.opencontainers.image.created="2024-08-23" \
#     org.opencontainers.image.authors="Alan Szmyt" \
#     org.opencontainers.image.url="https://example.com/myimage" \
#     org.opencontainers.image.documentation="https://example.com/myimage/docs" \
#     org.opencontainers.image.source="https://github.com/example/myimage" \
#     org.opencontainers.image.version=${BASE_IMAGE_VERSION} \
#     org.opencontainers.image.revision="abc1234" \
#     org.opencontainers.image.vendor="Example, Inc." \
#     org.opencontainers.image.licenses="MIT" \
#     org.opencontainers.image.title="${COMPOSE_PROJECT_NAME}" \
#     org.opencontainers.image.description="This image is used for..." \
#     org.opencontainers.image.base.name="debian:bookworm" \
#     org.opencontainers.image.target.platform="${TARGETPLATFORM}" \
#     org.opencontainers.image.target.os="${TARGETOS}" \
#     org.opencontainers.image.target.arch="${TARGETARCH}" \
#     org.opencontainers.image.target.variant="${TARGETVARIANT}" \
#     org.opencontainers.image.build.platform="${BUILDPLATFORM}" \
#     org.opencontainers.image.build.os="${BUILDOS}" \
#     org.opencontainers.image.build.arch="${BUILDARCH}" \
#     org.opencontainers.image.build.variant="${BUILDVARIANT}"

# Arguments with default values.
ARG TMPDIR=/tmp
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US:en
ARG TZ=UTC
ARG PYTHONUNBUFFERED=1
ARG PYTHONIOENCODING=UTF-8
ARG PYTHONFAULTHANDLER=1
ARG PYTHONHASHSEED=random
ARG PYTHONUTF8=1
ARG PYTHONVERBOSE=1
ARG PIP_NO_CACHE_DIR=off
ARG PIP_DISABLE_PIP_VERSION_CHECK=on
ARG PIP_DEFAULT_TIMEOUT=100
ARG PIP_NO_WARN_SCRIPT_LOCATION=on
# Disable weak cryptography in GNUTLS
ARG GNUTLS_FORCE_FIPS_MODE=1

# Set environment variables.
ENV APP_USER=app
ENV APP_GROUP=app
ENV APP_UID=65532
ENV APP_GID=65532
ENV APP_HOME=/home/${APP_USER}
ENV APP_BIN=${APP_HOME}/bin
ENV APP_CONFIG=${APP_HOME}/config
ENV APP_LOGS=${APP_HOME}/logs
ENV APP_DATA=${APP_HOME}/data
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_PRIORITY=critical \
    DEBCONF_NOWARNINGS=yes \
    TERM=xterm-256color \
    APT_LISTCHANGES_FRONTEND=none \
    APT_LISTBUGS_FRONTEND=none \
    NOPERLDOC=1 \
    TMPDIR=${TMPDIR} \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ} \
    PYTHONUNBUFFERED=${PYTHONUNBUFFERED} \
    PYTHONIOENCODING=${PYTHONIOENCODING} \
    PYTHONFAULTHANDLER=${PYTHONFAULTHANDLER} \
    PYTHONHASHSEED=${PYTHONHASHSEED} \
    PYTHONUTF8=${PYTHONUTF8} \
    PYTHONVERBOSE=${PYTHONVERBOSE} \
    PIP_NO_CACHE_DIR=${PIP_NO_CACHE_DIR} \
    PIP_DISABLE_PIP_VERSION_CHECK=${PIP_DISABLE_PIP_VERSION_CHECK} \
    PIP_DEFAULT_TIMEOUT=${PIP_DEFAULT_TIMEOUT} \
    PIP_NO_WARN_SCRIPT_LOCATION=${PIP_NO_WARN_SCRIPT_LOCATION} \
    GNUTLS_FORCE_FIPS_MODE=${GNUTLS_FORCE_FIPS_MODE}

# Ensure the build process uses the root user.
USER root

# Set safer shell options for script execution.
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

# Create necessary directories and set permissions.
RUN mkdir --parents ${APP_HOME} \
    ${APP_BIN} ${APP_CONFIG} ${APP_LOGS} ${APP_DATA} \
    # Set ownership to the app user and group
    && chown --recursive ${APP_USER}:${APP_GROUP} ${APP_HOME} \
    # Set permissions: read, write, and execute for owner, and read-only for group and others
    && chmod --recursive 700 ${SANCTUARY_HOME} \
    && chmod --recursive 755 ${SANCTUARY_BIN}

# Create a non-root user with specific configurations.
RUN groupadd \
    --gid ${SANCTUARY_GID} \
    --force ${SANCTUARY_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${SANCTUARY_UID} \
    --gid ${SANCTUARY_GID} \
    --comment "Non-root User for Running Applications" \
    --home-dir ${SANCTUARY_HOME} \
    --shell /usr/sbin/nologin \
    ${SANCTUARY_USER}

# Set the working directory to the sanctuary home directory.
WORKDIR ${SANCTUARY_HOME}

# TODO for security, we could have a specific user that is allowed to use the scripts and so you are forced to switch to that user to run the scripts. This will enforce extending the base image to utilize the scripts.
# Copy the scripts from the local bin directory to the container's bin directory.
COPY --chown=${SANCTUARY_USER}:${SANCTUARY_GROUP} --chmod=500 bin ${SANCTUARY_BIN}

# Copy apt.conf and dpkg.cfg to their respective locations.
COPY --chown=root:root --chmod=644  config/apt.conf /etc/apt/apt.conf.d/99docker-apt.conf
COPY --chown=root:root --chmod=644  config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99docker-dpkg.cfg

# Set the environment variable for the global Git config location for all users
ENV GIT_CONFIG=${SANCTUARY_CONFIG}/.gitconfig

# Copy the Git config file to a common location accessible by all users
COPY --chown=root:root --chmod=644 config/.gitconfig ${GIT_CONFIG}

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir -p /usr/share/man/man1


# Stage 2: Installing APT Dependencies.
FROM setup AS apt-install

# Install packages using cached directories and configure locale and timezone.
# TODO set versions per platform
# https://docs.docker.com/build/building/best-practices/#apt-get
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib \
    apt-get update \
    && apt-get install --yes \
    apt-utils \
    build-essential \
    bzip2 \
    ca-certificates \
    ccache \
    clang-format \
    clang-tidy \
    cmake \
    curl \
    dnsutils \
    doxygen \
    git \
    ghostscript \
    graphviz \
    htop \
    iputils-ping \
    libaprutil1 \
    libboost-all-dev \
    libblosc-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    libksba8 \
    liblz4-dev \
    liblzma-dev \
    libreadline-dev \
    libpng-dev \
    libpng-tools \
    libncursesw5-dev \
    libspdlog-dev \
    libsqlite3-dev \
    libssl-dev \
    libtasn1-6 \
    libtiff-dev \
    libtool \
    libxml2-dev \
    libxmlsec1-dev \
    libzstd-dev \
    locales \
    locales-all \
    lsof \
    make \
    nano \
    net-tools \
    ninja-build \
    pandoc \
    pkg-config \
    python3 \
    python3-dev \
    strace \
    sysstat \
    tcpdump \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ${SANCTUARY_TOOLS_BIN}/setup_locale.sh \
    && ${SANCTUARY_TOOLS_BIN}/set_timezone.sh

FROM apt-install AS logger

# Optional: Verify package installation from cache without internet
RUN --network=none \
    dpkg -l | grep -E 'locales|cmake|python3' > ${SANCTUARY_LOGS}/packages.log

RUN printenv | sort > ${SANCTUARY_LOGS}/environment.log

# Log the current git configuration.
RUN git config --list --show-origin > ${SANCTUARY_LOGS}/gitconfig.log

RUN dpkg --get-selections > ${SANCTUARY_LOGS}/installed_packages.log

# Log the current APT configuration.
RUN apt-config dump > ${SANCTUARY_LOGS}/apt-config.log

FROM logger AS base

# Switch to the non-root user.
USER ${SANCTUARY_USER}:${SANCTUARY_GROUP}

VOLUME [ "/home/app/data" ]
VOLUME [ "/home/app/config" ]
VOLUME [ "/home/app/logs" ]

# Set Bash as the entry point to keep the container running.
ENTRYPOINT [ "bash", "-c", "tail -f /dev/null" ]

# Healthcheck to ensure the container is running.
HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --start-period=5s \
    --retries=3 \
    CMD ${SANCTUARY_BIN}/healthcheck.sh
