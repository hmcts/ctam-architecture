#!/usr/bin/env bash
# Runs one test (or test class) and records a failure as the "red" evidence required by R2/T1.
# Copy to scripts/red.sh in the service repo.
#
#   ./scripts/red.sh BookingServiceTest
#   ./scripts/red.sh 'BookingServiceTest.rejectsSecondBookingForSameJohAndSlot'
#
# On FAILURE  → writes .ctam/red-marker (which unlocks src/main edits for the hook's TTL) and
#               exits 0, because a failing test is the expected, desired outcome here.
# On SUCCESS  → removes the marker and exits 1: a test that passes before the production code
#               exists is not a red test. Either it asserts nothing (T16) or the behaviour is
#               already implemented and this story needs re-reading (R1).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [ "$#" -ne 1 ]; then
  echo "usage: ./scripts/red.sh <TestClass|TestClass.method>" >&2
  exit 2
fi

filter="$1"
marker_dir="$REPO_ROOT/.ctam"
marker="$marker_dir/red-marker"
mkdir -p "$marker_dir"

echo "==> running $filter — expecting an ASSERTION FAILURE (T1 step 3)"
set +e
output=$(./gradlew --console=plain test --tests "$filter" 2>&1)
status=$?
set -e
printf '%s\n' "$output"

if [ "$status" -eq 0 ]; then
  rm -f "$marker"
  cat >&2 <<'MSG'

RED NOT OBSERVED — the test passed.

A test that passes before the production code exists is not evidence of anything. Check:
  - does it actually assert the new behaviour, or does it assert nothing meaningful (T16)?
  - is the behaviour already implemented, meaning this story needs re-reading (R1)?
MSG
  exit 1
fi

if printf '%s' "$output" | grep -qE 'error: |Compilation failed|compileJava FAILED|compileTestJava FAILED'; then
  rm -f "$marker"
  cat >&2 <<'MSG'

COMPILE ERROR, NOT A RED TEST (T2).

Introduce the minimum signature — an interface, an empty method, a record — so the test compiles,
then re-run. Only an assertion failure tells you the test is wired to the behaviour.
MSG
  exit 1
fi

{
  echo "filter=$filter"
  echo "recorded_at_epoch=$(date +%s)"
  echo "recorded_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$marker"

echo
echo "RED observed and recorded. Paste the assertion failure above into the transcript (R2),"
echo "then write the minimum production code to pass it."
