#!/usr/bin/env bash
# PreToolUse hook on the Bash matcher. Protects the default branch; everything else is allowed.
#
# POLICY (revised 2026-08-19 — SCP 2026-08-19c). The human gate moved from "every commit" to
# "the pull request". An agent may branch, stage, commit and push a feature branch. It may not
# write to a protected branch, rewrite published history, or discard work.
#
#   ALLOWED   status log diff show blame ls-files config remote fetch submodule
#             add commit switch checkout <branch> branch <new> stash push/list/show
#             push <feature-branch>            (fast-forward, non-protected, non-force)
#             pull                             (on a feature branch)
#
#   DENIED    commit / merge / rebase / cherry-pick / revert / pull  while HEAD is protected
#             push to a protected branch, by any spelling
#             push --force / --force-with-lease / --mirror / +refspec   (anywhere)
#             push --delete, push :branch, branch -d/-D/-m
#             tag, push --tags, push refs/tags/*
#             reset --hard/--merge/--keep, clean, rm, restore, checkout -- <path>,
#             stash drop/clear, filter-branch
#             gh / hub (any subcommand)
#
# WHY these stay denied even though committing is now allowed:
#   - Protected branch: the PR is the review gate. Committing or pushing straight to main
#     bypasses the only human checkpoint in an AI-led delivery model.
#   - Force push: rewrites history a reviewer may already have read, and can erase review
#     context on a shared branch. A human can do it deliberately.
#   - Tags: `arch-vN` is a release action with downstream consumers pinning it (see the
#     delivery operating model). Tagging is a human decision, not a side effect.
#   - Discarding work: uncommitted changes may be the only copy of something.
#   - gh/hub: repository administration, PR approval and merge are the human gate itself.
#     A hook cannot tell `gh pr create` from `gh pr merge --admin` safely enough to be worth it.
#
# Override the protected set with CTAM_PROTECTED_BRANCHES (regex alternation), e.g.
#   export CTAM_PROTECTED_BRANCHES='main|master|release/.*'

set -euo pipefail

cmd=$(jq -r '.tool_input.command // ""')

PROTECTED="${CTAM_PROTECTED_BRANCHES:-main|master}"

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

# Strip space-separated git flag-value pairs so the patterns below see `git` adjacent to its
# subcommand. Handles `git -C path subcommand`, `git --git-dir path subcommand`, etc.
normalize() {
  local s="$1" prev="" i=0
  while [ "$s" != "$prev" ] && [ "$i" -lt 10 ]; do
    prev="$s"
    s=$(printf '%s' "$s" | sed -E 's/(^|[[:space:];&|`])git[[:space:]]+(-C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--exec-path)[[:space:]]+[^[:space:]]+/\1git/g')
    i=$((i + 1))
  done
  printf '%s' "$s"
}

normalized=$(normalize "$cmd")
has() { printf '%s' "$normalized" | grep -qE "$1"; }

# Command positions only: start of line, after a separator, or inside $( ) / a subshell.
#
# A backtick is deliberately NOT a boundary. Legacy `cmd` substitution is rare, and treating a
# backtick as one makes any prose mentioning a blocked command in inline code — including this
# programme's own documentation of this policy — look like an invocation of it. That false positive
# fires exactly when someone writes the rule down, which is the worst possible time to be wrong.
#
# KNOWN LIMIT, accepted: this matches text, so a blocked command appearing as *data* at a command
# position (a here-doc line, a test fixture, an echo argument) is still denied. The alternative —
# ignoring quoted spans — would let `sh -c "gh pr merge"` straight through, which is worse. When you
# need to write about a blocked command, write the file with an editor tool rather than a here-doc.
boundary='(^|[;&|(])'
git_cmd="${boundary}[[:space:]]*git([[:space:]]+--?[^[:space:]]+(=[^[:space:]]+)?)*[[:space:]]+"
# A single command's argument span: everything up to the next shell separator.
args='[^;&|`]*'

# ---------------------------------------------------------------- GitHub CLI
if has "${boundary}[[:space:]]*(gh|hub)([[:space:]]|$)"; then
  deny "gh/hub is not available to Claude sessions. Repository administration, PR approval and PR \
merge are the human gate in this programme — see the delivery operating model. Prepare the branch \
and push it; the human opens, reviews and merges the pull request. (Also: the HMCTS template's \
setup-new-repo.sh makes a repository PUBLIC, which is another reason gh stays closed.)"
fi

# ---------------------------------------------------------------- force / history rewriting
if has "${git_cmd}push${args}(--force|--force-with-lease|--mirror)" \
   || has "${git_cmd}push${args}[[:space:]]-f([[:space:]]|$)" \
   || has "${git_cmd}push${args}[[:space:]]\+[^[:space:]]*:"; then
  deny "Force pushing is not allowed. It rewrites history a reviewer may already have read, and \
can erase review context on a shared branch. A normal push to your feature branch is allowed. If \
history genuinely needs rewriting, surface the reason and let the human do it deliberately."
fi

if has "${git_cmd}(filter-branch|filter-repo)"; then
  deny "History rewriting (filter-branch/filter-repo) is not allowed from a Claude session."
fi

# ---------------------------------------------------------------- branch/ref deletion
if has "${git_cmd}push${args}(--delete|--prune)" \
   || has "${git_cmd}push${args}[[:space:]]:[^[:space:]]+" \
   || has "${git_cmd}branch${args}[[:space:]]-(d|D|m|M)([[:space:]]|$)"; then
  deny "Deleting or renaming branches (local or remote) is not allowed. Create branches freely; \
removing them is a human decision."
fi

# ---------------------------------------------------------------- tags are release actions
if has "${git_cmd}tag([[:space:]]|$)" \
   || has "${git_cmd}push${args}--tags" \
   || has "${git_cmd}push${args}refs/tags/"; then
  deny "Tagging is not allowed from a Claude session. An arch-vN tag is a release action that \
downstream repos pin as a submodule — see the delivery operating model's bus-pinning rule. Say \
which tag is needed and why; the human creates it."
fi

# ---------------------------------------------------------------- discarding work
if has "${git_cmd}reset${args}(--hard|--merge|--keep)"; then
  deny "git reset --hard/--merge/--keep discards uncommitted work, which may be the only copy. \
Use a plain 'git reset' to unstage, or commit first."
fi

if has "${git_cmd}(clean|rm|restore)([[:space:]]|$)"; then
  deny "git clean/rm/restore discards work that may be the only copy. If a file genuinely needs \
removing, say so and let the human confirm."
fi

if has "${git_cmd}checkout${args}[[:space:]]--[[:space:]]" \
   || has "${git_cmd}checkout[[:space:]]+\.([[:space:]]|$)"; then
  deny "'git checkout -- <path>' discards uncommitted changes to those files. Switching branches \
('git switch <branch>' / 'git checkout <branch>') is allowed."
fi

if has "${git_cmd}stash${args}(drop|clear)"; then
  deny "git stash drop/clear destroys stashed work permanently."
fi

# ---------------------------------------------------------------- protected-branch writes
# Explicit target, e.g. `git push origin main`, `git push origin HEAD:main`,
# `git push origin refs/heads/master`.
if has "${git_cmd}push${args}[[:space:]](refs/heads/)?(${PROTECTED})([[:space:]]|$)" \
   || has "${git_cmd}push${args}:(refs/heads/)?(${PROTECTED})([[:space:]]|$)"; then
  deny "Pushing to a protected branch (${PROTECTED//|/, }) is not allowed — the pull request is \
the human gate. Push your feature branch instead; the human reviews and merges."
fi

# Implicit target: whatever HEAD currently is.
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
# symbolic-ref first: it resolves the branch name even on an UNBORN branch (a fresh repo with no
# commits), where rev-parse fails. That is precisely the state in which a first commit would land
# on main, so getting this wrong would leave the main protection off exactly when it matters most.
current=$(git -C "$project_dir" symbolic-ref --quiet --short HEAD 2>/dev/null \
          || git -C "$project_dir" rev-parse --abbrev-ref HEAD 2>/dev/null \
          || printf '')

if [ -n "$current" ] && printf '%s' "$current" | grep -qE "^(${PROTECTED})$"; then
  if has "${git_cmd}(commit|merge|rebase|cherry-pick|revert|am)([[:space:]]|$)"; then
    deny "HEAD is on '${current}', a protected branch, so this would write to it directly and \
bypass the pull-request gate. For a dispatched story you should already be on its 'story/<id>' branch — if \
you are not, dispatch went wrong, so stop and ask rather than cutting a new one. For work that is not a \
dispatched story, branch first ('bugfix/<ticket>-<desc>' or 'chore/<desc>' per conventions.md)."
  fi
  if has "${git_cmd}push([[:space:]]|$)"; then
    deny "HEAD is on '${current}', a protected branch, so a bare push targets it. Move the work onto the \
story's branch ('story/<id>', created at dispatch), or for non-story work a 'bugfix/' or 'chore/' branch."
  fi
  if has "${git_cmd}pull([[:space:]]|$)"; then
    deny "Pulling onto '${current}' updates a protected branch and can create a merge commit on it. \
The human keeps protected branches in sync."
  fi
fi

exit 0
