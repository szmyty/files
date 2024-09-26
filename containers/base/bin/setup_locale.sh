#!/usr/bin/env bash

######################################################################
# @Project      : app
# @File         : setup_locale.sh
# @Description  : Script to configure the locale for Debian Bookworm and
#                 check for necessary package installations. The script
#                 ensures the required locale packages are installed
#                 and sets the appropriate locale environment variables.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-30
######################################################################

######################################################################
# @brief        Checks if a specific package is installed on the system.
#
# @param[in]    _package The name of the package to check.
#
# @return       0 if the package is installed, 1 otherwise.
#
# @details      Uses dpkg-query to verify the installation status of the
#               specified package. If the package is not installed, it
#               prints a message and returns 1.
#
# @see          https://man7.org/linux/man-pages/man1/dpkg-query.1.html
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

######################################################################
# @brief        Install necessary packages for locale configuration.
#
# @details      Installs the 'locales' and 'locales-all' packages if
#               they are not already installed on the system.
#
# @see          https://man7.org/linux/man-pages/man8/apt-get.8.html
######################################################################
install_locale_packages() {
    apt-get update --quiet

    if is_package_installed "locales"; then
        echo "Proceeding since the package is installed."
    else
        echo "Installing the 'locales' package..."
        apt-get install --yes locales
    fi

    if is_package_installed "locales-all"; then
        echo "Proceeding since the package is installed."
    else
        echo "Installing the 'locales-all' package..."
        apt-get install --yes locales-all
    fi
}

######################################################################
# @brief        Set the locale configuration for the system.
#
# @details      This function configures the locale based on the environment
#               variables or defaults. It determines the appropriate locale,
#               updates /etc/locale.gen, generates the locale, and applies
#               the locale settings system-wide.
#
# @see          https://man7.org/linux/man-pages/man1/locale-gen.1.html
# @see          https://man7.org/linux/man-pages/man8/update-locale.8.html
# @see          https://man7.org/linux/man-pages/man8/dpkg-reconfigure.8.html
######################################################################
configure_locale() {
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

    echo "The selected locale is: ${_locale}"

    # Uncomment the desired locale in /etc/locale.gen
    echo "Uncommenting the locale in /etc/locale.gen..."
    sed --in-place "/^# *${_locale}/s/^# *//" /etc/locale.gen

    # Generate the selected locale.
    echo "Generating locale..."
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

    echo "Locale configuration completed."
}

######################################################################
# @brief        Main function to orchestrate the locale setup.
#
# @details      Installs the required packages and configures the locale
#               on the system.
######################################################################
main() {
    install_locale_packages
    configure_locale
}

# Execute the main function
main

exit 0
