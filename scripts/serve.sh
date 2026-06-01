#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root from this script's location so the script
# works regardless of the caller's current working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARCHITECTURE_DIR="$REPO_ROOT/architecture"

if ! command -v likec4 >/dev/null 2>&1; then
  echo "Error: 'likec4' is not installed or not on PATH." >&2
  echo "Install it globally with:" >&2
  echo "  npm install -g likec4" >&2
  echo "Or run via npx without installing:" >&2
  echo "  npx likec4 serve \"$ARCHITECTURE_DIR\"" >&2
  echo "Docs: https://likec4.dev/tooling/cli/" >&2
  exit 1
fi

if [ ! -d "$ARCHITECTURE_DIR" ]; then
  echo "Error: architecture directory not found at $ARCHITECTURE_DIR" >&2
  exit 1
fi

echo "Serving LikeC4 model from: $ARCHITECTURE_DIR"
exec likec4 serve "$ARCHITECTURE_DIR" "$@"
