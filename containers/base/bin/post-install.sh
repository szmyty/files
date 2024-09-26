#!/usr/bin/env bash
# Reference:
# - https://github.com/ironpeakservices/iron-debian/blob/master/post-install.sh

set -euo pipefail

# Remove APT packages
dpkg --purge apt apt-utils

# Remove specific directories and files related to APT
rm -rf /etc/apt /var/lib/apt /var/cache/apt /usr/lib/apt /usr/share/apt /usr/bin/apt* /usr/sbin/apt*
