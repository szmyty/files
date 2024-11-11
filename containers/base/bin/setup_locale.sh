#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

###########
# setup_locale.sh: Script to configure the locale for Debian Bookworm and
# check for necessary package installations. The script ensures the required
# locale packages are installed and sets the appropriate locale environment variables.
#
# Project: app
# Author: Alan Szmyt
# Date: 2024-08-30
###########

##########################################################################
# update_package_list: Updates the package list for apt-get.
#
# This function runs 'apt-get update' in quiet mode to refresh the package
# index, ensuring that the latest package versions are available for installation.
#
# Usage:
#   update_package_list
##########################################################################
function update_package_list() {
    apt-get update --quiet
}

##########################################################################
# is_package_installed: Checks if a specific package is installed on the system.
#
# This function verifies whether a given package is installed using dpkg-query.
# If the package is not installed, it prints a message and returns 1.
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
    local _package="${1}"
    local _package_status

    # Retrieve the installation status of the package.
    _package_status=$(dpkg-query --show --showformat='${Status}\n' "${_package}" 2>/dev/null)

    # Check if the package is installed.
    if printf "%s" "${_package_status}" | grep -q "install ok installed"; then
        printf "Package '%s' is already installed.\n" "${_package}"
        return 0
    else
        printf "Package '%s' is not installed.\n" "${_package}"
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
    local _package="${1}"

    if is_package_installed "${_package}"; then
        printf "Proceeding since the package '%s' is installed.\n" "${_package}"
    else
        printf "Installing the '%s' package...\n" "${_package}"
        apt-get install --yes "${_package}" || return 1
    fi
}

##########################################################################
# install_packages_if_missing: Installs multiple packages if they are not already installed.
#
# This function takes a list of package names as arguments and installs each
# one if it is not already present on the system by calling install_package_if_missing.
#
# Usage:
#   install_packages_if_missing "package1" "package2" "package3"
#
# Arguments:
#   $@ - A list of package names to check and install.
#
# Returns:
#   0 if all packages are already installed or were successfully installed.
#   1 if any installation failed.
##########################################################################
function install_packages_if_missing() {
    # Array of packages to install.
    local _packages=("$@")

    for _package in "${_packages[@]}"; do
        install_package_if_missing "${_package}" || return 1
    done
}

##########################################################################
# install_locale_packages: Install necessary packages for locale configuration.
#
# This function installs the 'locales' and 'locales-all' packages if
# they are not already installed on the system.
#
# See also:
#   https://man7.org/linux/man-pages/man8/apt-get.8.html
##########################################################################
function install_locale_packages() {
    # Update the package list.
    update_package_list

    # Install required packages.
    install_packages_if_missing "locales" "locales-all"
}

##########################################################################
# configure_locale: Set the locale configuration for the system.
#
# This function configures the locale based on the environment
# variables or defaults. It determines the appropriate locale,
# updates /etc/locale.gen, generates the locale, and applies
# the locale settings system-wide.
#
# See also:
#   https://man7.org/linux/man-pages/man1/locale-gen.1.html
#   https://man7.org/linux/man-pages/man8/update-locale.8.html
#   https://man7.org/linux/man-pages/man8/dpkg-reconfigure.8.html
##########################################################################
function configure_locale() {
    # Determine the locale based on the priority: LANGUAGE > LC_ALL > LANG
    local _locale="${LANG:-en_US.UTF-8}"
    local _language="${LANGUAGE:-en_US:en}"
    local _lc_ctype="${LC_CTYPE:-${_locale}}"
    local _lc_numeric="${LC_NUMERIC:-${_locale}}"
    local _lc_time="${LC_TIME:-${_locale}}"
    local _lc_collate="${LC_COLLATE:-${_locale}}"
    local _lc_monetary="${LC_MONETARY:-${_locale}}"
    local _lc_messages="${LC_MESSAGES:-${_locale}}"
    local _lc_paper="${LC_PAPER:-${_locale}}"
    local _lc_name="${LC_NAME:-${_locale}}"
    local _lc_address="${LC_ADDRESS:-${_locale}}"
    local _lc_telephone="${LC_TELEPHONE:-${_locale}}"
    local _lc_measurement="${LC_MEASUREMENT:-${_locale}}"
    local _lc_identification="${LC_IDENTIFICATION:-${_locale}}"

    printf "The selected locale is: %s\n" "${_locale}"

    # Uncomment the desired locale in /etc/locale.gen.
    printf "Uncommenting the locale in /etc/locale.gen...\n"
    sed --in-place "/^# *${_locale}/s/^# *//" /etc/locale.gen

    # Generate the selected locale.
    printf "Generating locale...\n"
    locale-gen "${_locale}"

    # Update the system locale configuration.
    update-locale \
        LANG="${_locale}" \
        LANGUAGE="${_language}" \
        LC_CTYPE="${_lc_ctype}" \
        LC_NUMERIC="${_lc_numeric}" \
        LC_TIME="${_lc_time}" \
        LC_COLLATE="${_lc_collate}" \
        LC_MONETARY="${_lc_monetary}" \
        LC_MESSAGES="${_lc_messages}" \
        LC_PAPER="${_lc_paper}" \
        LC_NAME="${_lc_name}" \
        LC_ADDRESS="${_lc_address}" \
        LC_TELEPHONE="${_lc_telephone}" \
        LC_MEASUREMENT="${_lc_measurement}" \
        LC_IDENTIFICATION="${_lc_identification}"

    # Reconfigure the locales package to apply changes.
    dpkg-reconfigure --frontend=noninteractive locales

    printf "Locale configuration completed.\n"
}

##########################################################################
# main: Main function to orchestrate the locale setup.
#
# This function installs the required packages and configures the locale
# on the system.
##########################################################################
function main() {
    install_locale_packages
    configure_locale
}

# Execute the main function.
main

# Exit the script with a successful status code.
exit 0
