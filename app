#!/usr/bin/env bash
# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr

######################################################################
# @Project      : app
# @File         : app
# @Description  : Bash script to bring up the Docker Compose services
#                 for the project. This script is designed
#                 to be easily expandable as more services are added
#                 to the project.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-22
# @Version      : 1.0
# @References   :
#   - https://www.gnu.org/software/bash/
#   - https://www.gnu.org/software/bash/manual/bash.html
#   - https://docs.docker.com/compose/cli-command/
#   - https://docs.docker.com/compose/compose-file/
#   - https://docs.docker.com/compose/reference/overview/
#   - http://redsymbol.net/articles/unofficial-bash-strict-mode/
#   - https://www.shellcheck.net/
#   - https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
#   - https://tldp.org/LDP/abs/html/
#   - https://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html
#   - https://man7.org/linux/man-pages/man7/signal.7.html
#   - http://redsymbol.net/articles/bash-exit-traps/
#   - https://mywiki.wooledge.org/BashGuide/Practices
#   - https://bertvv.github.io/cheat-sheets/Bash.html
#   - https://google.github.io/styleguide/shellguide.html
#   - https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
#   - https://docs.docker.com/build/building/variables/
#   - https://docs.docker.com/build/building/secrets/
#   - https://docs.docker.com/build/building/base-images/
#   - https://no-color.org/
#   - https://ftp.gnu.org/gnu/aspell/dict/0index.html
#
# @Notes        :
#   Built-In Variables
#   For reference
#   $0   name of the script
#   $n   positional parameters to script/function
#   $$   PID of the script
#   $!    PID of the last command executed (and run in the background)
#   $?   exit status of the last command  (${PIPESTATUS} for pipelined commands)
#   $#   number of parameters to script/function
#   $@  all parameters to script/function (sees arguments as separate word)
#   $*    all parameters to script/function (sees arguments as single word)
#   Note
#   $*   is rarely the right choice.
#   $@ handles empty parameter list and white-space within parameters correctly
######################################################################
IFS=$'\n\t'

daemon_file="/etc/docker/daemon.json"

#######################################
# Log messages depending on the log level.
# This function logs messages based on the project's log level. It will only log messages
# that have a level greater than or equal to the current project log level.
#
# Globals:
#   PROJECT_LOG_LEVEL (int): Controls the verbosity of the logs. Default is 3 (INFO).
# Arguments:
#   $1: Log level of the message (DEBUG, INFO, WARNING, ERROR).
#   $2: Log message to output.
# Outputs:
#   Writes log messages to stdout or stderr depending on the log level.
# Returns:
#   0: Always returns 0 (success).
#######################################
function log() {
    local LEVELS=("ERROR" "WARNING" "INFO" "DEBUG")
    local LOG_LEVEL="${1}"
    local MESSAGE="${2}"

    # Set default log level if not set (INFO level, which is 3)
    local PROJECT_LOG_LEVEL="${PROJECT_LOG_LEVEL:-2}"

    # Convert log level to a numeric value
    local LOG_LEVEL_NUM=0
    for _level in "${!LEVELS[@]}"; do
        if [[ "${LEVELS[${_level}]}" == "${LOG_LEVEL}" ]]; then
            LOG_LEVEL_NUM="${_level}"
            break
        fi
    done

    # Log only if the log level is greater than or equal to the project log level
    if [[ "${LOG_LEVEL_NUM}" -le "${PROJECT_LOG_LEVEL}" ]]; then
        # Output to stderr for WARNING and ERROR, otherwise stdout
        if [[ "${LOG_LEVEL}" == "WARNING" || "${LOG_LEVEL}" == "ERROR" ]]; then
            echo "[${LOG_LEVEL}] ${MESSAGE}" >&2
        else
            echo "[${LOG_LEVEL}] ${MESSAGE}"
        fi
    fi
}

#######################################
# Log an error message.
# This function logs an error message with the "ERROR" log level.
#
# Globals:
#   PROJECT_LOG_LEVEL (int): The current project log level.
# Arguments:
#   $*: The message to log.
# Outputs:
#   Writes the log message to stderr.
# Returns:
#   0: Always returns 0 (success).
#######################################
function log::error() {
    log "ERROR" "$*"
}

#######################################
# Log a warning message.
# This function logs a warning message with the "WARNING" log level.
#
# Globals:
#   PROJECT_LOG_LEVEL (int): The current project log level.
# Arguments:
#   $*: The message to log.
# Outputs:
#   Writes the log message to stderr.
# Returns:
#   0: Always returns 0 (success).
#######################################
function log::warning() {
    log "WARNING" "$*"
}

#######################################
# Log an informational message.
# This function logs an info message with the "INFO" log level.
#
# Globals:
#   PROJECT_LOG_LEVEL (int): The current project log level.
# Arguments:
#   $*: The message to log.
# Outputs:
#   Writes the log message to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function log::info() {
    log "INFO" "$*"
}

#######################################
# Log a debug message.
# This function logs a debug message with the "DEBUG" log level.
#
# Globals:
#   PROJECT_LOG_LEVEL (int): The current project log level.
# Arguments:
#   $*: The message to log.
# Outputs:
#   Writes the log message to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function log::debug() {
    log "DEBUG" "$*"
}

#######################################
# Custom realpath function to resolve absolute path.
# This function mimics the behavior of `realpath` using built-in Bash commands.
#
# Arguments:
#   $1: Path to resolve.
# Outputs:
#   Writes the absolute path of the file or directory to stdout.
# Returns:
#   0: If successful.
#   1: If the path does not exist.
#######################################
function realpath() {
    local _target_file="${1}"

    # Check if the file/directory exists
    if [[ ! -e "${_target_file}" ]]; then
        echo "Error: '${_target_file}' does not exist." >&2
        return 1
    fi

    # Resolve symbolic links if necessary
    while [[ -h "${_target_file}" ]]; do
        local _link
        _link=$(readlink "${_target_file}")

        # If the symlink is relative, resolve relative to the directory of the symlink
        if [[ "${_link}" != /* ]]; then
            _target_file="$(dirname "${_target_file}")/${_link}"
        else
            _target_file="${_link}"
        fi
    done

    # Get the absolute directory of the target file
    local _absolute_directory
    _absolute_directory=$(cd "$(dirname "${_target_file}")" && pwd)

    # Return the full absolute path
    echo "${_absolute_directory}/$(basename "${_target_file}")"
}

#######################################
# Check if a given command is available in the system.
# Globals:
#   None
# Arguments:
#   _command (string) : The name of the command to check.
# Outputs:
#   Returns 0 if the command is available, 1 if not.
#######################################
function app::has_command() {
    local _command="${1}"
    if command -v "${_command}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

#######################################
# Check if the current script is being sourced.
# This function checks whether the current script is being sourced or executed.
# If the script is sourced, it will return 0 (true); if executed, it will return 1 (false).
#
# Globals:
#   BASH_SOURCE (array): Array of sourced filenames (bash-specific).
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0: If the script is being sourced.
#   1: If the script is being executed directly.
#######################################
function app::is_sourced() {
    # If the script is sourced, BASH_SOURCE[0] will be different from $0
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        return 0  # Sourced
    else
        return 1  # Executed directly
    fi
}

#######################################
# Enable errtrace for error trap handler inheritance.
# This function ensures that the error trap handler is inherited by all functions and
# subshells within the script. Without enabling errtrace, error trapping won't work as expected
# in subshells or function calls.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0: Always returns 0 (success).
# References:
#   - https://stackoverflow.com/a/28776166/8787985
#######################################
function app::enable_errtrace() {
    set -o errtrace
}

#######################################
# Get script path details and assign them to variables.
# Outputs:
#   SCRIPT_PATH: Full absolute path to the script.
#   SCRIPT_DIR: Directory containing the script.
#   SCRIPT_NAME: Script file name with extension.
#   SCRIPT_NAME_NO_EXT: Script file name without extension.
#   SCRIPT_EXT: Script file extension.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_script_info() {
    readonly ORIGINAL_CWD="${PWD}"
    readonly SCRIPT_OPTIONS="$*"

    # Full path of the script
    SCRIPT_PATH=$(realpath "$0")

    # Directory containing the script
    SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")

    # Script file name with extension
    SCRIPT_NAME=$(basename "${SCRIPT_PATH}")

    # Script file name without extension
    SCRIPT_NAME_NO_EXT="${SCRIPT_NAME%.*}"

    # Script file extension
    SCRIPT_EXT="${SCRIPT_NAME##*.}"

    readonly SCRIPT_DIR SCRIPT_NAME SCRIPT_PATH SCRIPT_NAME_NO_EXT SCRIPT_EXT

    # Display the information (optional)
    printf "SCRIPT_PATH: %s" "${SCRIPT_PATH}"
    printf "SCRIPT_DIR: %s" "${SCRIPT_DIR}"
    printf "SCRIPT_NAME_WITH_EXT: %s" "${SCRIPT_NAME}"
    printf "SCRIPT_NAME_NO_EXT: %s" "${SCRIPT_NAME_NO_EXT}"
    printf "SCRIPT_EXT: %s" "${SCRIPT_EXT}"
}

function app::error_handler() {
    local _exit_code=1

    # Disable the error trap handler to prevent potential recursion.
    trap - ERR

    # Consider any further errors non-fatal to ensure we run to completion.
    set +o errexit
    set +o pipefail

    # Validate any provided exit code.
    if [[ ${1-} =~ ^[0-9]+$ ]]; then
        _exit_code="${1}"
    fi

    # Output debug data if in Cron mode.
    if [[ -n ${cron-} ]]; then
        # Restore original file output descriptors
        if [[ -n ${script_output-} ]]; then
            exec 1>&3 2>&4
        fi

        # Print basic debugging information
        printf '***** Abnormal termination of script *****\n'
        printf 'Script Path:            %s\n' "${SCRIPT_PATH}"
        printf 'Script Parameters:      %s\n' "${SCRIPT_OPTIONS}"
        printf 'Script Exit Code:       %s\n' "${_exit_code}"

        # Print the script log if we have it. It's possible we may not if we
        # failed before we even called cron_init(). This can happen if bad
        # parameters were passed to the script so we bailed out very early.
        if [[ -n ${script_output-} ]]; then
            # shellcheck disable=SC2312
            printf 'Script Output:\n\n%s' "$(cat "${script_output}")"
        else
            printf 'Script Output:          None (failed before log init)\n'
        fi
    fi

    # Exit with failure status.
    exit "${_exit_code}"
}

function app::exit_handler() {
    cd "${ORIGINAL_CWD}"

    # Remove Cron mode script log.
    if [[ -n ${cron-} && -f ${script_output-} ]]; then
        rm "${script_output}"
    fi

    # Remove script execution lock
    if [[ -d ${script_lock-} ]]; then
        rmdir "${script_lock}"
    fi

    # Restore terminal colours
    # printf '%b' "${ta_none}"
}

#######################################
# Print all environment variables in alphabetical order.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes sorted environment variables to stdout.
#######################################
function app::print_environment() {
    printenv | sort
}

#######################################
# Load environment variables from a .env file, ignoring comments and empty lines.
# Globals:
#   None
# Arguments:
#   _env_file (string): Path to the .env file.
# Outputs:
#   Exports environment variables from the file to the shell.
#   Prints an error message if the file is not found.
# Returns:
#   0: If environment variables are successfully loaded.
#   1: If the .env file is not found.
#######################################
function app::load_env_file() {
    local _env_file="${1}"

    if [[ -f "${_env_file}" ]]; then
        # Process each line that is not a comment or empty
        while IFS='=' read -r key value; do
            # Remove any part after a '#' symbol (inline comments) using parameter expansion
            value="${value%%#*}"

            # Strip leading/trailing spaces from key and value
            key=$(echo "${key}" | xargs)
            value=$(echo "${value}" | xargs)

            # Ignore empty keys or values
            if [[ -n "${key}" && -n "${value}" ]]; then
                echo "key: ${key} value: ${value}"
                export "${key}"="${value}"
            fi
        done < <(grep -v '^#' "${_env_file}")  # Redirection to avoid subshell

        # For debugging, you can print the environment variables
        printenv | sort
    else
        echo ".env file not found: ${_env_file}"
        return 1
    fi
}

#######################################
# Find the Docker executable and construct the Docker command with optional debug flags.
# Globals:
#   PROJECT_DEBUG (optional): If set to 1, Docker debug mode is enabled.
# Arguments:
#   None
# Outputs:
#   Writes the Docker executable path to stdout.
#   Exports the constructed Docker command to be used globally.
# Returns:
#   0: If Docker is found and the command is constructed.
#   1: If Docker is not installed or not in the PATH.
#######################################
function app::find_docker() {
    # Find the Docker executable path
    local _docker_path
    _docker_path=$(command -v docker)
    if [[ -z "${_docker_path}" ]]; then
        echo "Docker is not installed or not in the PATH."
        return 1
    fi

    echo "Docker found at: ${_docker_path}"

    # Start constructing the Docker command
    local _docker_cmd="${_docker_path}"

    # Check if debug is enabled via environment variable
    if [[ "${PROJECT_DEBUG:-0}" -eq 1 ]]; then
        echo "Enabling Docker debug mode."
        docker_command=("${_docker_cmd}" --debug --log-level "debug")
    else
        docker_command=("${_docker_cmd}")
    fi

    # Export the docker command so it can be used globally in the script
    export docker_command
}

#######################################
# Wrapper function to execute the Docker command with optional arguments.
# Globals:
#   docker_command: The Docker command constructed by the find_docker function.
# Arguments:
#   ${@}: All arguments passed to this function are forwarded to the Docker command.
# Outputs:
#   Executes the Docker command with the provided arguments and outputs the result.
# Returns:
#   The return code of the Docker command execution.
#######################################
function app::docker() {
    ${docker_command} "${@}"
}

#######################################
# Get the operating system running Docker.
# Outputs:
#   Prints the operating system running Docker to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_operating_system() {
    app::docker info --format "{{.OperatingSystem}}"
}

#######################################
# Get the Containerd version used by Docker.
# Outputs:
#   Prints the Containerd version used by Docker to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_containerd_version() {
    app::docker info --format "{{.ContainerdCommit.ID}}"
}

#######################################
# Get the Docker root directory where Docker stores container data.
# Outputs:
#   Prints the Docker root directory to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_docker_root_dir() {
    app::docker info --format "{{.DockerRootDir}}"
}

#######################################
# Get the number of currently running containers.
# Outputs:
#   Prints the number of running containers to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_running_containers() {
    app::docker info --format "{{.ContainersRunning}}"
}

#######################################
# Get the total number of Docker images on the system.
# Outputs:
#   Prints the total number of images to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_total_images() {
    app::docker info --format "{{.Images}}"
}

#######################################
# Get the status of the Docker storage driver.
# Outputs:
#   Prints the Docker storage driver status to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_driver_status() {
    app::docker info --format "{{ .DriverStatus }}"
}

#######################################
# Get the OS of the Docker client.
# Outputs:
#   Prints the OS of the Docker client to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_client_os() {
    app::docker version --format "{{.Client.Os}}"
}

#######################################
# Get the architecture of the Docker client.
# Outputs:
#   Prints the architecture of the Docker client to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_client_arch() {
    app::docker version --format "{{.Client.Arch}}"
}

#######################################
# Get the context of the Docker client.
# Outputs:
#   Prints the current context of the Docker client to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_client_context() {
    app::docker version --format "{{.Client.Context}}"
}

#######################################
# Get the version of the Docker client.
# Outputs:
#   Prints the version of the Docker client to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::get_client_version() {
    app::docker version --format "{{.Client.Version}}"
}

#######################################
# Gather and print key Docker system information.
# This function gathers various Docker system details by calling the appropriate getter functions.
#
# Outputs:
#   Displays Docker system information to stdout.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::gather_docker_info() {
    # shellcheck disable=SC2310
    printf "Operating System: %s\n" "$(app::get_operating_system || true)"

    # shellcheck disable=SC2310
    printf "Containerd Version: %s\n" "$(app::get_containerd_version || true)"

    # shellcheck disable=SC2310
    printf "Docker Root Directory: %s\n" "$(app::get_docker_root_dir || true)"

    # shellcheck disable=SC2310
    printf "Running Containers: %s\n" "$(app::get_running_containers || true)"

    # shellcheck disable=SC2310
    printf "Total Images: %s\n" "$(app::get_total_images || true)"

    # shellcheck disable=SC2310
    printf "Driver Status: %s\n" "$(app::get_driver_status || true)"

    # shellcheck disable=SC2310
    printf "Client OS: %s\n" "$(app::get_client_os || true)"

    # shellcheck disable=SC2310
    printf "Client Arch: %s\n" "$(app::get_client_arch || true)"

    # shellcheck disable=SC2310
    printf "Client Context: %s\n" "$(app::get_client_context || true)"

    # shellcheck disable=SC2310
    printf "Client Version: %s\n" "$(app::get_client_version || true)"
}

#######################################
# Check if Docker is running on Docker Desktop.
# This function checks whether Docker is running on Docker Desktop by comparing
# the `operating_system` variable. Returns 0 if Docker Desktop is detected, otherwise returns 1.
#
# Globals:
#   operating_system: The operating system running Docker (set by app::gather_docker_info).
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0: If Docker is running on Docker Desktop.
#   1: If Docker is running on a different operating system.
#######################################
function app::is_docker_desktop() {
    # Check if running on Docker Desktop or a Linux system with Docker Engine
    # shellcheck disable=SC2310
    if [[ $(app::get_operating_system || true) == "Docker Desktop" ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Check if Docker is running in rootless mode.
# This function uses `docker info` to check if Docker is running in rootless mode
# by examining the "rootless" field in the output.
#
# Globals:
#   docker_command (function): The Docker command constructed by find_docker.
# Arguments:
#   None
# Outputs:
#   Writes whether Docker is running in rootless mode or not to stdout.
# Returns:
#   0: If Docker is running in rootless mode.
#   1: If Docker is not running in rootless mode.
#######################################
function app::is_docker_rootless() {
    # Use `docker info` to check if Docker is rootless
    # shellcheck disable=SC2310
    if app::docker info --format "{{.SecurityOptions}}" | grep -q "rootless"; then
        echo "Docker is running in rootless mode."
        return 0
    else
        echo "Docker is not running in rootless mode."
        return 1
    fi
}

# Function to check and modify docker daemon.json and restart the Docker service.
# TODO
function app::configure_containerd_snapshotter() {
    local _containerd_snapshotter_setting=".features[\"containerd-snapshotter\"]"

    # Check if daemon.json exists, if not create it
    if [[ ! -f "${daemon_file}" ]]; then
        echo "Docker daemon.json not found. Creating a new one."
        echo '{"features": {"containerd-snapshotter": true}}' > "${daemon_file}"
    else
        # Check if 'containerd-snapshotter' is set to true in the daemon.json
        if ! jq --exit-status "${_containerd_snapshotter_setting} == true" "${daemon_file}" >/dev/null 2>&1; then
            echo "Setting 'containerd-snapshotter' to true in Docker daemon.json."
            # Modify or add the 'containerd-snapshotter' setting to true
            jq "${_containerd_snapshotter_setting} |= true" "${daemon_file}" > "/tmp/daemon.json" && mv "/tmp/daemon.json" "${daemon_file}"
        else
            echo "'containerd-snapshotter' is already enabled."
        fi
    fi

    # Restart the Docker service
    echo "Restarting Docker service..."
    systemctl restart docker.service

    # Wait for Docker to be back up
    echo "Waiting for Docker service to restart..."
    # shellcheck disable=SC2310
    until app::docker info >/dev/null 2>&1; do
        sleep 1
    done

    # Verify that the 'containerd-snapshotter' is in use
    # shellcheck disable=SC2310
    if app::docker info --format '{{ .DriverStatus }}' | grep -q "driver-type io.containerd.snapshotter.v1"; then
        echo "The containerd snapshotter is in use."
    else
        echo "Failed to verify that the containerd snapshotter is in use."
        return 1
    fi
}

# Function to create/update and switch to a Docker context based on the project name
function app::configure_docker_context() {
    # Ensure COMPOSE_PROJECT_NAME is set
    if [[ -z "${COMPOSE_PROJECT_NAME}" ]]; then
        echo "COMPOSE_PROJECT_NAME is not set. Please set it and try again."
        return 1
    fi

    # Define the context name and Docker endpoint
    local _context_name="${COMPOSE_PROJECT_NAME}-context"
    local _docker_host="${DOCKER_HOST:-unix:///var/run/docker.sock}"

    # Check if the context already exists
    # shellcheck disable=SC2310
    if app::docker context ls --format "{{.Name}}" | grep -q "^${_context_name}$"; then
        echo "Docker context '${_context_name}' already exists."

        # Get the current endpoint for the existing context
        local _current_endpoint
        _current_endpoint=$(app::docker context inspect "${_context_name}" --format '{{.Endpoints.docker.Host}}')

        # Check if the current endpoint matches the desired one
        if [[ "${_current_endpoint}" != "${_docker_host}" ]]; then
            echo "Docker endpoint has changed. Updating context '${_context_name}' to use new Docker host: ${_docker_host}"
            # Update the existing context with the new Docker endpoint
            app::docker context update "${_context_name}" --docker "host=${_docker_host}"
        else
            echo "Docker endpoint is already set to ${_docker_host}. No update needed."
        fi
    else
        echo "Docker context '${_context_name}' does not exist. Creating it..."
        # Create a new context with the specified Docker host
        app::docker context create --docker "host=${_docker_host}" "${_context_name}"
    fi

    # Switch to the new or updated context
    echo "Switching to Docker context '${_context_name}'..."
    docker context use "${_context_name}"

    # Confirm the current context
    local _current_context
    _current_context=$(docker context show)
    if [[ "${_current_context}" == "${_context_name}" ]]; then
        echo "Successfully switched to Docker context '${_context_name}'."
    else
        echo "Failed to switch Docker context."
        return 1
    fi
}

#######################################
# Check if containerd is active in Docker.
# This function checks whether Docker is using containerd as the container runtime
# by inspecting the output of the `docker info` command.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0: If containerd is active.
#   1: If containerd is not active or Docker is not running.
#######################################
function app::is_containerd_active() {
    # Check if containerd is active
    # shellcheck disable=SC2310
    if app::docker info | grep -q "containerd"; then
        return 0
    else
        return 1
    fi
}

# Function to ensure containerd is enabled and running.
# TODO
function app::ensure_containerd_enabled() {
    echo "Checking the current status of containerd..."
}

# Function to check and ensure Docker Swarm is initialized
function app::ensure_docker_swarm() {
    # shellcheck disable=SC2310
    if ! app::docker info | grep -q 'Swarm: active'; then
        echo "Docker Swarm is not active. Initializing Docker Swarm..."
        docker swarm init || {
            echo "Failed to initialize Docker Swarm."
            exit 1
        }
        echo "Docker Swarm has been successfully initialized."
    else
        echo "Docker Swarm is already active."
    fi
}

# Function to check if the Docker buildx builder exists and create it if necessary
function app::ensure_buildx_builder() {
    local _builder_name
    _builder_name="${1}"

    # shellcheck disable=SC2310
    if app::docker buildx inspect "${_builder_name}" > /dev/null 2>&1; then
        echo "Builder '${_builder_name}' already exists. Setting it as the default builder."
    else
        echo "Builder '${_builder_name}' does not exist. Creating and setting it as the default builder."
        app::docker buildx create \
            --name "${_builder_name}" \
            --node "${_builder_name}-node" \
            --driver "docker-container" \
            --driver-opt "default-load=true" \
            --use \
            --bootstrap
        echo "Builder '${_builder_name}' created and set as default."
    fi
    app::docker buildx use "${_builder_name}"
}

function app::configure_buildx() {
    export DOCKER_DEFAULT_PLATFORM="${client_os}/${client_arch}"

    echo "${DOCKER_DEFAULT_PLATFORM}"

    app::ensure_buildx_builder "${BUILDX_BUILDER:-"app-container-builder"}"
}

#######################################
# Build the base Docker image using Docker Compose.
# This function runs the Docker Compose build command to build the base image.
# It uses the specified compose file, environment files, and builds the 'base' service.
#
# Globals:
#   CONTAINERS_ROOT (optional): The root directory where container configurations are stored.
# Arguments:
#   None
# Outputs:
#   Runs Docker Compose to build the base image and displays the progress.
# Returns:
#   The exit status of the Docker Compose build command.
#######################################
function app::build_base_image() {
    app::docker compose \
        --file app.yml \
        --env-file app.env \
        --env-file "${CONTAINERS_ROOT:-containers}"/base/base.env \
        --parallel 1 \
        --ansi auto \
        --progress plain \
        build base
}

#######################################
# Deploy a local Docker registry using Docker Compose.
# This function sets up and starts a local Docker registry by navigating to the registry directory,
# creating necessary data and config directories, and then launching the registry container
# using Docker Compose.
#
# Globals:
#   CONTAINERS_ROOT (optional): The root directory where container configurations are stored.
# Arguments:
#   None
# Outputs:
#   Deploys the Docker registry service in detached mode using Docker Compose.
# Returns:
#   The exit status of the Docker Compose `up` command.
#######################################
function app::deploy_local_registry() {
    cd "${CONTAINERS_ROOT:-containers}/registry" && \
        mkdir --parents "${PWD}/data" && \
        mkdir --parents "${PWD}/config" && \
        app::docker compose \
            --file registry.yml \
            --env-file registry.env \
            --parallel 1 \
            --ansi auto \
            --progress plain \
            up --detach registry
}

function app::start_services() {
    # Array of services to bring up. Add more services here as needed.
    services=("matchering")

        # "--env-file" "containers/redis/redis.env"
        # "--env-file" "containers/tiledb/tiledb.env"
        # "--env-file" "containers/minio/minio.env"

    # Base Docker Compose command, broken into multiple lines for readability.
    cmd=(
        "app::docker" "compose"
        "--file" "app.yml"
        "--env-file" "app.env"
        "--env-file" "containers/base/base.env"
        "--env-file" "containers/matchering/matchering.env"
        "--parallel" "1"
        "--ansi" "auto"
        "up"
        "--build"
        "--force-recreate"
        "--remove-orphans"
    )
    # Add services to the command, with --no-deps to skip dependency services.
    for service in "${services[@]}"; do
        cmd+=("--no-deps" "${service}")
    done

    # Append any additional arguments passed to the script.
    cmd+=("$@")

    # Echo the final command for visibility.
    echo "Executing: ${cmd[*]}"

    # Execute the final command.
    "${cmd[@]}"
}

function app::load_environment() {
    app::load_env_file "app.env"
    app::load_env_file "${CONTAINERS_ROOT:-.}/base/base.env"
    app::load_env_file "${CONTAINERS_ROOT:-.}/matchering/matchering.env"
    app::print_environment
}

#######################################
# Enable xtrace (debugging) if PROJECT_DEBUG is set.
# This function enables xtrace (i.e., command tracing) if the PROJECT_DEBUG environment variable
# is set to 1, yes, or true.
#
# Globals:
#   PROJECT_DEBUG (optional): Enables xtrace if set to 1, yes, or true.
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::configure_xtrace() {
    # Enable xtrace if the PROJECT_DEBUG environment variable is set to 1, yes, or true
    if [[ "${PROJECT_DEBUG:-0}" =~ ^1|yes|true$ ]]; then
        set -o xtrace
    fi
}

#######################################
# Configure shell options for safer script execution.
# This function sets strict shell options to ensure that errors are caught and handled properly.
# It should only be executed, not sourced, to avoid unintended side effects.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Prints an error message if the script is sourced instead of executed.
# Returns:
#   0: If shell options are successfully set.
#   1: If the script is sourced (must be executed instead).
#######################################
function app::configure_shell_options() {
    # shellcheck disable=SC2310
    if app::is_sourced; then
        echo "This script must be executed, not sourced."
        return 1
    fi

    # Exit on most errors (see the manual)
    set -o errexit

    # Disallow expansion of unset variables
    set -o nounset

    # Use last non-zero exit code in a pipeline
    set -o pipefail
}

#######################################
# Print usage information for the script.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes usage information to stdout.
#######################################
function usage() {
    echo "Usage: $0 [OPTIONS] <positional-argument>"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message and exit"
    echo "  -v, --verbose        Enable verbose mode"
    echo "  -o, --output <file>  Specify output file"
    echo ""
    echo "Positional arguments:"
    echo "  <positional-argument> A required positional argument"
}

#######################################
# Parse command-line options and arguments.
# Globals:
#   None
# Arguments:
#   ${@}: Command-line options and arguments.
# Outputs:
#   None
# Returns:
#   0 if all options are successfully parsed.
#   1 if an error occurs while parsing.
#######################################
function parse_options() {
    local positional_arg=""
    local verbose=0
    local output_file=""

    # Parse options using `getopts` for short options and manual parsing for long options
    while [[ "${#}" -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -o|--output)
                if [[ -n "${2}" && "${2}" != -* ]]; then
                    output_file="${2}"
                    shift 2
                else
                    echo "Error: --output requires a non-empty argument."
                    usage
                    exit 1
                fi
                ;;
            --) # End of options
                shift
                break
                ;;
            -*) # Unknown option
                echo "Error: Unknown option: ${1}"
                usage
                exit 1
                ;;
            *) # Positional argument
                positional_arg="${1}"
                shift
                ;;
        esac
    done

    # Check if the required positional argument is provided
    if [[ -z "${positional_arg}" ]]; then
        echo "Error: A positional argument is required."
        usage
        exit 1
    fi

    # Display the parsed options and arguments (for demonstration)
    echo "Verbose mode: ${verbose}"
    echo "Output file: ${output_file}"
    echo "Positional argument: ${positional_arg}"
}

#######################################
# Configure script with shell options and debugging features.
# This function sets up essential configurations for the script by calling other functions
# to enable xtrace, configure strict shell options, and ensure errtrace is enabled.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Configures the shell environment for script execution.
# Returns:
#   0: Always returns 0 (success).
#######################################
function app::configure_script() {
    app::configure_xtrace
    app::configure_shell_options
    app::enable_errtrace
}

function app::init() {
    app::configure_script
    app::load_environment
    app::get_script_info "$@"
}

function setup() {
    app::find_docker
    app::configure_docker_context
    app::gather_docker_info
    app::ensure_containerd_enabled
    app::configure_buildx
    # app::deploy_local_registry TODO add conditional
}

#######################################
# Run Docker Buildx bake with specific options.
# This function executes the `docker buildx bake` command using an app-specific configuration,
# and passes any additional arguments to the command. The bake command is used for defining
# and executing complex build definitions.
#
# Globals:
#   None
# Arguments:
#   ${@}: Additional arguments to pass to the `docker buildx bake` command.
# Outputs:
#   Runs the Docker Buildx bake command with specified options and arguments.
# Returns:
#   The exit status of the `docker buildx bake` command.
#######################################
function app::bake() {
    app::docker buildx bake \
        --progress plain \
        --file app.yml \
        --metadata-file app.metadata.json \
        --load \
        "${@}"
}

function main() {
    trap app::error_handler ERR
    trap app::exit_handler EXIT

    app::init "$@"

    app::print_environment

    # setup
    # build_base_image

    # BASE_IMAGE_ID=$(app::docker inspect --format='{{.Id}}' app/base:1.0)
    # export BASE_IMAGE_ID

    # bake "${@}"
    # start_services "${@}"
}

# shellcheck disable=SC2310
if ! app::is_sourced; then
    main "$@"
fi
