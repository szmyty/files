#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# remove_dangerous_commands.sh: Script to remove potentially dangerous
# commands from critical system directories.
#
# This script searches for and deletes specific commands considered
# dangerous in directories like /bin, /etc, /lib, /sbin, and /usr.
#
# Usage:
#   ./remove_dangerous_commands.sh
#
# Author: Alan Szmyt
##########################################################################

##########################################################################
# remove_dangerous_commands: Removes dangerous commands from specified directories.
#
# This function iterates over critical system directories and removes
# commands that are considered potentially dangerous. It ensures that
# only specified commands are deleted, avoiding the removal of necessary tools.
#
# Usage:
#   remove_dangerous_commands
#
# Arguments:
#   None
#
# Returns:
#   0 if all dangerous commands are removed successfully.
#   1 if an error occurs during the removal process.
##########################################################################
function remove_dangerous_commands() {
    # Array of directories to search for dangerous commands.
    local _directories=("/bin" "/etc" "/lib" "/sbin" "/usr")

    printf "Removing potentially dangerous commands from critical system directories...\n"

    # Call the function to delete the dangerous commands
    delete_dangerous_commands "${_directories[@]}" || {
        printf "Error: Failed to remove dangerous commands.\n" >&2
        return 1
    }

    printf "Dangerous commands have been removed.\n"
}

##########################################################################
# delete_dangerous_commands: Finds and deletes specified dangerous commands.
#
# This function searches through the provided directories for a list of
# dangerous commands and deletes them. It uses ssh-keyscan to locate and
# remove the commands, ensuring the system remains secure.
#
# Usage:
#   delete_dangerous_commands "/bin" "/etc"
#
# Arguments:
#   $@ - A list of directories to search for dangerous commands.
#
# Returns:
#   0 if all specified dangerous commands are deleted successfully.
#   1 if an error occurs during the deletion process.
##########################################################################
function delete_dangerous_commands() {
    # Array of directories to search for dangerous commands.
    local _dirs=("$@")

    # The list of dangerous commands to be removed.
    local _commands=("hexdump" "chgrp" "chown" "ln" "od" "strings" "su" "sudo")

    # Use find to locate and delete the dangerous commands.
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
        printf "Failed to delete one or more dangerous commands.\n" >&2
        exit 1
    }
}

##########################################################################
# main: Main function to orchestrate the removal of dangerous commands.
#
# This function calls remove_dangerous_commands to initiate the process
# of deleting potentially dangerous commands from critical system directories.
#
# Usage:
#   main
##########################################################################
function main() {
    remove_dangerous_commands
}

# Execute the main function.
main

# Exit the script with a successful status code.
exit 0
