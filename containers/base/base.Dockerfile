# syntax=docker/dockerfile:1
# escape=\
######################################################################
# check=error=true
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
ARG DEBIAN_IMAGE_VERSION=bookworm-20240926-slim

# Define ARG variables
# ARG TARGETPLATFORM=linux/amd64
# ARG TARGETOS=linux
# ARG TARGETARCH=amd64
# ARG TARGETVARIANT=
# ARG BUILDPLATFORM=linux/amd64
# ARG BUILDOS=linux
# ARG BUILDARCH=amd64
# ARG BUILDVARIANT=

# FROM debian:${DEBIAN_IMAGE_VERSION} AS setup
FROM debian:${DEBIAN_IMAGE_VERSION} AS setup

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
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${APP_BIN}

ENV CFLAGS=-O2 \
    DEBIAN_FRONTEND=noninteractive \
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
RUN mkdir --parents ${APP_HOME} ${APP_BIN} ${APP_CONFIG} ${APP_LOGS} ${APP_DATA}

# Create a non-root user with specific configurations.
RUN groupadd \
    --gid ${APP_GID} \
    --force ${APP_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${APP_UID} \
    --gid ${APP_GID} \
    --comment "Non-root User for Running Applications" \
    --home-dir ${APP_HOME} \
    --shell /usr/sbin/nologin \
    ${APP_USER} && \
    # Set ownership to the app user and group
    chown --recursive ${APP_USER}:${APP_GROUP} ${APP_HOME} \
    # Set permissions: read, write, and execute for owner, and read-only for group and others
    && chmod --recursive 700 ${APP_HOME} \
    && chmod --recursive 755 ${APP_BIN}

# Set the working directory to the app home directory.
WORKDIR ${APP_HOME}

# TODO for security, we could have a specific user that is allowed to use the scripts and so you are forced to switch to that user to run the scripts. This will enforce extending the base image to utilize the scripts.
# Copy the scripts from the local bin directory to the container's bin directory.
COPY --chown=${APP_USER}:${APP_GROUP} --chmod=500 bin ${APP_BIN}

# Copy apt.conf and dpkg.cfg to their respective locations.
COPY --chown=root:root --chmod=644  config/apt.conf /etc/apt/apt.conf.d/99docker-apt.conf
COPY --chown=root:root --chmod=644  config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99docker-dpkg.cfg

# Set the environment variable for the global Git config location for all users
ENV GIT_CONFIG=${APP_CONFIG}/.gitconfig

# Copy the Git config file to a common location accessible by all users
COPY --chown=root:root --chmod=644 config/.gitconfig ${GIT_CONFIG}

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir --parents /usr/share/man/man1

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
    bash \
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
    ffmpeg \
    gettext \
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
    libncurses5-dev \
    libncursesw5-dev \
    libsecret-1-dev \
    libsndfile1 \
    libspdlog-dev \
    libsqlite3-dev \
    libssl-dev \
    libtasn1-6 \
    libtiff-dev \
    libtool \
    libxml2-dev \
    libxmlsec1-dev \
    libzstd-dev \
    llvm \
    locales \
    locales-all \
    lsof \
    make \
    moreutils \
    nano \
    net-tools \
    ninja-build \
    openssh-client \
    pandoc \
    pkg-config \
    python3 \
    python3-dev \
    python3-openssl \
    python3-pip \
    strace \
    sysstat \
    tcpdump \
    unzip \
    uuid-runtime \
    vim \
    wget \
    xz-utils \
    tk-dev \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ${APP_BIN}/setup_locale.sh \
    && ${APP_BIN}/set_timezone.sh

FROM apt-install AS install-pyenv

LABEL stage="install-pyenv"
LABEL description="Stage to install pyenv from source."

ARG PYENV_VER_MAJOR=2
ARG PYENV_VER_MINOR=4
ARG PYENV_VER_PATCH=14
ARG PYENV_REPO_URL="https://github.com/pyenv/pyenv.git"

ARG PYTHON_VER_MAJOR=3
ARG PYTHON_VER_MINOR=12
ARG PYTHON_VER_PATCH=5

ENV PYTHON_VERSION="${PYTHON_VER_MAJOR}.${PYTHON_VER_MINOR}.${PYTHON_VER_PATCH}"
ENV PYENV_VERSION="${PYENV_VER_MAJOR}.${PYENV_VER_MINOR}.${PYENV_VER_PATCH}"
ENV PYENV_GIT_TAG="v${PYENV_VERSION}"

RUN mkdir --parents --mode 0700 ${APP_HOME}/.ssh && \
    chown --recursive ${APP_USER}:${APP_GROUP} ${APP_HOME}/.ssh && \
    /usr/bin/env bash ${APP_BIN}/setup_known_hosts.sh

# Set-up necessary Env vars for PyEnv
ENV PYENV_ROOT=${APP_HOME}/.pyenv
ENV PATH=${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}

RUN ${APP_BIN}/install_pyenv.sh

FROM install-pyenv AS logger

# Optional: Verify package installation from cache without internet
RUN --network=none \
    dpkg -l | grep -E 'locales|cmake|python3' > ${APP_LOGS}/packages.log

RUN printenv | sort > ${APP_LOGS}/environment.log

# Log the current git configuration.
RUN git config --list --show-origin > ${APP_LOGS}/gitconfig.log

RUN dpkg --get-selections > ${APP_LOGS}/installed_packages.log

# Log the current APT configuration.
RUN apt-config dump > ${APP_LOGS}/apt-config.log

RUN pyenv --version > ${APP_LOGS}/pyenv.log

FROM logger AS base

# Switch to the non-root user.
USER ${APP_USER}:${APP_GROUP}

VOLUME [ "/home/app/data" ]
VOLUME [ "/home/app/config" ]
VOLUME [ "/home/app/logs" ]

# Reset to default shell for runtime
SHELL ["/bin/bash", "-c"]

# Set Bash as the entry point to keep the container running.
ENTRYPOINT [ "bash", "-c", "tail -f /dev/null" ]

# Runtime commands
CMD ["bash"]

# Healthcheck to ensure the container is running.
HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --start-period=5s \
    --retries=3 \
    CMD ${APP_BIN}/healthcheck.sh
