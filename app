#!/usr/bin/env bash

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
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
IFS=$'\n\t'

daemon_file="/etc/docker/daemon.json"

function has_command() {
    local _command="${1}"
    if command -v "${_command}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function print_environment() {
    echo "Environment Variables:"
    printenv | sort
}

# Function to load environment variables from a .env file, ignoring comments and empty lines
function load_env_file() {
    local _env_file="${1}"

    if [[ -f "${_env_file}" ]]; then
        # Export each line from the file that is not a comment or empty
        while IFS='=' read -r key value; do
            # Remove any part after a '#' symbol (inline comments)
            value=$(echo "${value}" | sed 's/#.*//')

            # Strip leading/trailing spaces from key and value
            key=$(echo "${key}" | xargs)
            value=$(echo "${value}" | xargs)

            # Ignore empty keys or values
            if [[ -n "${key}" && -n "${value}" ]]; then
                export "${key}"="${value}"
            fi
        done < <(grep -v '^#' "${_env_file}")
    else
        echo ".env file not found: ${_env_file}"
        return 1
    fi
}

# Function to setup Docker command with optional debug flags
function find_docker() {
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
        docker_command=("${_docker_cmd}" --debug --log-level \"debug\")
    else
        docker_command=("${_docker_cmd}")
    fi

    # Export the docker command so it can be used globally in the script
    export docker_command
}

function app::docker() {
    ${docker_command} "${@}"
}

function gather_docker_info() {
    # Extract information using docker info --format
    operating_system=$(app::docker info --format "{{.OperatingSystem}}")
    containerd_version=$(app::docker info --format "{{.ContainerdCommit.ID}}")
    docker_root_dir=$(app::docker info --format "{{.DockerRootDir}}")
    running_containers=$(app::docker info --format "{{.ContainersRunning}}")
    total_images=$(app::docker info --format "{{.Images}}")
    driver_status=$(app::docker info --format "{{ .DriverStatus }}")
    client_os=$(app::docker version --format "{{.Client.Os}}")
    client_arch=$(app::docker version --format "{{.Client.Arch}}")
    client_context=$(app::docker version --format "{{.Client.Context}}")
    client_version=$(app::docker version --format "{{.Client.Version}}")

    export \
        operating_system \
        containerd_version \
        docker_root_dir \
        running_containers \
        total_images \
        driver_status \
        client_os \
        client_arch \
        client_context \
        client_version

    # Display the extracted information
    printf "Operating System: %s\n", "${operating_system}"
    echo "Containerd Version: ${containerd_version}"
    echo "Docker Root Directory: ${docker_root_dir}"
    echo "Running Containers: ${running_containers}"
    echo "Total Images: ${total_images}"
    echo "Driver Status: ${driver_status}"
    echo "Client OS: ${client_os}"
    echo "Client Arch: ${client_arch}"
    echo "Client Context: ${client_context}"
    echo "Client Version: ${client_version}"
}

function is_docker_desktop() {
    # Check if running on Docker Desktop or a Linux system with Docker Engine
    if [[ ${operating_system} == "Docker Desktop" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if Docker is running in rootless mode
# TODO
function is_docker_rootless() {
    if "${rootless}" | grep -q "true"; then
        echo "Docker is running in rootless mode."
        return 0
    else
        echo "Docker is not running in rootless mode."
        return 1
    fi
}

# Function to check and modify docker daemon.json and restart the Docker service.
# TODO
function configure_containerd_snapshotter() {
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
    until app::docker info >/dev/null 2>&1; do
        sleep 1
    done

    # Verify that the 'containerd-snapshotter' is in use
    if app::docker info --format '{{ .DriverStatus }}' | grep -q "driver-type io.containerd.snapshotter.v1"; then
        echo "The containerd snapshotter is in use."
    else
        echo "Failed to verify that the containerd snapshotter is in use."
        return 1
    fi
}

# Function to create/update and switch to a Docker context based on the project name
configure_docker_context() {
    # Ensure COMPOSE_PROJECT_NAME is set
    if [[ -z "${COMPOSE_PROJECT_NAME}" ]]; then
        echo "COMPOSE_PROJECT_NAME is not set. Please set it and try again."
        return 1
    fi

    # Define the context name and Docker endpoint
    local _context_name="${COMPOSE_PROJECT_NAME}-context"
    local _docker_host="${DOCKER_HOST:-unix:///var/run/docker.sock}"

    # Check if the context already exists
    if app::docker context ls --format '{{.Name}}' | grep -q "^${_context_name}$"; then
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


function is_containerd_active() {
    # Check if containerd is active
    if app::docker info | grep -q 'containerd'; then
        return 0
    else
        return 1
    fi
}

# Function to ensure containerd is enabled and running. TODO
function ensure_containerd_enabled() {
    echo "Checking the current status of containerd..."

    # Check if containerd is active
    # if is_containerd_active; then
    #     echo "Containerd is already active."
    # else
    #     echo "Containerd is not active. Attempting to start containerd..."
    #     sudo systemctl start containerd

    #     # Enable containerd to start at boot
    #     sudo systemctl enable containerd
    #     echo "Containerd has been started and enabled."
    # fi

    # # Check if running on Docker Desktop or a Linux system with Docker Engine
    # if is_docker_desktop; then
    #     # Docker Desktop (MacOS)
    #     echo "Docker Desktop detected."

    #     # Command to check if containerd is active in Docker Desktop
    #     # Docker Desktop should manage containerd automatically; manual intervention is not typical
    #     # if ! app::docker info | grep -q 'containerd'; then
    #     #     echo "Containerd appears to be inactive or not properly configured in Docker Desktop."
    #     #     echo "Please check Docker Desktop settings or restart Docker."
    #     # else
    #     #     echo "Containerd is active in Docker Desktop."
    #     # fi
    # elif command -v systemctl &> /dev/null; then
    #     # Linux Docker Engine
    #     echo "Systemd found, assuming Linux environment with Docker Engine."

    #     # Check if containerd service is active
    #     if ! systemctl is-active --quiet containerd.service; then
    #         echo "Containerd is not active. Attempting to start containerd..."
    #         sudo systemctl start containerd

    #         # Enable containerd to start at boot
    #         sudo systemctl enable containerd
    #         echo "Containerd has been started and enabled."
    #     else
    #         echo "Containerd is already active and running."
    #     fi
    # else
    #     echo "Neither Docker Desktop nor a standard Linux Docker Engine environment detected."
    #     echo "Manual verification required."
    # fi
}

# Function to check and ensure Docker Swarm is initialized
function ensure_docker_swarm() {
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
function ensure_buildx_builder() {
    local _builder_name
    _builder_name="${1}"

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

function configure_buildx() {
    export DOCKER_DEFAULT_PLATFORM="${client_os}/${client_arch}"

    echo "${DOCKER_DEFAULT_PLATFORM}"

    ensure_buildx_builder "${BUILDX_BUILDER:-"app-container-builder"}"
}

function build_base_image() {
    app::docker compose \
        --file app.yml \
        --env-file app.env \
        --env-file containers/base/base.env \
        --parallel 1 \
        --ansi auto \
        --progress plain \
        build base
}

function start_services() {
    # Array of services to bring up. Add more services here as needed.
    services=("tiledb")

    # Base Docker Compose command, broken into multiple lines for readability.
    cmd=(
        "app::docker" "compose"
        "--file" "app.yml"
        "--env-file" "app.env"
        "--env-file" "containers/base/base.env"
        "--env-file" "containers/redis/redis.env"
        "--env-file" "containers/tiledb/tiledb.env"
        "--env-file" "containers/minio/minio.env"
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

function load_environment() {
    load_env_file "app.env"
    load_env_file "${CONTAINERS_ROOT:-.}/base/base.env"
    print_environment
}

function setup() {
    load_environment
    find_docker
    configure_docker_context
    gather_docker_info
    ensure_containerd_enabled
    configure_buildx
}

function bake() {
    app::docker buildx bake \
        --progress plain \
        --file app.yml \
        --metadata-file app.metadata.json \
        "${@}"
}

# if [[ "${TRACE-0}" == "1" ]];

function main() {
    setup
    bake "${@}"
    # build_base_image
    # start_services
}

main "$@"