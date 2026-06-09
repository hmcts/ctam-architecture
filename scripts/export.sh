#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root from this script's location so the script
# works regardless of the caller's current working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARCHITECTURE_DIR="$REPO_ROOT/architecture"
OUTPUT_DIR="$REPO_ROOT/architecture/tobe/diagrams"

if ! command -v likec4 >/dev/null 2>&1; then
  echo "Error: 'likec4' is not installed or not on PATH." >&2
  echo "Install it globally with:" >&2
  echo "  npm install -g likec4" >&2
  echo "Docs: https://likec4.dev/tooling/cli/" >&2
  exit 1
fi

if [ ! -d "$ARCHITECTURE_DIR" ]; then
  echo "Error: architecture directory not found at $ARCHITECTURE_DIR" >&2
  exit 1
fi

# Playwright/Chromium is required for PNG export.
# One-time install: npx playwright install chromium
echo "Exporting LikeC4 model to: $OUTPUT_DIR"
likec4 export png "$ARCHITECTURE_DIR" --output "$OUTPUT_DIR" --flatten "$@"
echo "Done."
