#!/usr/bin/env bash
set -euo pipefail

# Render the JO (eLinks) ER diagrams from their D2 sources to PNG + SVG.
# Works regardless of the caller's current working directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIAGRAM_DIR="$REPO_ROOT/docs/integrations/jo/diagrams"

if ! command -v d2 >/dev/null 2>&1; then
  echo "Error: 'd2' is not installed or not on PATH." >&2
  echo "Install it with:  brew install d2   (or see https://d2lang.com)" >&2
  exit 1
fi

# Layout engine + padding are fixed here so every diagram renders identically.
export D2_LAYOUT=elk
PAD=40

DIAGRAMS=(
  jo-er-core
  jo-er-location
  jo-er-ticket
  jo-er-reference-hub
  jo-er-full
)

for name in "${DIAGRAMS[@]}"; do
  src="$DIAGRAM_DIR/$name.d2"
  echo "Rendering $name ..."
  d2 --pad "$PAD" "$src" "$DIAGRAM_DIR/$name.png"
  d2 --pad "$PAD" "$src" "$DIAGRAM_DIR/$name.svg"
done

echo "Done. Outputs in $DIAGRAM_DIR"
