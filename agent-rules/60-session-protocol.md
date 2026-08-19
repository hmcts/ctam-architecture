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

### W7 — No git writes (R13), and here is what to do instead

Surface the work and stop:

- a one-paragraph summary of what changed and why;
- the file list, grouped by layer, with a line on each;
- the evidence (**R2**, **R12**);
- the Conventional Commits subject you would use, ≤ 72 chars (`conventions.md` → *Git conventions*) — as **text for the human to use**, not a command to run.

The human reviews and commits from VSCode. Do not offer to commit, do not ask for permission to commit, do not stage anything.

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

Definition of done and the exact commands are in [`90-definition-of-done.md`](./90-definition-of-done.md). The handoff includes the fields the control plane needs to signal the ledger:

```
story:        0.1.4
repo:         ctam-reference-data
bus_version:  arch-v1.0            # as pinned by this repo's submodule
status:       in-review            # never "done" — done is the human's call after review
frs:          [FR6, FR7, NFR24]
open_questions: [ … ]              # empty list only if genuinely empty
```

### W13 — `in-review`, never `done`

You do not mark work done. You mark it ready for review, with evidence. `done` is set in the control-plane ledger by a human, after review and commit.
