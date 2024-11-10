#!/usr/bin/env bash

######################################################################
# @Project      : app
# @File         : set_timezone.sh
# @Description  : Script to set the timezone on a Debian-based system
#                 with error handling. The script ensures that the
#                 timezone package 'tzdata' is installed and sets the
#                 timezone based on the TZ environment variable or
#                 defaults to UTC.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-30
######################################################################

######################################################################
# @function     is_package_installed
# @brief        Checks if a given package is installed on the system.
#
# @param[in]    _package   The name of the package to check.
#
# @return       0 if the package is installed, 1 otherwise.
#
# @details      This function uses 'dpkg-query' to determine if the
#               specified package is installed. It returns a status
#               message indicating whether the package is installed.
######################################################################
is_package_installed() {
    local _package="$1"

    local _package_status
    _package_status=$(dpkg-query --show --showformat='${Status}\n' "${_package}" 2>/dev/null)

    # Check if the package is installed
    if echo "${_package_status}" | grep --quiet "install ok installed"; then
        echo "Package '${_package}' is already installed."
        return 0
    else
        echo "Package '${_package}' is not installed."
        return 1
    fi
}

# Update package lists
apt-get update

# Check if the 'tzdata' package is installed, install if not
if is_package_installed "tzdata"; then
    echo "Proceeding since the package is installed."
else
    echo "Installing the package..."
    sudo apt-get install --yes tzdata
fi

# Set the default timezone if TZ is not set
timezone="${TZ:-UTC}"

######################################################################
# @function     is_valid_timezone
# @brief        Validates if the specified timezone exists on the system.
#
# @param[in]    $1   The timezone to validate.
#
# @return       0 if the timezone is valid, 1 otherwise.
#
# @details      This function checks the existence of the timezone file
#               in '/usr/share/zoneinfo'. It returns 0 if the timezone
#               file exists and 1 if it does not.
######################################################################
is_valid_timezone() {
    if [[ -f "/usr/share/zoneinfo/$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Validate the specified timezone
if ! is_valid_timezone "${timezone}"; then
    echo "Invalid timezone: ${timezone}" >&2
    exit 1
fi

# Commit change: Update the timezone
echo "Setting timezone to ${timezone}."

######################################################################
# @brief        Sets the system timezone to the specified value.
#
# @details      This part of the script creates a symbolic link to the
#               appropriate timezone file and updates the '/etc/timezone'
#               file. It also reconfigures 'tzdata' to apply the changes.
######################################################################

# Create a symbolic link to the appropriate timezone file
ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime

# Update /etc/timezone
echo "${timezone}" >/etc/timezone

# Reconfigure tzdata to apply changes
dpkg-reconfigure -f noninteractive tzdata

# Final confirmation
echo "Timezone has been set to ${timezone}."
echo "You may want to restart any long-running services or daemons to apply the new timezone settings."
