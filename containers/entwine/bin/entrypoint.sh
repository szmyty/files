#!/usr/bin/env bash
set -euo pipefail

######################################################################
# @Project      : app
# @File         : entrypoint
# @Description  : Default entrypoint script for containers in the app
#                 project. This script serves as a template or default entrypoint
#                 that can be overridden by specific containers. It ensures
#                 proper setup and execution of the container's main process.
#
# @Author       : Alan Szmyt
######################################################################

exec \
    entwine \
    "${@}"
