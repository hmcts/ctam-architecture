---
id: agent-rules/session-protocol
title: Session and workflow protocol (W1–W13)
status: draft
last_updated: 2026-08-19
---

# Session and workflow protocol

> How a session starts, what it may touch, and how it hands back. The repo boundaries here are not bureaucracy: per the delivery operating model, each boundary is a **human review gate**, and each repo must stay independently readable by a fresh session or a human HMCTS developer who has none of your context.

## Starting

### W1 — Read in this order, before the first edit

1. `CLAUDE.md` in this repo (the core rules, R1–R14).
2. `docs/stories/<id>.md` — the story packet. Its Gherkin ACs are your scope (**R1**).
3. The rule file for what you are about to touch (index in [`00-core.md`](./00-core.md)).
4. The existing code you will change — actually read it. Not the filenames, not your memory of a similar codebase (**R7**).

If the story packet is missing, ambiguous about scope, or references a bus version other than the one this repo pins, **stop** (**R5**).

The packet's shape is fixed by [`templates/story-packet.md`](./templates/story-packet.md) — BMad's story template, with CTAM detail nested under `## Dev Notes`. Two consequences for you:

- **You write into `## Dev Agent Record`** — model used, debug log references, completion notes (your red/green evidence per **R2** and gate output per **R12**), and the `### File List`. You tick off `## Tasks / Subtasks` as you go.
- **You never restructure the packet, and never edit the acceptance criteria** (**W8**). A packet that does not match the template is a dispatch defect: raise it under *Open questions* rather than reshaping it yourself.

### W2 — Say the plan before writing anything

Your first substantive output is a short plan, not an edit:

- **AC → test list.** Each AC restated as the test(s) that will prove it, in the order you will write them.
- **Files you expect to touch**, and the layer each sits in.
- **Open questions** (**R5**) — surfaced now, before work depends on them.
- **Explicitly out of scope** — what a reader might expect that this story does not include.

Then start the loop (**T1**). A design choice *within* the sanctioned structure (which class, which method, how to split) is yours to make. Anything on **R6**'s list — a new dependency, table, column, endpoint, env var, config key, or public surface — needs a citation or a human's yes first.

### W3 — Resuming a story you did not start

Establish state before editing: re-read the packet, read the working tree (read-only `git status` / `git diff` is allowed), and run the test suite to see what is actually green. Never assume the previous session finished what its notes claim (**R12** applies to other sessions' claims too).

## Boundaries

### W4 — One story, one repo, one session

Do not interleave two stories. Serialise within a repo so its history stays linear and reviewable; parallelism belongs **across** repos, one session each (delivery operating model → *Parallel execution*).

### W5 — `_arch/` is read-only

The submodule is the pinned context bus. Never edit anything under `_arch/`, never `git submodule update` to a different version, and never work around a rule by changing the rules. A rule that is wrong is amended in the control plane by SCP, then adopted by a deliberate bump PR ([`index.md`](./index.md) → *Amending these rules*).

### W6 — Stay inside this repo

No edits to the control plane (`ctam-analysis`), no edits to another service repo, no edits to a generated artefact. If the work needs a change in another repo, that is a **stop** — it is a separate story, dispatched separately.

### W7 — the pull request is the human gate (R13)

*Revised 2026-08-19 (SCP 2026-08-19c). Committing was previously prohibited outright; the gate is now the PR.*

You own the branch. A human owns `main`.

1. **You are already on the story's branch — do not cut another.** Dispatch created `story/<id>` in this repo, committed the packet on it and pushed it; that branch is the claim on this story. Confirm you are on it (`git rev-parse --abbrev-ref HEAD`) and continue there. **One branch per story, from dispatch to PR** (`conventions.md` → *Git conventions*). If HEAD is on a protected branch instead, stop and ask — something went wrong at dispatch; the hook will refuse the commit anyway, and it is right to.
2. **Commit as you go**, Conventional Commits, imperative, ≤ 72-char subject. Prefer several honest commits over one that hides the sequence: red-green cycles are easier to review when they are visible.
3. **Push the branch** — `git push` (the upstream is already set; dispatch pushed it).
4. **Stop there and hand back.** Surface the compare URL, a one-paragraph summary of what changed and why, the file list grouped by layer, and the evidence (**R2**, **R12**).

**Never:** open, approve or merge the pull request · push to `main`/`master` · force-push · tag · use `gh`/`hub` · discard uncommitted work. Those *are* the gate, and an agent that operates its own gate does not have one.

A push is not a claim of doneness. The packet's `Status:` goes to `review` and the human reviews the PR (**W13**).

## While working

### W8 — The story packet is the working record

Keep it current as you go: `status`, decisions taken with their citations (**R4**), and *Open Questions*. **Never edit the acceptance criteria** — they are copied verbatim from the epic in the control plane. If an AC is wrong, that is an Open Question and a stop.

### W9 — Scope discovered mid-story goes to Open Questions

Not into the diff (**R14**). Write what you found, where, and why it matters. Someone will turn it into a story; that is the system working, not friction.

### W10 — Report what is true

If tests fail, say so and paste the failure. If you skipped something, say what and why. If you are unsure whether something works, say that instead of implying it does. A false green is worse than a red, because the review that would have caught it will not happen.

### W11 — Context hygiene

Read the minimum needed and cite what you read (**R4**). Do not re-derive a decision already recorded in the packet. On a long session, re-read `CLAUDE.md` before the handoff — the core rules are exactly what erodes as context fills.

## Handing back

### W12 — Run the gate, then write the handoff

Definition of done and the exact commands are in [`90-definition-of-done.md`](./90-definition-of-done.md). The handoff includes the fields the control plane needs to signal progress:

```
story:             0.1.4
sprint_status_key: 0-1-4-mrd-supplementary-reference-data-is-ingested-from-the-weekly-excel-feed
repo:              ctam-reference-data
bus_version:       arch-v1.0            # as pinned by this repo's submodule
frs:               [FR6, FR7, NFR24]
branch:            feature/CTAM-123-mrd-ingestion    # your claim on this story
open_questions:    [ … ]                # empty list only if genuinely empty
```

### W13 — set the packet's `Status:` to `review`, never `done`

**One status vocabulary, used in two places.** BMad's: `ready-for-dev` → `in-progress` → `review` → `done`.

| Where | Field | Who sets it |
|---|---|---|
| This story packet, `docs/stories/<id>.md` | the `Status:` line | **you**, up to `review` |
| The control plane's `sprint-status.yaml` | the story's entry | a **human**, after review |

You move the packet to `in-progress` when you start and to **`review`** when you hand back. You never set `done` in either place, and you never touch the control plane — it is a different repository (**W6**).

*(The programme previously kept a second, per-epic ledger with its own vocabulary. It was retired in favour of BMad's sprint status, so there is now exactly one set of words for a status.)*
