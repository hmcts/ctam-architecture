#!/usr/bin/env bash
# PreToolUse hook on Bash matcher.
# Reads {"tool_input":{"command":"..."}} on stdin and denies state-changing
# git/GitHub operations. User commits externally via VSCode after review.
#
# Blocked git subcommands: commit push pull merge rebase reset checkout branch
#                          tag stash cherry-pick clean rm
# Blocked binaries:        gh hub (all subcommands)
# Allowed read-only git:   status log diff show blame ls-files config remote
#                          fetch (and any other subcommand not in the blocklist)
#
# Note: `git branch` (with no args) is read-only listing but is included in the
# blocklist because `git branch -d/-D/-m <name>` mutate. Same for `git tag`.

set -euo pipefail

cmd=$(jq -r '.tool_input.command // ""')

# Strip space-separated git flag-value pairs so the simple regex below sees
# `git` directly adjacent to the subcommand. Handles `git -C path subcommand`,
# `git --git-dir path subcommand`, etc. Iterate to collapse multiple flags.
normalize() {
  local s="$1"
  local prev=""
  local i=0
  while [ "$s" != "$prev" ] && [ "$i" -lt 10 ]; do
    prev="$s"
    s=$(printf '%s' "$s" | sed -E 's/(^|[[:space:];&|`])git[[:space:]]+(-C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--exec-path)[[:space:]]+[^[:space:]]+/\1git/g')
    i=$((i + 1))
  done
  printf '%s' "$s"
}

normalized=$(normalize "$cmd")

boundary='(^|[;&|`])'
gh_pattern="${boundary}[[:space:]]*(gh|hub)([[:space:]]|$)"
blocked_subs='commit|push|pull|merge|rebase|reset|checkout|branch|tag|stash|cherry-pick|clean|rm'
git_pattern="${boundary}[[:space:]]*git([[:space:]]+--?[^[:space:]]+(=[^[:space:]]+)?)*[[:space:]]+(${blocked_subs})([[:space:]]|$)"

if printf '%s' "$normalized" | grep -qE "$gh_pattern" \
   || printf '%s' "$normalized" | grep -qE "$git_pattern"; then
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Git/GitHub state-changing operations are blocked from Claude sessions per CLAUDE.md. User commits externally via VSCode after review. Allowed read-only: git status/log/diff/show/blame/ls-files."
    }
  }'
fi

exit 0
