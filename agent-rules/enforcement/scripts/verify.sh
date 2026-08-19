#!/usr/bin/env bash
# CTAM pre-handoff quality gate (Q3). Copy to scripts/verify.sh in the service repo.
#
# One command, every gate, no silent skips. If a tool is missing, this FAILS — a gate that
# cannot run has not passed (R12), and reporting otherwise is how false greens happen.
#
# Runnable from anywhere: resolves the repo root from this script's own location.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
fail() { printf '\n\033[31mGATE FAILED: %s\033[0m\n' "$1" >&2; exit 1; }

command -v ./gradlew >/dev/null 2>&1 || [ -x ./gradlew ] || fail "no ./gradlew in $REPO_ROOT"

step "Gradle quality gate (format, structure, architecture, tests, coverage, mutation, SBOM)"
./gradlew --console=plain qualityGate || fail "./gradlew qualityGate"

step "OpenAPI spec generation"
# Adjust the task name to whatever the service's Swagger Core wiring exposes; the scaffolding
# story sets this once. It must produce the spec at the path below.
SPEC_PATH="build/openapi/openapi.json"
./gradlew --console=plain generateOpenApiDocs || fail "OpenAPI spec generation"
[ -f "$SPEC_PATH" ] || fail "expected generated spec at $SPEC_PATH"

step "OpenAPI lint (Spectral)"
if command -v spectral >/dev/null 2>&1; then
  spectral lint --ruleset .spectral.yaml --fail-severity=warn "$SPEC_PATH" || fail "spectral lint"
elif command -v npx >/dev/null 2>&1; then
  npx --yes @stoplight/spectral-cli lint --ruleset .spectral.yaml --fail-severity=warn "$SPEC_PATH" \
    || fail "spectral lint"
else
  fail "spectral is not installed and npx is unavailable — install @stoplight/spectral-cli. \
The API lint is not optional (C3)."
fi

step "Contract tests (Pact)"
# Both directions: provider verification for what this service publishes, consumer tests for
# what it calls (C2). Task names are set by the scaffolding story.
if ./gradlew --console=plain tasks --all | grep -qE '^(pactTest|pactVerify)'; then
  ./gradlew --console=plain pactTest || fail "pactTest"
else
  fail "no Pact task found — every endpoint needs both sides of a contract test (C2). \
If this service genuinely publishes and consumes nothing, remove this step deliberately, \
with a note in the story packet."
fi

printf '\n\033[32mGATE PASSED\033[0m — paste this output into the handoff (Q3).\n'
printf 'Reminder: a passing gate is necessary, not sufficient. The AC -> test map is the evidence\n'
printf 'that the story is done (Q1), and status stays in-review, never done (Q13).\n'
