#!/usr/bin/env bash

set -euo pipefail

VENV_DIR="$HOME/.mlcweb/venv"
PYTHON=""
REQUIREMENTS=(
  "-U torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu122"
  "--pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cu122 mlc-ai-nightly-cu122"
  "-U open-webui"
)

# Find Python 3.11 or 3.12
for V in 3.12 3.11; do
  if command -v python$V >/dev/null 2>&1; then
    PYTHON=$(command -v python$V)
    break
  fi
done

if [[ -z "$PYTHON" ]]; then
  echo "❌ Python 3.11 or 3.12 not found. Please install one of them." >&2
  exit 1
fi

# Create venv if needed
if [[ ! -d "$VENV_DIR" ]]; then
  echo "🔧 Creating virtualenv at $VENV_DIR using $PYTHON..."
  "$PYTHON" -m venv "$VENV_DIR"
fi

# Activate venv
source "$VENV_DIR/bin/activate"
python -m pip install -U pip

# Check for updates
echo "🔄 Checking for updates to mlc-llm, open-webui, and torch..."
for req in "${REQUIREMENTS[@]}"; do
  echo "⬇️  Installing/updating: pip install $req"
  if python -m pip install --quiet $req; then
    echo "✅ Installed: $req"
  else
    echo "⚠️  Failed to update: $req" >&2
    exit 1
  fi
done

# Run servers in parallel
echo "🚀 Starting mlc_llm and open-webui..."
(
  # Default to 8B model if no args provided
  if [[ $# -eq 0 ]]; then
    echo "ℹ️  No model specified. Using default: mlc-ai/Qwen3-8B-q4f16_1-MLC"
    set -- HF://mlc-ai/Qwen3-8B-q4f16_1-MLC
  fi

  # Append --device=vulkan if not specified
  if [[ "$*" != *"--device="* ]]; then
    set -- "$@" --device=cuda
  fi

  mlc_llm serve "$@" & pid1=$!
  OPENAI_API_BASE_URL=http://localhost:8000/v1 \
  ENABLE_DIRECT_CONNECTIONS=False \
  ENABLE_OLLAMA_API=False \
  open-webui serve & pid2=$!

  # Wait for webui to start and open in browser
  for i in {1..30}; do
    if curl -fs http://localhost:8080 >/dev/null 2>&1; then
      xdg-open http://localhost:8080 >/dev/null 2>&1 || echo "🌐 Open http://localhost:8080 manually"
      break
    fi
    sleep 0.5
  done &

  # Handle Ctrl+C
  trap "echo '🛑 Caught SIGINT, stopping...'; kill $pid1 $pid2; exit" SIGINT
  wait $pid1 $pid2
)
