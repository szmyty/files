#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# apt_install_package_list.sh: Install Debian packages from a package list.
#
# This script reads a package list file, extracts package names,
# and installs them using apt-get. Comments and empty lines in the file
# are ignored to ensure only valid package names are processed.
#
# Usage:
#   ./apt_install_package_list.sh <path_to_package_list>
#
# Author: Alan Szmyt
##########################################################################

##########################################################################
# print_usage: Prints the usage instructions for the script.
#
# This function displays the correct usage of the script when an invalid
# number of arguments is provided.
#
# Usage:
#   print_usage
#
# Arguments:
#   None
#
# Returns:
#   None
##########################################################################
function print_usage() {
    printf "Usage: %s <path_to_package_list>\n" "${0}"
}

##########################################################################
# validate_arguments: Validates the number of arguments passed to the script.
#
# This function checks whether exactly one argument is provided. If not,
# it prints the usage instructions and exits with a non-zero status.
#
# Usage:
#   validate_arguments "$@"
#
# Arguments:
#   $@ - All command-line arguments passed to the script.
#
# Returns:
#   None. Exits with a non-zero status if validation fails.
##########################################################################
function validate_arguments() {
    if [[ "$#" -ne 1 ]]; then
        print_usage
        exit 1
    fi
}

##########################################################################
# get_package_names: Extracts package names from the package list file.
#
# This function reads the package list file, ignoring comments and empty
# lines, and stores the package names in a global array.
#
# Usage:
#   get_package_names
#
# Globals:
#   _package_list   (in)  Path to the package list file.
#   _regex_pattern  (in)  Regex pattern to filter out comments and empty lines.
#   _delimiter      (in)  Delimiter used to extract package names.
#   package_names   (out) Array containing the extracted package names.
#
# Arguments:
#   None
#
# Returns:
#   None
##########################################################################
function get_package_names() {
    mapfile -t package_names < <(\
        grep \
            --invert-match \
            --extended-regexp "${_regex_pattern}" "${_package_list}" \
            | cut --delimiter="${_delimiter}" --fields=1
    )
}

##########################################################################
# update_and_install_packages: Updates apt-get and installs packages.
#
# This function updates the apt package index and installs the packages
# listed in the `package_names` array.
#
# Usage:
#   update_and_install_packages
#
# Globals:
#   package_names   (in) Array containing the package names to install.
#
# Arguments:
#   None
#
# Returns:
#   None. Exits with a non-zero status if any step fails.
##########################################################################
function update_and_install_packages() {
    apt-get update
    apt-get install --yes "${package_names[@]}" || {
        printf "Failed to install packages from %s\n" "${_package_list}" >&2
        exit 1
    }
}

##########################################################################
# clean_apt_cache: Cleans the apt cache.
#
# This function removes cached package files to free up disk space
# after the installation process is complete.
#
# Usage:
#   clean_apt_cache
#
# Arguments:
#   None
#
# Returns:
#   None
##########################################################################
function clean_apt_cache() {
    rm -rf /var/lib/apt/lists/*
}

##########################################################################
# main: Main function to orchestrate package installation.
#
# This function validates the arguments, extracts package names from the
# package list, installs the packages, and cleans the apt cache.
#
# Usage:
#   main "$@"
#
# Arguments:
#   $@ - All command-line arguments passed to the script.
#
# Returns:
#   None
##########################################################################
function main() {
    # Validate arguments.
    validate_arguments "$@"

    # Define global variables.
    local _package_list="${1}"
    local _delimiter=' '
    local _regex_pattern='^\s*(#|$)'
    declare -a package_names

    # Extract package names and install them.
    get_package_names
    update_and_install_packages

    # Clean up the apt cache.
    clean_apt_cache
}

# Execute the main function.
main "$@"

# Exit the script with a successful status code.
exit 0
