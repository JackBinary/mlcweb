#!/usr/bin/env bash

set -euo pipefail

INSTALL_PATH="/usr/local/bin/mlcweb"
SCRIPT_URL="https://raw.githubusercontent.com/JackBinary/mlcweb/refs/heads/main/mlcweb.sh"

echo "📦 Downloading mlcweb launcher from:"
echo "    $SCRIPT_URL"
echo ""

curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH" || {
  echo "❌ Failed to download mlcweb script from $SCRIPT_URL" >&2
  exit 1
}

chmod +x "$INSTALL_PATH"

echo ""
echo "✅ Installed mlcweb to $INSTALL_PATH"
echo "➡️  Run it with:"
echo "    mlcweb"
