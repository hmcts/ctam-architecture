#!/usr/bin/env bash
# PreToolUse hook on Edit|Write|MultiEdit — enforces R2/T1 (red before green).
#
# WHAT THIS IS: a guardrail, not a proof. It refuses production-code edits unless a test run
# has recently been observed failing, recorded by scripts/red.sh. It raises the cost of
# skipping TDD; it cannot verify that the failing test was the RIGHT test. The real evidence
# is the red/green output pasted in the transcript (R2) and reviewed by a human.
#
# HOW IT WORKS
#   scripts/red.sh <test-filter>   runs the suite for that filter; on failure it writes
#                                  .ctam/red-marker with the filter and a timestamp
#   this hook                      allows edits under src/main/** only while that marker is
#                                  fresher than CTAM_RED_TTL_SECONDS (default 1800 = 30 min)
#
# ALWAYS ALLOWED: everything under src/test/**, docs/**, and any non-source file. Writing the
# test first is the point — the hook must never stand in the way of that.
#
# HUMAN OVERRIDE: export CTAM_ALLOW_MAIN_EDIT=1 for the session. Deliberate, visible, and
# logged in this hook's denial trail rather than silently assumed.

set -euo pipefail

TTL="${CTAM_RED_TTL_SECONDS:-1800}"
input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Not a production source file → nothing to enforce.
case "$file_path" in
  */src/main/java/*.java) ;;
  *) exit 0 ;;
esac

if [ "${CTAM_ALLOW_MAIN_EDIT:-0}" = "1" ]; then
  exit 0
fi

project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
marker="$project_dir/.ctam/red-marker"

deny() {
  jq -nc --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

if [ ! -f "$marker" ]; then
  deny "R2/T1: no failing test on record, so this edit to src/main is not allowed yet. Write the \
test for one acceptance criterion first, then run ./scripts/red.sh <TestClass or TestClass.method> \
and confirm it fails on an ASSERTION (a compile error is not a red test — T2). Paste that output, \
then make this edit. Human override for the session: export CTAM_ALLOW_MAIN_EDIT=1"
fi

now=$(date +%s)
marker_time=$(stat -f %m "$marker" 2>/dev/null || stat -c %Y "$marker" 2>/dev/null || echo 0)
age=$(( now - marker_time ))

if [ "$age" -gt "$TTL" ]; then
  deny "R2/T1: the last recorded failing test is ${age}s old (limit ${TTL}s), so it is not evidence \
for this edit. Re-run ./scripts/red.sh <TestClass> for the behaviour you are about to implement. \
Human override for the session: export CTAM_ALLOW_MAIN_EDIT=1"
fi

exit 0
