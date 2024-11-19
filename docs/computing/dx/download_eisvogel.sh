#!/bin/bash

# Script to download and extract the entire Eisvogel template folder for Pandoc

# Step 1: Get the latest release tag from GitHub API
latest_release=$(curl --silent "https://api.github.com/repos/Wandmalfarbe/pandoc-latex-template/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

echo "Latest Eisvogel release: $latest_release"

# Construct the download URL
download_url="https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/${latest_release}/Eisvogel-${latest_release#v}.tar.gz"

echo "Downloading Eisvogel template from $download_url..."

# Step 2: Download the archive
curl -L "$download_url" -o Eisvogel.tar.gz

# Step 3: Extract the archive contents into the current directory
echo "Extracting the Eisvogel template..."
tar -xzf Eisvogel.tar.gz

# Step 4: Remove the downloaded archive
rm Eisvogel.tar.gz

echo "Eisvogel template extracted successfully."
echo "All contents are now available in the extracted folder."
