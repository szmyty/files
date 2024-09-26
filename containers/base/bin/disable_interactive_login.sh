#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# File: disable_interactive_login.sh
#
# Purpose: Disable interactive login shell for all users in the system.
#
# Description: This script modifies the /etc/passwd file to replace the login
#              shell of all users with /sbin/nologin, effectively preventing
#              interactive logins.
#
# Usage: ./disable_interactive_login.sh
#
# Author: Alan Szmyt
# -----------------------------------------------------------------------------
# Best Practices:
# - Make sure this file is executable: `chmod +x disable_interactive_login.sh`
# - Run the script as root or with sufficient privileges to modify /etc/passwd.
# - Backup the /etc/passwd file before running the script.
# -----------------------------------------------------------------------------

# Function to disable interactive login for all users
disable_interactive_login() {
    local _passwd_file="/etc/passwd"

    # Check if the passwd file exists
    if [[ ! -f "${_passwd_file}" ]]; then
        echo "Error: ${_passwd_file} not found." >&2
        exit 1
    fi

    # Replace the login shell of all users with /sbin/nologin
    echo "Disabling interactive login shell for all users."

    # Call the function separately to ensure set -e is respected
    replace_login_shell "${_passwd_file}"

    echo "Interactive login shell has been disabled for all users."
}

# Function to replace the login shell with /sbin/nologin
replace_login_shell() {
    local _file="${1}"

    # This expression finds each line in the /etc/passwd file and replaces the
    # login shell field (the last field) with /sbin/nologin.
    #
    # ^(.*):[^:]*$:
    # - ^(.*): Matches the beginning of the line and captures everything up to the last `:`.
    # - [^:]*: Matches the current shell or last field.
    # - \1:/sbin/nologin: Replaces the last field with /sbin/nologin.
    #
    # If sed fails, it prints an error message and exits.
    sed --in-place --regexp-extended 's#^(.*):[^:]*$#\1:/sbin/nologin#' "${_file}" || {
        echo "Failed to modify ${_file}." >&2
        exit 1
    }
}

# Main function to execute the script logic
main() {
    disable_interactive_login
}

# Call the main function
main
