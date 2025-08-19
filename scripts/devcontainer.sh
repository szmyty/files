#!/usr/bin/env bash
set -euo pipefail

# Where is node?
NODE="$(which node)"
if [[ -z "$NODE" ]]; then
  echo "❌ Node.js not found. Please install it (e.g., via brew install node)."
  exit 1
fi

# CLI script path (update version if needed)
CLI_SCRIPT="$HOME/.vscode/extensions/ms-vscode-remote.remote-containers-0.413.0/dist/spec-node/devContainersSpecCLI.js"

# Optional: check CLI script exists
if [[ ! -f "$CLI_SCRIPT" ]]; then
  echo "❌ devContainersSpecCLI.js not found at: $CLI_SCRIPT"
  exit 1
fi

# Run and stream logs prettily with jq
LOGFILE="devcontainer-log.json"

echo "🚀 Running DevContainer CLI with pretty JSON logging..."
"$NODE" "$CLI_SCRIPT" up \
  --user-data-folder "$HOME/Library/Application Support/Code/User/globalStorage/ms-vscode-remote.remote-containers/data" \
  --container-session-data-folder "/tmp/devcontainers-$(uuidgen)" \
  --workspace-folder "$HOME/.files/src/repos/wealth" \
  --workspace-mount-consistency cached \
  --gpu-availability detect \
  --id-label "devcontainer.local_folder=$HOME/.files/src/repos/wealth" \
  --id-label "devcontainer.config_file=$HOME/.files/src/repos/wealth/.devcontainer/devcontainer.json" \
  --log-level debug \
  --log-format json \
  --config "$HOME/.files/src/repos/wealth/.devcontainer/devcontainer.json" \
  --default-user-env-probe loginInteractiveShell \
  --remove-existing-container \
  --mount "type=volume,source=vscode,target=/vscode,external=true" \
  --skip-post-create \
  --update-remote-user-uid-default on \
  --mount-workspace-git-root \
  --include-configuration \
  --include-merged-configuration \
  2>&1 | tee "$LOGFILE" | jq -C .

echo "📁 Full raw log saved to: $LOGFILE"

