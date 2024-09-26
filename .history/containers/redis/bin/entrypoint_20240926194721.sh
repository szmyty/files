#!/usr/bin/env bash
######################################################################
# @Project      : sanctuary
# @File         : entrypoint
# @Description  : Default entrypoint script for containers in the sanctuary
#                 project. This script serves as a template or default entrypoint
#                 that can be overridden by specific containers. It ensures
#                 proper setup and execution of the container's main process.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-23
# @Version      : 1.0
######################################################################

# Best practices for entrypoints:
# - Use `#!/usr/bin/env bash` for portability.
# - Set the script to fail on errors, unset variables, and pipe failures using `set -euo pipefail`.
# - Always execute setup scripts or any necessary pre-run configuration before the main process.
# - Use `exec "$@"` to replace the shell with the main container process. This ensures that signals are properly forwarded to the process.

# Fail on error, unset variable, or pipe failure.
set -euo pipefail

# Run additional setup.
# This script is a placeholder for any setup commands that need to be executed
# before the container's main process is started. Containers can override or extend
# this script as needed.
bash "${APP_BIN:-}/setup.sh"

# Replace the shell with the main container process.
# This allows the container to receive signals directly and shutdown gracefully.
exec "${@}"
