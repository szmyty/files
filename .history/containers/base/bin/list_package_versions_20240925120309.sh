#!/usr/bin/env bash
set -euox pipefail

######################################################################
# @Project      : sanctuary
# @File         : list_package_versions.sh
# @Description  : Script to list all installed packages on a Debian-based
#                 system along with their versions. The output is sorted
#                 alphabetically by package name.
#
# @Author       : Alan Szmyt
# @Date         : 2024-08-30
######################################################################

######################################################################
# @brief        Lists all installed packages on the system.
#
# @details      This script uses 'dpkg-query' to retrieve the names and
#               versions of all installed packages. The output is then
#               sorted alphabetically and printed.
#
# @return       None.
######################################################################

# Retrieve the list of installed packages with their versions.
packages=$(dpkg-query --show --showformat='${Package}=${Version}\n')

# Sort and print the package list.
echo "${packages}" | sort
