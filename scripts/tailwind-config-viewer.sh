#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Get the absolute path to this script.
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Get the project's root directory relative to the script.
_PROJECT_DIR="$(cd "${_SCRIPT_DIR}/.." &> /dev/null && pwd)"

# Set the path to the developer experience (dx) .env file.
_DX_ENV_FILE="${_PROJECT_DIR}/dx.env"

# Set the path to the Tailwind CSS configuration file.
_PROJECT_TAILWIND_CONFIG_FILE="${_PROJECT_DIR}/tailwind.config.ts"

# Set the path to the Tailwind CSS output directory.
_OUTPUT_DIR="${_PROJECT_DIR}/.cache/tailwind"

# Set the path to the Tailwind CSS types output directory.
_DECLARATION_DIR="${_OUTPUT_DIR}/types"

# Set the path to the compiled Tailwind CSS configuration file.
_COMPILED_TAILWIND_CONFIG_FILE="${_OUTPUT_DIR}/tailwind.config.js"

# Set the port for the Tailwind CSS configuration viewer.
_TAILWIND_CONFIG_VIEWER_PORT="${TAILWIND_CONFIG_VIEWER_PORT:-5030}"

function build_tailwind_config() {
  printf "Building Tailwind CSS configuration file...\n"

  pnpm exec dotenv \
    -e "${_DX_ENV_FILE}" \
    -- pnpm exec \
    tsc "${_PROJECT_TAILWIND_CONFIG_FILE}" \
    --types jest,node \
    --esModuleInterop \
    --allowSyntheticDefaultImports \
    --declaration \
    --declarationDir "${_DECLARATION_DIR}" \
    --outDir "${_OUTPUT_DIR}" \
    --module CommonJS
}

function serve_tailwind_config() {
    printf "Serving Tailwind CSS configuration file viewer...\n"

    pnpm exec dotenv \
        -e "${_DX_ENV_FILE}" \
        -- pnpm exec npx \
        tailwind-config-viewer \
        --config "${_COMPILED_TAILWIND_CONFIG_FILE}" \
        serve \
        --port "${_TAILWIND_CONFIG_VIEWER_PORT}" \
        --open
}

function main() {
    build_tailwind_config
    serve_tailwind_config
}

# Execute the main function.
main

# Exit the script with a successful status code.
exit 0
