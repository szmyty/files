#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# remove_apt_package_manager.sh: Script to remove the apt package manager from
# critical system directories.
#
# This script searches for and deletes files and directories related
# to the apt package manager to prevent its usage.
#
# Usage:
#   ./remove_apt_package_manager.sh
#
# Author: Alan Szmyt
##########################################################################

##########################################################################
# remove_apt_files: Deletes apt-related files from the file system.
#
# This function searches for and removes files matching the pattern '*apt*'
# from the root directory and its subdirectories, excluding mounted filesystems.
#
# Usage:
#   remove_apt_files
#
# Arguments:
#   None
#
# Returns:
#   0 if all files are removed successfully.
#   1 if an error occurs during the deletion process.
##########################################################################
function remove_apt_files() {
    printf "Searching for and deleting apt-related files..."

    # Find and delete apt-related files.
    find / -type f -iname '*apt*' -xdev -delete || {
        printf "Error: Failed to delete apt-related files." >&2
        return 1
    }

    printf "All apt-related files have been deleted."
}

##########################################################################
# remove_apt_directories: Deletes apt-related directories from the file system.
#
# This function searches for and removes directories matching the pattern
# '*apt*' from the root directory and its subdirectories, excluding mounted filesystems.
#
# Usage:
#   remove_apt_directories
#
# Arguments:
#   None
#
# Returns:
#   0 if all directories are removed successfully.
#   1 if an error occurs during the deletion process.
##########################################################################
function remove_apt_directories() {
    printf "Searching for and deleting apt-related directories..."

    # Find and delete apt-related directories.
    find / -type d -iname '*apt*' -print0 -xdev | xargs -0 rm -r -- || {
        printf "Error: Failed to delete apt-related directories." >&2
        return 1
    }

    printf "All apt-related directories have been deleted."
}

##########################################################################
# main: Main function to orchestrate the removal of the apt package manager.
#
# This function calls remove_apt_files and remove_apt_directories to delete
# apt-related files and directories from the system.
#
# Usage:
#   main
##########################################################################
function main() {
    printf "Starting the removal of the apt package manager..."

    # Remove apt-related files.
    remove_apt_files

    # Remove apt-related directories.
    remove_apt_directories

    printf "The apt package manager has been successfully removed."
}

# Execute the main function.
main

exit 0
