#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# add_known_hosts.sh: Script to add specified domains to the SSH known_hosts.
#
# This script adds SSH host keys for given domains to the user's known_hosts
# file. It ensures that the specified domains' SSH keys are recognized,
# preventing SSH warnings or prompts during automated operations.
#
# Project: app
# Author: Alan Szmyt
# Date: 2024-08-30
##########################################################################

##########################################################################
# add_known_hosts: Adds specified domains to the SSH known_hosts file.
#
# This function takes a list of domain names as arguments and scans their
# SSH host keys using ssh-keyscan. The scanned keys are appended to the
# user's ~/.ssh/known_hosts file. If the ~/.ssh directory does not exist,
# it is created with appropriate permissions.
#
# Usage:
#   add_known_hosts "github.com" "gitlab.com"
#
# Arguments:
#   $@ - A list of domain names to add to the known_hosts file.
#
# Returns:
#   0 if all domains are processed successfully.
#   1 if an error occurs during directory creation or key scanning.
##########################################################################
function add_known_hosts() {
    # Array of domains to add to known_hosts.
    local _domains=("$@")

    # Ensure the .ssh directory exists with correct permissions.
    if [[ ! -d "${HOME}/.ssh" ]]; then
        mkdir -p "${HOME}/.ssh" || {
            printf "Error: Failed to create ~/.ssh directory.\n"
            return 1
        }
        chmod 700 "${HOME}/.ssh" || {
            printf "Error: Failed to set permissions on ~/.ssh directory.\n"
            return 1
        }
    fi

    for _domain in "${_domains[@]}"; do
        printf "Adding SSH key for '%s' to known_hosts...\n" "${_domain}"
        ssh-keyscan "${_domain}" >> "${HOME}/.ssh/known_hosts" 2>/dev/null || {
            printf "Warning: Failed to scan SSH key for '%s'. Continuing...\n" "${_domain}"
            continue
        }
    done

    printf "All specified domains have been processed.\n"
}

##########################################################################
# main: Main function to orchestrate adding SSH known_hosts.
#
# This function calls add_known_hosts with a predefined list of domains
# to ensure their SSH host keys are added to the known_hosts file.
#
# Usage:
#   main
##########################################################################
function main() {
    add_known_hosts "github.com" "gitlab.com"
}

# Execute the main function.
main

exit 0
