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

# Project name.
ARG PROJECT_NAME=app

# Image name to use.
ARG BASE_IMAGE_NAME=base

# Image version to use.
ARG BASE_IMAGE_VERSION=latest

ARG REDIS_VERSION=6.2.6
ARG REDIS_PORT=6379
ARG REDIS_DATA_DIR=

# Use a base image.
FROM ${PROJECT_NAME}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}

# Ensure the build process uses the root user.
# USER root


