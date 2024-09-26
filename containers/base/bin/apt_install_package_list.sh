#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# File: apt_install_package_list.sh
#
# Purpose: Install Debian packages listed in a package list file.
#
# Description: This script reads a package list file, extracts the package names,
# and installs them using apt-get. The script handles comments and empty lines,
# ensuring only valid package names are installed.
#
# Author: Alan Szmyt
# -----------------------------------------------------------------------------

# Check if the package list file is provided as an argument
if [[ "$#" -ne 1 ]]; then
    echo "Usage: ${0} <path_to_package_list>"
    exit 1
fi

# Define the package list file path from the CLI argument
package_list="$1"

# Define the regex pattern for filtering out comments and empty lines
regex_pattern='^\s*(#|$)'

# Function to extract package names from the package list and store them in an array
get_package_names() {
    mapfile -t package_names < <(grep --invert-match --extended-regexp "${regex_pattern}" "${package_list}" | cut --delimiter=' ' --fields=1)
}

# Update apt-get and install packages from the package list
{
    apt-get update
    get_package_names
    apt-get install -y "${package_names[@]}"
} || {
    echo "Failed to install packages from ${package_list}" >&2
    exit 1
}

# Clean up the apt cache
rm -rf /var/lib/apt/lists/*
