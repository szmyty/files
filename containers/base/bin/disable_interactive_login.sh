#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# disable_interactive_login.sh: Disable interactive login shell for all users.
#
# This script modifies the /etc/passwd file to replace the login shell of
# all users with /sbin/nologin, effectively preventing interactive logins.
#
# Usage:
#   ./disable_interactive_login.sh
#
# Author: Alan Szmyt
##########################################################################

##########################################################################
# validate_passwd_file: Validates the existence of the /etc/passwd file.
#
# This function checks if the /etc/passwd file exists. If not, it prints
# an error message and exits with a non-zero status.
#
# Usage:
#   validate_passwd_file
#
# Globals:
#   _passwd_file   (in) Path to the /etc/passwd file.
#
# Arguments:
#   None
#
# Returns:
#   None. Exits with a non-zero status if the file does not exist.
##########################################################################
function validate_passwd_file() {
    local _passwd_file="/etc/passwd"

    if [[ ! -f "${_passwd_file}" ]]; then
        printf "Error: %s not found.\n" "${_passwd_file}" >&2
        exit 1
    fi
}

##########################################################################
# replace_login_shell: Replaces the login shell for all users with /sbin/nologin.
#
# This function modifies the /etc/passwd file, replacing the login shell
# (the last field in each line) with /sbin/nologin for all users.
#
# Usage:
#   replace_login_shell "/path/to/passwd"
#
# Arguments:
#   $1 - Path to the /etc/passwd file.
#
# Returns:
#   None. Exits with a non-zero status if sed fails to modify the file.
##########################################################################
function replace_login_shell() {
    local _file="${1}"

    sed --in-place --regexp-extended 's#^(.*):[^:]*$#\1:/sbin/nologin#' "${_file}" || {
        printf "Failed to modify %s.\n" "${_file}" >&2
        exit 1
    }
}

##########################################################################
# disable_interactive_login: Disables interactive login for all users.
#
# This function validates the /etc/passwd file, then calls
# `replace_login_shell` to disable interactive login by changing the login
# shell for all users to /sbin/nologin.
#
# Usage:
#   disable_interactive_login
#
# Globals:
#   _passwd_file   (in) Path to the /etc/passwd file.
#
# Arguments:
#   None
#
# Returns:
#   None. Exits with a non-zero status if any step fails.
##########################################################################
function disable_interactive_login() {
    local _passwd_file="/etc/passwd"

    # Validate the existence of the passwd file.
    validate_passwd_file

    # Disable interactive login for all users.
    printf "Disabling interactive login shell for all users...\n"
    replace_login_shell "${_passwd_file}"
    printf "Interactive login shell has been disabled for all users.\n"
}

##########################################################################
# main: Main function to orchestrate the disabling of interactive login.
#
# This function calls `disable_interactive_login` to initiate the process.
#
# Usage:
#   main
##########################################################################
function main() {
    disable_interactive_login
}

# Execute the main function.
main

# Exit the script with a successful status code.
exit 0
