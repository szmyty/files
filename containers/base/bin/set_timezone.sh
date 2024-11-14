#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# set_timezone.sh: Script to set the timezone on a Debian-based system
#
# This script sets the timezone based on the TZ environment variable or
# defaults to UTC. It ensures that the 'tzdata' package is installed,
# validates the specified timezone, and applies the timezone settings.
#
# Project: app
# Author: Alan Szmyt
# Date: 2024-08-30
##########################################################################
# Best Practices:
# - Make sure this file is executable: `chmod +x set_timezone.sh`.
# - Run the script as root or with sufficient privileges to modify system directories.
# - Be cautious with the timezone value to ensure it is valid.
##########################################################################

##########################################################################
# is_package_installed: Checks if a given package is installed on the system.
#
# This function uses 'dpkg-query' to determine if the specified package
# is installed. It returns 0 if the package is installed and 1 otherwise.
#
# Usage:
#   is_package_installed "package-name"
#
# Arguments:
#   $1 - The name of the package to check.
#
# Returns:
#   0 if the package is installed.
#   1 if the package is not installed.
#
# See also:
#   https://man7.org/linux/man-pages/man1/dpkg-query.1.html
##########################################################################
function is_package_installed() {
    # The name of the package to check.
    local _package="$1"

    # Retrieve the installation status of the package.
    local _package_status
    _package_status=$(dpkg-query --show --showformat='${Status}\n' "${_package}" 2>/dev/null)

    # Check if the package is installed.
    if printf "%s" _package_status | grep --quiet "install ok installed"; then
        printf "Package '%s' is already installed." _package
        return 0
    else
        printf "Package '%s' is not installed." _package
        return 1
    fi
}

##########################################################################
# update_package_list: Updates the package list for apt-get.
#
# This function runs 'apt-get update' to refresh the package index,
# ensuring that the latest package versions are available for installation.
#
# Usage:
#   update_package_list
##########################################################################
function update_package_list() {
    apt-get update --quiet
}

##########################################################################
# is_valid_timezone: Validates if the specified timezone exists on the system.
#
# This function checks the existence of the timezone file in '/usr/share/zoneinfo'.
# It returns 0 if the timezone file exists and 1 if it does not.
#
# Usage:
#   is_valid_timezone "Timezone"
#
# Arguments:
#   $1 - The timezone to validate.
#
# Returns:
#   0 if the timezone is valid.
#   1 if the timezone is invalid.
#
# See also:
#   https://man7.org/linux/man-pages/man1/zoneinfo.5.html
##########################################################################
function is_valid_timezone() {
    # The timezone to validate.
    local _timezone="$1"

    if [[ -f "/usr/share/zoneinfo/${_timezone}" ]]; then
        return 0
    else
        return 1
    fi
}

##########################################################################
# install_package_if_missing: Installs a specified package if it is not already installed.
#
# This function checks whether a given package is installed on the system.
# If the package is not installed, it proceeds to install it using apt-get.
#
# Usage:
#   install_package_if_missing "package-name"
#
# Arguments:
#   $1 - The name of the package to check and install.
#
# Returns:
#   0 if the package is already installed or was successfully installed.
#   1 if the installation failed.
##########################################################################
function install_package_if_missing() {
    # The name of the package to install.
    local _package="$1"

    if is_package_installed "${_package}"; then
        printf "Proceeding since the package '%s' is installed." _package
    else
        printf "Installing the '%s' package..." _package
        apt-get install --yes "${_package}" || return 1
    fi
}

##########################################################################
# validate_timezone: Validates the specified timezone and exits if invalid.
#
# This function checks whether the given timezone is valid using the
# `is_valid_timezone` function. If the timezone is invalid, it prints an
# error message and exits with a non-zero status.
#
# Usage:
#   validate_timezone "timezone"
#
# Arguments:
#   $1 - The timezone to validate.
#
# Returns:
#   None. Exits with a non-zero status if the timezone is invalid.
##########################################################################
function validate_timezone() {
    # The timezone to validate.
    local _timezone="$1"

    # Validate the timezone using the `is_valid_timezone` function.
    if ! is_valid_timezone "${_timezone}"; then
        printf "Invalid timezone: %s\n" "${_timezone}" >&2
        exit 1
    fi
}

##########################################################################
# set_system_timezone: Sets the system timezone to the specified value.
#
# This function creates a symbolic link to the appropriate timezone file
# and updates the '/etc/timezone' file. It also reconfigures 'tzdata' to
# apply the changes.
#
# Usage:
#   set_system_timezone "Timezone"
#
# Arguments:
#   $1 - The timezone to set.
#
# Returns:
#   0 if the timezone is set successfully.
#   1 if an error occurs during the process.
#
# See also:
#   https://man7.org/linux/man-pages/man1/ln.1.html
#   https://man7.org/linux/man-pages/man8/update-locale.8.html
#   https://man7.org/linux/man-pages/man8/dpkg-reconfigure.8.html
##########################################################################
function set_system_timezone() {
    # The timezone to set.
    local _timezone="$1"

    # Validate the timezone.
    validate_timezone _timezone

    # Commit change: Update the timezone.
    printf "Setting timezone to %s." _timezone

    # Create a symbolic link to the appropriate timezone file.
    ln -sf "/usr/share/zoneinfo/${_timezone}" /etc/localtime || {
        printf "Error: Failed to create symbolic link for timezone." >&2
        return 1
    }

    # Update /etc/timezone.
    printf "%s" _timezone >/etc/timezone || {
        printf "Error: Failed to write to /etc/timezone." >&2
        return 1
    }

    # Reconfigure tzdata to apply changes.
    dpkg-reconfigure --frontend=noninteractive tzdata || {
        printf "Error: Failed to reconfigure tzdata." >&2
        return 1
    }

    # Final confirmation.
    printf "Timezone has been set to %s." _timezone
    printf "You may want to restart any long-running services or daemons to apply the new timezone settings."
}

##########################################################################
# main: Main function to orchestrate the timezone setup.
#
# This function installs the required packages and sets the timezone
# on the system based on the TZ environment variable or defaults to UTC.
#
# Usage:
#   main
##########################################################################
function main() {
    # Update package lists.
    update_package_list

    # Check if the 'tzdata' package is installed, install if not.
    install_package_if_missing "tzdata"

    # Set the default timezone if TZ is not set.
    local _timezone="${TZ:-UTC}"

    # Set the system timezone.
    set_system_timezone "${_timezone}"
}

# Execute the main function.
main

# Exit the script with a successful status code.
exit 0
