#!/usr/bin/env bash

function add_known_hosts() {
    local domains=("gitlab.com" "github.com")
    for domain in "${domains[@]}"; do
        ssh-keyscan "${domain}" >>"${HOME}/.ssh/known_hosts" || true
    done
}

######################################################################
# @brief        Main function to orchestrate the locale setup.
#
# @details      Installs the required packages and configures the locale
#               on the system.
######################################################################
function main() {
    add_known_hosts
}

# Execute the main function
main

exit 0
