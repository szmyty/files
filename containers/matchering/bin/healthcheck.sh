#!/usr/bin/env bash

# @file healthcheck.sh
# @brief Health check script for verifying TileDB and TileDB-Py installations.
#
# This script checks the installation of the TileDB C library and the TileDB Python module
# to ensure they are correctly installed and match the expected versions. The script is intended
# to be used as a health check in a Docker container.

# @version 1.0
# @date 2024-08-23
# @author Alan Szmyt

# @section LICENSE
# Licensed under the MIT License.

# Exit immediately if a command exits with a non-zero status.
set -euox pipefail

# Set the expected versions of TileDB and TileDB-Py.
TILEDB_VERSION=${TILEDB_VERSION:-"2.25.0"}
TILEDB_PY_VERSION=${TILEDB_PY_VERSION:-"0.31.1"}

# @brief Check if the TileDB C library is installed and the version matches the expected version.
#
# This function verifies that the TileDB C library (`libtiledb.so`) is available in the system
# and that the installed version matches the expected version.
#
# @retval 0 Success.
# @retval 1 Failure.
check_tiledb_c_library() {
    echo "Checking for TileDB C library..."

    # Check if libtiledb.so is available.
    if ! ldconfig -p | grep -q "libtiledb.so"; then
        echo "TileDB C library not found!"
        exit 1
    fi

    # Extract the version of the installed TileDB C library.
    INSTALLED_VERSION=$(tiledb_version)
    if [[ "${INSTALLED_VERSION}" != "${TILEDB_VERSION}" ]]; then
        echo "TileDB C library version mismatch! Expected ${TILEDB_VERSION}, but found ${INSTALLED_VERSION}."
        exit 1
    fi

    echo "TileDB C library version ${INSTALLED_VERSION} is correctly installed."
}

# @brief Check if the TileDB Python module is installed and the version matches the expected version.
#
# This function verifies that the TileDB Python module is installed and that the installed version
# matches the expected version.
#
# @retval 0 Success.
# @retval 1 Failure.
check_tiledb_python_module() {
    echo "Checking for TileDB Python module..."

    # Check if the TileDB Python module can be imported.
    if ! python3 -c "import tiledb" &> /dev/null; then
        echo "TileDB Python module not found!"
        exit 1
    fi

    # Extract the version of the installed TileDB Python module.
    INSTALLED_PY_VERSION=$(python3 -c "import tiledb; print(tiledb.version.version)")
    if [[ "${INSTALLED_PY_VERSION}" != "${TILEDB_PY_VERSION}" ]]; then
        echo "TileDB Python module version mismatch! Expected ${TILEDB_PY_VERSION}, but found ${INSTALLED_PY_VERSION}."
        exit 1
    fi

    echo "TileDB Python module version ${INSTALLED_PY_VERSION} is correctly installed."
}

# @brief Run the health checks for TileDB and TileDB-Py.
#
# This function calls the individual check functions to verify the installations
# of the TileDB C library and TileDB Python module.
#
# @retval 0 All checks passed successfully.
check_health() {
    check_tiledb_c_library
    check_tiledb_python_module

    echo "All health checks passed successfully."
}

# Run the health check.
check_health

exit 0
