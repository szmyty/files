#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# File: remove_dangerous_commands.sh
#
# Purpose: Remove potentially dangerous commands from critical system directories.
#
# Description: This script searches for and deletes specific commands considered
#              dangerous in directories like /bin, /etc, /lib, /sbin, and /usr.
#
# Usage: ./remove_dangerous_commands.sh
#
# Author: Alan Szmyt
# -----------------------------------------------------------------------------
# Best Practices:
# - Make sure this file is executable: `chmod +x remove_dangerous_commands.sh`
# - Run the script as root or with sufficient privileges to modify system directories.
# - Be cautious with the list of commands to ensure you are not removing necessary tools.
# -----------------------------------------------------------------------------

# Function to remove dangerous commands from specified directories
remove_dangerous_commands() {
    local _directories=("/bin" "/etc" "/lib" "/sbin" "/usr")

    echo "Removing potentially dangerous commands from critical system directories."

    # Call the function to delete the dangerous commands
    delete_dangerous_commands "${_directories[@]}"

    echo "Dangerous commands have been removed."
}

# Function to find and delete the specified dangerous commands
delete_dangerous_commands() {
    local _dirs=("$@")

    # The list of dangerous commands to be removed
    local _commands=("hexdump" "chgrp" "chown" "ln" "od" "strings" "su" "sudo")

    # Use find to locate and delete the dangerous commands
    find "${_dirs[@]}" -xdev \( \
        -name "${_commands[0]}" -o \
        -name "${_commands[1]}" -o \
        -name "${_commands[2]}" -o \
        -name "${_commands[3]}" -o \
        -name "${_commands[4]}" -o \
        -name "${_commands[5]}" -o \
        -name "${_commands[6]}" -o \
        -name "${_commands[7]}" \
    \) -delete || {
        echo "Failed to delete one or more dangerous commands." >&2
        exit 1
    }
}

# Main function to execute the script logic
main() {
    remove_dangerous_commands
}

# Call the main function
main
