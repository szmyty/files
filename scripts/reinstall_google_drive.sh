#!/usr/bin/env bash
# Completely uninstall and reinstall Google Drive on macOS (DMG+PKG version)

set -euo pipefail

main() {
  printf "🔄 Reinstalling Google Drive...\n"

  # 1. Kill related processes
  printf "🛑 Killing running Google Drive processes...\n"
  pkill -f "Google Drive" || true
  pkill -f "DriveFS" || true
  pkill -f "com.google.GoogleDrive" || true

  # 2. Remove app and related data
  printf "🧹 Removing application and config files...\n"
  rm -rf "/Applications/Google Drive.app"
  rm -rf "${HOME}/Library/Application Support/Google/DriveFS"
  rm -rf "${HOME}/Library/Application Support/Google/Drive"
  rm -rf "${HOME}/Library/Caches/com.google.GoogleDrive*"
  rm -rf "${HOME}/Library/Preferences/com.google.GoogleDrive*"
  rm -rf "${HOME}/Library/Logs/GoogleDrive"
  rm -rf "${HOME}/Library/Group Containers/google_drive*"
  rm -rf "${HOME}/Library/Containers/com.google.GoogleDrive*"
  rm -rf "${HOME}/Library/CloudStorage/GoogleDrive*"

  # 3. Remove launch agents
  printf "🔧 Removing launch agents...\n"
  launchctl remove com.google.GoogleDrive.FinderSync* || true
  launchctl remove com.google.GoogleDrive* || true

  # 4. Download and mount installer
  printf "⬇️  Downloading latest installer...\n"
  dmg="/tmp/GoogleDrive.dmg"
  curl -L -o "${dmg}" "https://dl.google.com/drive-file-stream/GoogleDrive.dmg"

  printf "💿 Mounting installer DMG...\n"
  mount_output=$(hdiutil attach "${dmg}" -nobrowse)
  mount_point=$(echo "$mount_output" | grep "/Volumes/Install Google Drive" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')

  echo "📁 Mounted at: $mount_point"

# 5. Install the .pkg
printf "📦 Installing GoogleDrive.pkg...\n"
  sudo installer -pkg "${mount_point}/GoogleDrive.pkg" -target /
 

  # 5. Install the .pkg
  printf "📦 Installing GoogleDrive.pkg...\n"
  sudo installer -pkg "${mount_point}/GoogleDrive.pkg" -target /

  # 6. Unmount
  printf "💽 Unmounting installer...\n"
  hdiutil detach "${mount_point}"

  # 7. Cleanup
  rm -f "${dmg}"

  # 8. Launch
  printf "🚀 Launching Google Drive...\n"
  open -a "Google Drive"

  printf "✅ Google Drive reinstallation complete.\n"
}

main "$@"

