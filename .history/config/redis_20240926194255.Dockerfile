# syntax=docker/dockerfile:1

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
######################################################################

# Use a base image, for example, Debian or Ubuntu
FROM debian:latest

# Set the shell options for safer script execution
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

# Ensure the build process uses the root user
USER root

# Set environment variables for APP_HOME, APP_BIN, and APP_CONFIG
ENV APP_HOME=/sanctuary
ENV APP_BIN=${APP_HOME}/bin
ENV APP_CONFIG=${APP_HOME}/config

# Copy apt.conf and dpkg.cfg to their respective locations
COPY apt.conf /etc/apt/apt.conf.d/99custom-apt.conf
COPY dpkg.cfg /etc/dpkg/dpkg.cfg.d/99custom-dpkg.cfg

# Copy the package list to the container
COPY package.list /tmp/package.list

# Update package lists and install packages from package.list
RUN apt-get update \
    && xargs -a /tmp/package.list apt-get install \
    && rm -rf /var/lib/apt/lists/*

# Optionally remove the package list file after installation
RUN rm /tmp/package.list

# Create a non-root user with specific configurations
RUN groupadd \
    --gid ${SANCTUARY_GID} \
    ${SANCTUARY_GROUP} \
    && useradd \
    --no-log-init \
    --create-home \
    --uid ${SANCTUARY_UID} \
    --gid ${SANCTUARY_GID} \
    --comment "Non-root User for Running Applications" \
    --home /home/${SANCTUARY_USER} \
    --skel /etc/skel \
    --shell /sbin/nologin \
    # --expiredate 2025-12-31 \
    ${SANCTUARY_USER}

# Copy the scripts from the local bin directory to the container's bin directory
COPY bin ${SANCTUARY_BIN}

# Make sure the scripts are executable
RUN chmod +x ${SANCTUARY_BIN}/*

RUN ${SANCTUARY_BIN}/script1.sh
RUN ${SANCTUARY_BIN}/script2.sh
RUN ${SANCTUARY_BIN}/script3.sh
