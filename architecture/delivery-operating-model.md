---
type: 'Architecture Shard'
description: 'How epics/stories authored in ctam-analysis are delivered into the 16-repo polyrepo: ctam-analysis is the control plane (planning + dispatch + traceability), ctam-architecture is the version-pinned context bus (git submodule), and each service repo is a self-contained execution unit. AI-led (Claude Code) delivery, deterministic dispatch order.'
resource: 'architecture/tobe/delivery-operating-model.html'
tags: [ctam-pathfinder, architecture, delivery, operating-model]
timestamp: '2026-07-07'
parent: ../architecture.md
title: Delivery Operating Model — Control Plane, Context Bus, Execution Units
last_updated: 2026-07-07
---

# Delivery Operating Model — Control Plane, Context Bus, Execution Units

> Sibling of [`../architecture.md`](../architecture.md). Companion to [`./repository-strategy.md`](./repository-strategy.md) ("*what* repos exist") and [`./repo-structure.md`](./repo-structure.md) ("*what's inside* each repo"). This file answers "*how* work flows from the epics/stories authored here into those repos, and who orchestrates it."

## The problem this shard resolves

Epics and stories are authored **once, centrally** in this planning workspace (`ctam-analysis`): the PRD, the architecture, and the per-phase epics with embedded Gherkin acceptance criteria all live here. But the code that satisfies them is delivered across a **16-repo polyrepo** ([`./repository-strategy.md`](./repository-strategy.md)), each repo with its own pipeline, CODEOWNERS, and release cadence. Delivery is **AI-led** — Claude Code agents implement the stories.

That creates one central question: *does the planning workspace become the thing that edits code in all 16 repos, or do stories get copied out and detached?* Both naive answers fail:

- **Copy-and-detach** produces 16 divergent copies of shared truth (conventions, the `JWTFilter` pattern, RFC 9457 shapes, ADRs). One convention change becomes a 16-way manual re-sync with no guarantee of consistency. Traceability fragments.
- **Fat orchestrator** (edit all repos from one central session) rebuilds a monorepo's coupling with none of a monorepo's tooling: per-repo CODEOWNERS/branch-protection become meaningless, session context bloats across 16 repos, and a repo checked out on its own has zero story context — it stops being the unit of delivery.

## Core principle: separate the control plane from the data plane, join them with a versioned context bus

Delivery is split into **three roles with three homes**. The orchestration of *what/when/traceability* (control plane) is kept strictly separate from *per-repo code editing* (data plane); the shared truth both depend on is *referenced, never copied* (context bus).

| Layer | Home | Owns | Never does |
|---|---|---|---|
| **Control plane** | `ctam-analysis` (this workspace) | Canonical PRD/architecture/epics/stories · the BMad **sprint status** (`implementation-artifacts/sprint-status.yaml`) · story-packet generation ("dispatch") · the pre-dispatch check | Edit service code |
| **Context bus** | `ctam-architecture` | *Published, version-pinned* architecture + conventions + ADRs + `ctam-scaffold.sh` + aggregated OpenAPI contracts every service consumes as shared truth | Hold planning or story state |
| **Execution units** | the 15 service / UI / infra repos (the polyrepo minus `ctam-architecture`) | Where code lands. Each carries a **self-contained story packet** (`docs/stories/<id>.md`) + a `CLAUDE.md` pinned to a `ctam-architecture` version | Own the roadmap |

This is already latent in the architecture: [`./repo-structure.md`](./repo-structure.md) names the canonical PRD as living in planning-artifacts (here) with `ctam-architecture/prd.md` as a *mirror*. This shard names that split and makes it operational.

**Direct answer to "is `ctam-analysis` the orchestrator?"** — Yes for **planning, sequencing, and traceability**. No for **code editing**, which happens per-repo to honour polyrepo isolation.

## Decision 1 — Context bus binding: git submodule, version-pinned

Every service repo consumes shared architecture truth by embedding **`ctam-architecture` as a git submodule pinned to an exact commit/tag**, rather than copying distilled context in or querying a runtime service.

```
ctam-{service}/
├── .gitmodules                     # pins ctam-architecture @ <tag>, e.g. arch-v1.0
├── _arch/                          # submodule → github.com/hmcts/ctam-architecture @ arch-v1.0
│   ├── architecture.md
│   ├── architecture/conventions.md
│   ├── architecture/data-tables.md
│   └── ...
├── CLAUDE.md                       # repo-specific rules + "read _arch/ for shared conventions; bus pinned at arch-v1.0"
└── docs/stories/<id>.md            # the self-contained story packet (see Decision 3)
```

**Why submodule over the alternatives:**

- **vs. synced distilled context pack (copies):** copies drift. A submodule is a single source referenced by pointer — there is exactly one authored copy of each convention.
- **vs. MCP-served context (runtime query):** an MCP service is unpinned (rules can change mid-work), invisible to a human opening the repo, and is extra infrastructure to build and operate. A submodule is inert, readable, and needs no running service.
- **Auditable + version-pinned:** git records every bump. Satisfies the programme's auditable-trail requirement and the per-repo independence principle simultaneously.

### The bus-pinning rule (this is what makes the model safe)

> **A service repo re-syncs to a newer `ctam-architecture` version only by an explicit, committed submodule bump. The bus never mutates a downstream repo silently.**

Consequence: a convention change is **one PR in `ctam-architecture`** (publish `arch-v(N+1)`) **+ one deliberate bump PR per repo that adopts it** — auditable, staged, reversible. This is precisely what prevents "central truth" from becoming "16 things silently drifting." Repos may sit on different bus versions intentionally (e.g. a phase-6 service on `arch-v1.9` while phase-1 services haven't yet needed the bump); each repo's pinned version is recorded in its own `CLAUDE.md` and in every story packet's `bus_version` — the pin lives with the repo that holds it, not in a central table that would drift.

### Contract placement within the bus: producer-owned source, read-only mirror only

The context-bus row above lists "aggregated OpenAPI contracts." That aggregation is a **read-only mirror — and nothing more.** API contracts follow the same "single source of truth, referenced not copied" rule as the architecture prose, but with a different transport:

- **Source of truth = the delivering service repo.** Each service's OpenAPI 3.x spec is generated from its own code (Swagger Core) and published **by Gradle, via the `maven-publish` plugin, as a Maven-format artefact** (`uk.gov.hmcts.ctam:api-ctam-{service}:{version}`) to the internal artefact repository. The spec is a build output of the service, so it must live where that code lives — otherwise contract and implementation drift, and Spectral/Pact checks can't gate the spec against its own service in CI.
- **Distribution = version-pinned artefact.** Consumers (other services, `ctam-ui`, `ctam-admin-ui`) depend on a **pinned version** of the producer's artefact and generate their clients from it — structurally identical to a repo pinning `ctam-architecture@arch-vN` as a submodule. Same principle, per-service granularity.
- **`ctam-architecture` holds a READ-ONLY MIRROR.** The aggregated specs under `ctam-architecture/api-specs/` exist only for **discovery, the shared Spectral ruleset, and diagram wiring**. They are:
  - **regenerated by automation** on producer release — **never hand-edited**;
  - **never a build dependency** — consumers pin the producer's Maven-format artefact, not the mirror;
  - **not a source of truth** — the producing repo always wins on any discrepancy.

> **Rule:** the architecture repo never *owns* a contract and never *serves* one to a build. It reflects contracts; it does not hold them. Hand-editing the mirror, or consuming it as source, re-introduces the exact drift this model exists to prevent.

## Decision 2 — Sequencing driver: the epics themselves

*Rewritten 2026-08-19 (SCP 2026-08-19d). This decision previously introduced a bespoke `delivery/dispatch-graph.yaml`. That file has been retired: five of its nine fields duplicated the epic files (title, story list, phase, `decomposed`) or the bus tag (`bus_version`), no BMad skill ever read it, and the two fields that mattered belong on the epic itself.*

Build order is **structured data on each epic**, in its frontmatter:

```yaml
epic: 0.1
title: 'Upstream JOH/MRD reference data is ingested'
storyCount: 4
repo: ctam-reference-data          # or a list: [ctam-authorisation, ctam-mock-auth, ctam-ui]
depends_on: [epic-0.0, epic-0.6]   # epic ids, resolved against sprint-status.yaml
```

Two fields, on the artefact that is already authored, parsed and version-controlled — and the artefact `bmad-sprint-planning` already reads.

**Why on the epic rather than in a graph file:**

- **`repo:` has nowhere else structured to live.** BMad has no concept of which repository a story lands in; a 16-repo polyrepo needs one. Previously it existed only in epic prose.
- **`depends_on:` is a property of the epic**, not of a separate index. Keeping it beside the epic means it cannot fall out of step with the epic it describes.
- **No duplication.** The story list, title, phase and decomposition state are already in the epic file and in `sprint-status.yaml`; a graph repeated all four.
- **No second `bus_version` claim.** The graph asserted one; the real pin is each repo's submodule. Two claims is a drift risk, not a convenience.

**Buildable-now rule:** an epic is dispatchable iff every id in its `depends_on` is `done` in `sprint-status.yaml`. Epics with disjoint dependency sets and no shared state may run **in parallel** — the core advantage of AI-led delivery. Epic 0.5 (Notification) needs only the estate, so it can run alongside 0.1/0.2.

This is checked by `scripts/dispatch-preflight.sh <story-id>`, which is read-only and also confirms the story is still `backlog` and that no branch on the target remote already claims it (see *Multi-user coordination* below).

**Phases 1–8** are not yet decomposed into epics, so they have no frontmatter to carry. Their dependency edges are recorded as prose in [`../epics/framework.md`](../epics/framework.md) → *Phase dependency order*, and each phase gains structured frontmatter when `bmad-create-epics-and-stories` runs for it.

## The per-story delivery flow

Each story travels the same four steps. The "transport" is a **lossless generate**, not a copy — so there is no independent copy to drift.

```
[ctam-analysis: control plane]                    [ctam-{service}: execution unit]
        │
  1. DISPATCH ──────────────────────────────────────────┐
     compile story + Gherkin ACs + needed arch context   │
     + pinned bus version  →  story packet                │
        │                                                 ▼
        │                                    2. LAND on branch story/<id>: packet
        │                                       committed + pushed = the claim
        │                                                 │
        │                                                 ▼
        │                                    3. EXECUTE dev-story session in-repo
        │                                       reads CLAUDE.md → _arch/ (pinned bus)
        │                                       implements; diff surfaced for VSCode commit
        │                                                 │
  4. SIGNAL ◄─────────────────────────────────────────────┘
     sprint-status.yaml updated: story -> done  (bmad-sprint-status)
```

Mapped to the installed BMAD skills:

| Step | Skill(s) | Runs in |
|---|---|---|
| 1 · Dispatch | `bmad-create-story` / `compile-epic-context` — "all the context the agent will need to implement it later" | `ctam-analysis` |
| 2 · Land | packet committed on `story/<id>` in the target repo and pushed — the branch is the claim | target repo |
| 3 · Execute | `bmad-dev-story` (then `bmad-code-review`, `bmad-checkpoint-preview`) | target repo |
| 4 · Signal | `bmad-sprint-status` updating `sprint-status.yaml` | `ctam-analysis` |
| Sprint setup | `bmad-sprint-planning` parses the epics → `sprint-status.yaml`; `scripts/dispatch-preflight.sh` picks the next buildable story | `ctam-analysis` |

### Story packet schema (`docs/stories/<id>.md` in the target repo)

*Rewritten 2026-08-19 (SCP 2026-08-19b). The earlier version of this section specified a bespoke layout while the table above mapped dispatch to `bmad-create-story` — two incompatible instructions three lines apart. A hand-authored packet followed the layout, `bmad-dev-story` then had no `## Tasks / Subtasks` to work through and no `## Dev Agent Record` to write into, and the pilot caught it. The contract below removes the contradiction.*

**The packet is BMad's story template, plus CTAM's polyrepo fields. Three rules, in priority order:**

1. **Every top-level section is BMad's** — `## Story`, `## Acceptance Criteria`, `## Tasks / Subtasks`, `## Dev Notes`, `## Dev Agent Record`, and `### File List` — at BMad's heading level, with BMad's spelling. `bmad-dev-story` reads and writes them by exact heading; renaming or dropping one breaks the dev workflow.
2. **CTAM content is added only as frontmatter and as subsections of `## Dev Notes`.** Never as a new top-level section. Context distilled from the bus, the rules that apply, out-of-scope boundaries, recorded deviations and definition-of-done deltas are all `###` under Dev Notes.
3. **There is exactly one status: the `Status:` line, in BMad's vocabulary** (`ready-for-dev | in-progress | review | done`). The packet frontmatter carries **no** `status` key. `sprint-status.yaml` uses the same vocabulary, so a status means one thing everywhere: set the story to `ready-for-dev` there in the same change that lands the packet.

Canonical template, versioned with the bus so every repo gets the same one:

    ctam-architecture/agent-rules/templates/story-packet.md

```markdown
---
story_id: 0.1.4
epic: epic-0.1-upstream-reference-data-ingested
repo: ctam-reference-data
bus_version: arch-v1.0            # the target repo's actual _arch pin, not an aspiration
frs: [FR6, FR7]
nfrs: [NFR24]
depends_on_stories: [0.0.3]       # optional intra-graph prerequisites
sprint_status_key: 0-1-4-mrd-supplementary-reference-data-is-ingested-from-the-weekly-excel-feed
---
# Story 0.1.4: <title>
Status: ready-for-dev
## Story                    (as a / I want / so that)
## Acceptance Criteria      (numbered; Gherkin inside an item — AC-3 must resolve to item 3)
## Tasks / Subtasks         (checkboxes citing AC numbers, ordered as the TDD loop will run)
## Dev Notes
### Context distilled from the bus     ← what this story needs, cited; not the whole architecture
### Rules that apply                   ← the agent-rules ids that will bite on this story
### Project Structure Notes            ← expected files; variances with rationale
### Out of scope / boundaries
### Recorded deviations                ← omit entirely when there are none
### Definition of done                 ← only the deltas from 90-definition-of-done.md
### References                         ← [Source: _arch/architecture/<file>.md#<heading>]
## Dev Agent Record
### Agent Model Used
### Debug Log References
### Completion Notes List   (red/green evidence per R2, gate output per R12)
### File List               (written by the implementing session)
```

**Enforcement, because prose did not hold:**

- **`ctam-analysis/scripts/validate-story-packet.sh <packet>`** fails on a missing BMad section, a CTAM section promoted to top level, a missing frontmatter key, a duplicate `status:` key, an out-of-vocabulary `Status:`, unnumbered ACs, or absent task checkboxes. Run it before a packet is reported ready.
- **`_bmad/custom/bmad-create-story.toml`** (committed team customization) points the skill at the canonical template, at the target-repo output location, and at the validator. This is why the reconciliation is executable rather than aspirational.

**Prerequisite, easy to miss:** `bmad-create-story` refuses to run without `{implementation_artifacts}/sprint-status.yaml`, which only `bmad-sprint-planning` creates. Dispatch therefore starts with sprint planning, once per phase — not with story creation.

### Programme progress (`_bmad-output/implementation-artifacts/sprint-status.yaml`)

*Replaced the bespoke per-epic ledger 2026-08-19 (SCP 2026-08-19d). The ledger carried `status`, `owner`, `pr`, `repo`, `frs` and `bus_version` per story; at the point it was retired every entry still read `not-started` / `owner: null` / `pr: null`, so no state was lost.*

One authoritative view of programme progress — the thing a fat orchestrator would give you, without the coupling — generated by `bmad-sprint-planning` from the epic files:

```yaml
development_status:
  epic-0.1: backlog
  0-1-1-scaffold-ctam-reference-data-from-the-hmcts-starter: backlog
  0-1-2-tier-a-upstream-jo-tables-ctam-sync-status-and-tier-a-write-protection: backlog
  ...
  epic-0.1-retrospective: optional
```

**One status vocabulary**, BMad's: stories `backlog → ready-for-dev → in-progress → review → done`; epics `backlog → in-progress → done`. The story packet's `Status:` line uses the same words. There is no second vocabulary anywhere — the previous two-vocabulary arrangement was the source of a documented contradiction.

**What BMad does not model, and where it now lives instead:**

| Fact | Home |
|---|---|
| Target repo | the epic's `repo:` frontmatter, and the packet's `repo:` |
| Requirements traced | the packet's `frs:` / `nfrs:` frontmatter |
| Bus version built against | the packet's `bus_version:`, and the repo's `CLAUDE.md` |
| PR link | the PR itself, and the packet's *Dev Agent Record* |
| Who is working on it | **the branch on the target remote** — a branch is the claim |

**Reverse lookups** the ledger used to answer — *which stories cover FR6? which repos are on which bus version?* — are now **generated** from packet frontmatter rather than maintained by hand. That trades an always-available table for one that has to be produced, and buys the elimination of a hand-maintained copy that would drift.

**Multi-user coordination** is by convention: **one dispatcher at a time.** `sprint-status.yaml` is a single file, so concurrent dispatch would conflict on it. `scripts/dispatch-preflight.sh` is the backstop — read-only, and it refuses a story that is not `backlog`, that a remote branch already claims, or whose prerequisites are not `done`. Execution parallelises freely, because it happens in different service repos.

## Human gates and the branch-protection constraint

*Revised 2026-08-19 (SCP 2026-08-19c). The original constraint was "Claude performs no git operations"; the gate is now the pull request.*

An agent **may** create a feature branch, commit to it, and push it. An agent **may not** write to a protected branch (`main`/`master`), force-push, delete or rename branches, create tags, discard uncommitted work, or use `gh`/`hub`. Opening, approving and merging the pull request are the human's, backed by server-side branch protection.

Enforced by `.claude/hooks/block-git-writes.sh` (the same file in every repo, published on the bus at `agent-rules/enforcement/claude/hooks/`), which resolves the current branch — including on an unborn branch in a freshly initialised repo — and refuses history-writing operations while HEAD is protected.

**Why this is still a real gate, and a better one than "no commits":**

- **The review boundary is unchanged.** Nothing reaches `main` without a human reading a diff. What changed is *where* the human reads it: a PR with commit-by-commit history, instead of an uncommitted working tree in someone's editor.
- **The history becomes evidence.** Red-green cycles committed as they happen are reviewable; the same work squashed into a human's single commit is not. This matters more in AI-led delivery than in hand-written code, because the sequence is the thing a reviewer needs to check (**R2**).
- **Per-repo CODEOWNERS and branch protection do the enforcing**, which is what they exist for — rather than a convention that every agent must remember.
- **Tags stay human** because `arch-vN` is consumed by pinned submodules across the polyrepo: a stray tag silently changes what every downstream repo can adopt.

Dispatch and signal steps in `ctam-analysis` follow the same rule: a branch and a PR, not a direct write to `main`.

## Parallel execution

Because polyrepo has no shared runtime state, stories whose dependencies are satisfied can be implemented concurrently — one isolated Claude session (or git worktree) per repo. Each epic's `depends_on` frontmatter plus `sprint-status.yaml` make the safe-to-parallelise set explicit at any moment; `scripts/dispatch-preflight.sh` reports it per story. Recommended ceiling: parallelise across *repos*, serialise *within* a repo (per-repo history stays linear and reviewable).

## What this means for the two planning homes

- **`ctam-analysis` (this workspace)** stays the canonical author of PRD/architecture/epics/stories. Its delivery state is BMad's own `implementation-artifacts/sprint-status.yaml`; the polyrepo facts BMad does not model (`repo:`, `depends_on:`) sit in each epic's frontmatter. It holds no bespoke tracking artefact.
- **`ctam-architecture`** becomes the *published* context bus — a mirror/publish target of the canonical architecture, tagged per version (`arch-vN`), consumed by every service repo as a pinned submodule. When it is scaffolded, this operating-model shard travels into it with the rest of the architecture, per [`./repo-structure.md`](./repo-structure.md)'s `decisions/` + `architecture/` layout.

## Bootstrapping order (first moves)

1. Publish `ctam-architecture` and tag `arch-v1.0` (the current architecture set becomes the first bus version).
2. Run `bmad-sprint-planning` in this workspace to generate `sprint-status.yaml` from the epics. `bmad-create-story` cannot run without it.
3. Scaffold `ctam-shared-infrastructure` (no `depends_on`) via `ctam-scaffold.sh`; wire its `_arch/` submodule + `CLAUDE.md`.
4. Dispatch epic 0.0's stories → execute → signal. Then follow the graph: mock-auth / reference-data / notification (parallelisable) → authorisation → UI shell.
```
