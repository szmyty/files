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

######################################################################
# Stage 1: Base Image Setup
######################################################################
ARG BASE_IMAGE_VERSION=0.1.0

# Use the official Debian image as the base image.
ARG DEBIAN_IMAGE_VERSION=bookworm-20240926-slim

# Extend from the official Debian image to set up the base image.
FROM debian:${DEBIAN_IMAGE_VERSION} AS setup

######################################################################
# Labels using OCI conventions and incorporating ARG variables.
#
# References:
#   - https://github.com/opencontainers/image-spec/blob/latest/annotations.md
#   - https://specs.opencontainers.org/image-spec/annotations/
######################################################################
LABEL \
    org.opencontainers.image.authors="Alan Szmyt" \
    org.opencontainers.image.url="https://example.com/myimage" \
    org.opencontainers.image.documentation="https://example.com/myimage/docs" \
    org.opencontainers.image.source="https://github.com/example/myimage" \
    org.opencontainers.image.version=${BASE_IMAGE_VERSION} \
    org.opencontainers.image.vendor="Example, Inc." \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="${COMPOSE_PROJECT_NAME}" \
    org.opencontainers.image.description="This image is used for..." \
    org.opencontainers.image.base.name="debian:bookworm"

######################################################################
# Arguments (with default values)
######################################################################

# Set the temporary directory.
ARG TMPDIR=/tmp

# Define the default system language.
ARG LANG=en_US.UTF-8

# Specify the language preferences.
ARG LANGUAGE=en_US:en

# Set the timezone.
ARG TZ=UTC

# Ensure Python outputs are unbuffered.
ARG PYTHONUNBUFFERED=1

# Define the encoding used by Python I/O.
ARG PYTHONIOENCODING=UTF-8

# Enable Python fault handler for better error reports.
ARG PYTHONFAULTHANDLER=1

# Seed the Python hash function for reproducibility.
ARG PYTHONHASHSEED=random

# Enable UTF-8 mode in Python.
ARG PYTHONUTF8=1

# Increase Python verbosity for more detailed logs.
ARG PYTHONVERBOSE=1

# Disable pip's cache directory to reduce image size.
ARG PIP_NO_CACHE_DIR=off

# Disable pip's version check to speed up installations.
ARG PIP_DISABLE_PIP_VERSION_CHECK=on

# Set the default timeout for pip operations.
ARG PIP_DEFAULT_TIMEOUT=100

# Suppress warnings about script locations in pip.
ARG PIP_NO_WARN_SCRIPT_LOCATION=on

# Disable weak cryptography in GNUTLS.
ARG GNUTLS_FORCE_FIPS_MODE=1

# Set the compiler flags for optimization.
ARG CFLAGS=-O2

# Configure Debian to run in non-interactive mode.
ARG DEBIAN_FRONTEND=noninteractive

# Indicate that non-interactive mode has been acknowledged by debconf.
ARG DEBCONF_NONINTERACTIVE_SEEN=true

# Set the priority level for Debian package configurations.
ARG DEBIAN_PRIORITY=critical

# Suppress warnings in debconf.
ARG DEBCONF_NOWARNINGS=yes

# Define the terminal type with 256-color support.
ARG TERM=xterm-256color

# Disable the frontend for APT list changes.
ARG APT_LISTCHANGES_FRONTEND=none

# Disable the frontend for APT list bugs.
ARG APT_LISTBUGS_FRONTEND=none

# Prevent Perl documentation from being installed.
ARG NOPERLDOC=1

######################################################################
# Environment Variables
######################################################################

# Set the application user.
ENV APP_USER=app

# Set the application group.
ENV APP_GROUP=app

# Assign the user ID for the application user.
ENV APP_UID=65532

# Assign the group ID for the application group.
ENV APP_GID=65532

# Define the home directory for the application user.
ENV APP_HOME=/home/${APP_USER}

# Set the binary directory for the application.
ENV APP_BIN=${APP_HOME}/bin

# Define the configuration directory for the application.
ENV APP_CONFIG=${APP_HOME}/config

# Set the logs directory for the application.
ENV APP_LOGS=${APP_HOME}/logs

# Define the data directory for the application.
ENV APP_DATA=${APP_HOME}/data

# Update the PATH environment variable to include the application binary directory.
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${APP_BIN}

######################################################################
# Set the arguments to the environment variables.
######################################################################
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    DEBCONF_NONINTERACTIVE_SEEN=${DEBCONF_NONINTERACTIVE_SEEN} \
    DEBIAN_PRIORITY=${DEBIAN_PRIORITY} \
    DEBCONF_NOWARNINGS=${DEBCONF_NOWARNINGS} \
    TERM=${TERM} \
    APT_LISTCHANGES_FRONTEND=${APT_LISTCHANGES_FRONTEND} \
    APT_LISTBUGS_FRONTEND=${APT_LISTBUGS_FRONTEND} \
    NOPERLDOC=${NOPERLDOC} \
    CFLAGS=${CFLAGS} \
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
    GNUTLS_FORCE_FIPS_MODE=${GNUTLS_FORCE_FIPS_MODE} \
    GIT_CONFIG=${APP_CONFIG}/.gitconfig

# Ensure the build process uses the root user.
USER root

# Set safer shell options for script execution.
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

# Create necessary directories and set permissions.
RUN mkdir --parents ${APP_HOME} ${APP_BIN} ${APP_CONFIG} ${APP_LOGS} ${APP_DATA}

# Create a non-root user with specific configurations.
# Set ownership to the app user and group.
# Set permissions: read, write, and execute for owner, and read-only for group and others.
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
    --shell /usr/sbin/nologin ${APP_USER} \
    && chown --recursive ${APP_USER}:${APP_GROUP} ${APP_HOME} \
    && chmod --recursive 700 ${APP_HOME} \
    && chmod --recursive 755 ${APP_BIN}

# Set the working directory to the app home directory.
WORKDIR ${APP_HOME}

# Copy the scripts from the local bin directory to the container's bin directory.
# chmod 500: Grants read and execute permissions to the owner, no permissions to group and others.
COPY --chown=${APP_USER}:${APP_GROUP} --chmod=500 bin ${APP_BIN}

# Copy the Git config file to for the app user.
COPY --chown=${APP_USER}:${APP_GROUP} --chmod=644 config/.gitconfig ${GIT_CONFIG}

# Copy the gitconfig file to the root user's home directory.
RUN cp ${GIT_CONFIG} /home/root/.gitconfig

# Copy apt.conf and dpkg.cfg to their respective locations.
# chmod 644: Grants read and write permissions to the owner, and read-only permissions to group and others.
COPY --chown=root:root --chmod=644  config/apt.conf /etc/apt/apt.conf.d/99docker-apt.conf
COPY --chown=root:root --chmod=644  config/dpkg.cfg /etc/dpkg/dpkg.cfg.d/99docker-dpkg.cfg

# Copy the Git config file to a common location accessible by all users.
COPY --chown=root:root --chmod=644 config/.gitconfig ${GIT_CONFIG}

# Disable the automatic removal of downloaded packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir --parents /usr/share/man/man1

######################################################################
# Stage 2: Install Packages
######################################################################
FROM setup AS apt-install

# Install packages using cached directories and configure locale and timezone.
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

######################################################################
# Stage 3: Install pyenv
######################################################################
FROM apt-install AS install-pyenv

# Set stage labels for the pyenv installation.
LABEL stage="install-pyenv"
LABEL description="Stage to install pyenv from source."

# Set the pyenv version and repository URL.
ARG PYENV_VER_MAJOR=2
ARG PYENV_VER_MINOR=4
ARG PYENV_VER_PATCH=14
ARG PYENV_REPO_URL="https://github.com/pyenv/pyenv.git"

# Set the Python version to install.
ARG PYTHON_VER_MAJOR=3
ARG PYTHON_VER_MINOR=12
ARG PYTHON_VER_PATCH=5

# Set the environment variables for pyenv and Python.
ENV PYTHON_VERSION="${PYTHON_VER_MAJOR}.${PYTHON_VER_MINOR}.${PYTHON_VER_PATCH}"
ENV PYENV_VERSION="${PYENV_VER_MAJOR}.${PYENV_VER_MINOR}.${PYENV_VER_PATCH}"
ENV PYENV_GIT_TAG="v${PYENV_VERSION}"

# Copy the scripts for setting up known hosts and installing pyenv.
RUN mkdir --parents --mode 0700 ${APP_HOME}/.ssh && \
    chown --recursive ${APP_USER}:${APP_GROUP} ${APP_HOME}/.ssh && \
    /usr/bin/env bash ${APP_BIN}/add_known_hosts.sh

# Setup necessary Env variables for pyenv.
ENV PYENV_ROOT=${APP_HOME}/.pyenv
ENV PATH=${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}

# Install pyenv from source.
RUN ${APP_BIN}/install_pyenv.sh

######################################################################
# Stage 4: Debug Logging
######################################################################
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

######################################################################
# Stage 3: Final Image
######################################################################
FROM logger AS base

# Switch to the non-root user.
USER ${APP_USER}:${APP_GROUP}

# Set volume for the application data, configuration, and logs.
VOLUME [ "/home/app/data" ]
VOLUME [ "/home/app/config" ]
VOLUME [ "/home/app/logs" ]

# Reset to default shell for runtime.
SHELL ["/bin/bash", "-c"]

# Set Bash as the entry point to keep the container running.
ENTRYPOINT [ "bash", "-c", "tail -f /dev/null" ]

# Runtime commands.
CMD ["bash"]

# Healthcheck to ensure the container is running.
HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --start-period=5s \
    --retries=3 \
    CMD ${APP_BIN}/healthcheck.sh
