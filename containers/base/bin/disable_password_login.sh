#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# File: disable_password_login.sh
#
# Purpose: Disable password login for all users on the system.
#
# Description: This script iterates through all the users listed in the
#              /etc/passwd file and disables password login for each user by
#              locking their account. It ensures that the script does not
#              break if any command fails during the iteration.
#
# Usage: ./disable_password_login.sh
#
# Author: Alan Szmyt
# -----------------------------------------------------------------------------
# Best Practices:
# - Make sure this file is executable: `chmod +x disable_password_login.sh`
# - Run the script as root or with sufficient privileges to modify user accounts.
# - Review the list of users affected by this script before running it.
# -----------------------------------------------------------------------------

# Function to lock the password login for a single user
lock_user_password() {
    local _username="$1"
    if ! passwd --lock "${_username}"; then
        echo "Failed to lock password for user: ${_username}" >&2
        exit 1
    fi
}

# Function to iterate through all users and disable their password login
disable_all_password_logins() {
    while IFS=: read -r _username _; do
        lock_user_password "${_username}"
    done < /etc/passwd
}

# Main function to execute the script logic
main() {
    disable_all_password_logins
}

# Call the main function
main
