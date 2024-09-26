#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# File: remove_crontabs.sh
#
# Purpose: Safely remove existing crontab configurations from the system.
#
# Description: This script removes all crontab-related files and directories
#              from the system, including user-specific crontabs, system-wide
#              crontabs, and periodic cron jobs. It ensures that these
#              directories exist before attempting to remove them to avoid
#              unnecessary errors.
#
# Usage: ./remove_crontabs.sh
#
# Author: Alan Szmyt
# -----------------------------------------------------------------------------
# Best Practices:
# - Make sure this file is executable: `chmod +x remove_crontabs.sh`
# - Run the script as root or with sufficient privileges to modify crontab files.
# - Verify the directories that will be removed before running the script.
# -----------------------------------------------------------------------------

# Function to safely remove a directory if it exists
remove_directory_if_exists() {
    local _dir="${1}"
    if [[ -d "${_dir}" ]]; then
        echo "Removing directory: ${_dir}"
        rm --force --recursive "${_dir}" || {
            echo "Failed to remove directory: ${_dir}" >&2
            exit 1
        }
    else
        echo "Directory does not exist: ${_dir}"
    fi
}

# Function to remove all crontab-related directories
remove_all_crontabs() {
    remove_directory_if_exists "/var/spool/cron"
    remove_directory_if_exists "/etc/crontabs"
    remove_directory_if_exists "/etc/periodic"
}

# Main function to execute the script logic
main() {
    remove_all_crontabs
}

# Call the main function
main
