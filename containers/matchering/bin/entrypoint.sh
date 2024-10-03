#!/usr/bin/env bash
######################################################################
# @Project      : app
# @File         : entrypoint
# @Description  : Default entrypoint script for containers in the app
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
/usr/bin/env bash "${APP_BIN:?}/setup.sh"

function substitute_env_vars() {
    # Substitute environment variables in the specified file.
    local _file="$1"
    envsubst < "${_file}" | sponge "${_file}"
}

function update_conf() {
    substitute_env_vars "${APP_CONF:?}/supervisord.conf"
}

function handle_errors() {
    # Print the error message.
    echo "Error on line $1"
    # Exit the script with the error code from the failed command.
    exit "$2"
}

function cleanup() {
    # Perform cleanup tasks here.
    echo "Cleaning up..."
}

function init() {
    # Initialize the environment.
    echo "Initializing..."
    local _file="./.secret_key"
    if [[ -f "${_file}" ]]; then
        echo "Using an existing SECRET_KEY..."
    else
        echo "Generating a new SECRET_KEY..."
        { date +%s | sha256sum | base64 | head -c 50; } > "${_file}"
    fi

    update_conf

    python3 manage.py makemigrations mgw_back
    python3 manage.py migrate
}

# https://docs.docker.com/config/containers/multi-service_container/
function start() {
    # Start the main process.
    exec supervisord \
        --user "${APP_USER:?}:${APP_GROUP:?}" \
        --configuration "${MATCHERING_SUPERVISOR_CONF:?}" \
        --logfile "${APP_LOGS:?}"/supervisord.log \
        "$@"
}

function main() {
    # Initialize the error handler.
    trap handle_errors ERR

    # Initialize the exit handler.
    trap cleanup EXIT

    # Initialize the environment.
    init

    # Run the main process.
    start "$@"
}

main "$@"
