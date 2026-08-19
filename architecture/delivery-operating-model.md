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
| **Control plane** | `ctam-analysis` (this workspace) | Canonical PRD/architecture/epics/stories · sprint & story queue · the machine-readable **dispatch graph** · the **traceability ledger** (FR/NFR → epic → story → repo → PR) · story-packet generation ("dispatch") | Edit service code |
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

Consequence: a convention change is **one PR in `ctam-architecture`** (publish `arch-v(N+1)`) **+ one deliberate bump PR per repo that adopts it** — auditable, staged, reversible. This is precisely what prevents "central truth" from becoming "16 things silently drifting." Repos may sit on different bus versions intentionally (e.g. a phase-6 service on `arch-v1.9` while phase-1 services haven't yet needed the bump); the ledger records each repo's pinned version.

### Contract placement within the bus: producer-owned source, read-only mirror only

The context-bus row above lists "aggregated OpenAPI contracts." That aggregation is a **read-only mirror — and nothing more.** API contracts follow the same "single source of truth, referenced not copied" rule as the architecture prose, but with a different transport:

- **Source of truth = the delivering service repo.** Each service's OpenAPI 3.x spec is generated from its own code (Swagger Core) and published **by Gradle, via the `maven-publish` plugin, as a Maven-format artefact** (`uk.gov.hmcts.ctam:api-ctam-{service}:{version}`) to the internal artefact repository. The spec is a build output of the service, so it must live where that code lives — otherwise contract and implementation drift, and Spectral/Pact checks can't gate the spec against its own service in CI.
- **Distribution = version-pinned artefact.** Consumers (other services, `ctam-ui`, `ctam-admin-ui`) depend on a **pinned version** of the producer's artefact and generate their clients from it — structurally identical to a repo pinning `ctam-architecture@arch-vN` as a submodule. Same principle, per-service granularity.
- **`ctam-architecture` holds a READ-ONLY MIRROR.** The aggregated specs under `ctam-architecture/api-specs/` exist only for **discovery, the shared Spectral ruleset, and diagram wiring**. They are:
  - **regenerated by automation** on producer release — **never hand-edited**;
  - **never a build dependency** — consumers pin the producer's Maven-format artefact, not the mirror;
  - **not a source of truth** — the producing repo always wins on any discrepancy.

> **Rule:** the architecture repo never *owns* a contract and never *serves* one to a build. It reflects contracts; it does not hold them. Hand-editing the mirror, or consuming it as source, re-introduces the exact drift this model exists to prevent.

## Decision 2 — Sequencing driver: a machine-readable dispatch graph

The build order is **encoded as data in the control plane**, not re-decided conversationally each sprint. This makes dispatch **deterministic**: given the ledger state, the "next buildable story" is a lookup, not a judgement call, and independent work is visible for safe parallel fan-out.

The graph lives at `_bmad-output/planning-artifacts/delivery/dispatch-graph.yaml` and encodes repo- and epic-level dependencies derived from [`./repository-strategy.md`](./repository-strategy.md) and [`../epics/framework.md`](../epics/framework.md):

```yaml
# dispatch-graph.yaml — repo build order + dependencies. Source of truth for "what's next".
bus_version: arch-v1.0          # current published context-bus version
repos:
  ctam-shared-infrastructure:
    phase: 0
    depends_on: []              # nothing precedes the estate
    epics: [epic-0.0]
  ctam-mock-auth:
    phase: 0
    depends_on: [ctam-shared-infrastructure]
    epics: [epic-0.2]           # dev/CI OIDC issuer, needed before auth integration
  ctam-reference-data:
    phase: 0
    depends_on: [ctam-shared-infrastructure]
    epics: [epic-0.1, epic-0.3] # integrations-first: jo_people before sign-in
  ctam-authorisation:
    phase: 0
    depends_on: [ctam-shared-infrastructure, ctam-mock-auth, ctam-reference-data]
    epics: [epic-0.2, epic-0.4]
  ctam-notification:
    phase: 0
    depends_on: [ctam-shared-infrastructure]
    epics: [epic-0.5]
  ctam-ui:
    phase: 0
    depends_on: [ctam-authorisation]
    epics: [epic-0.ui-shell]
  ctam-joh:        { phase: 1, depends_on: [ctam-authorisation, ctam-reference-data], epics: [] }
  ctam-absence:    { phase: 2, depends_on: [ctam-joh, ctam-notification], epics: [] }
  ctam-vacancy:    { phase: 3, depends_on: [ctam-absence], epics: [] }
  ctam-booking:    { phase: 4, depends_on: [ctam-vacancy], epics: [] }
  ctam-sitting:    { phase: 5, depends_on: [ctam-joh], epics: [] }
  ctam-payment:    { phase: 6, depends_on: [ctam-booking, ctam-sitting, ctam-notification], epics: [] }
  ctam-itinerary:  { phase: 7, depends_on: [ctam-joh, ctam-absence, ctam-vacancy, ctam-booking, ctam-sitting], epics: [] }
  ctam-mi-feed:    { phase: 8, depends_on: [ctam-itinerary], epics: [] }
  ctam-admin-ui:   { phase: post-mvp, depends_on: [ctam-reference-data, ctam-authorisation], epics: [] }
```

**Buildable-now rule:** a story is dispatchable iff every repo in its `depends_on` has its prerequisite epics marked `done` in the ledger. Anything with all-satisfied dependencies and no shared state can run **in parallel** — the core advantage of AI-led delivery over sequential human squads. `phases 1–8` epics are populated into this graph as they are decomposed (only phase 0 is decomposed today).

## The per-story delivery flow

Each story travels the same four steps. The "transport" is a **lossless generate**, not a copy — so there is no independent copy to drift.

```
[ctam-analysis: control plane]                    [ctam-{service}: execution unit]
        │
  1. DISPATCH ──────────────────────────────────────────┐
     compile story + Gherkin ACs + needed arch context   │
     + pinned bus version  →  story packet                │
        │                                                 ▼
        │                                    2. LAND packet as docs/stories/<id>.md
        │                                       (Claude writes files; human commits via VSCode)
        │                                                 │
        │                                                 ▼
        │                                    3. EXECUTE dev-story session in-repo
        │                                       reads CLAUDE.md → _arch/ (pinned bus)
        │                                       implements; diff surfaced for VSCode commit
        │                                                 │
  4. SIGNAL ◄─────────────────────────────────────────────┘
     ledger updated: story done, repo, PR link, bus version
```

Mapped to the installed BMAD skills:

| Step | Skill(s) | Runs in |
|---|---|---|
| 1 · Dispatch | `bmad-create-story` / `compile-epic-context` — "all the context the agent will need to implement it later" | `ctam-analysis` |
| 2 · Land | file write into target repo working tree (human commits) | target repo |
| 3 · Execute | `bmad-dev-story` (then `bmad-code-review`, `bmad-checkpoint-preview`) | target repo |
| 4 · Signal | `bmad-sprint-status` / `bmad-sprint-planning` updating the ledger | `ctam-analysis` |
| Sprint setup | `bmad-sprint-planning` reads `dispatch-graph.yaml` → next buildable stories | `ctam-analysis` |

### Story packet schema (`docs/stories/<id>.md` in the target repo)

Self-contained so the repo is readable standalone by a fresh Claude session *or* a human HMCTS dev:

```markdown
---
story_id: 0.1.4
epic: epic-0.1-upstream-reference-data-ingested
repo: ctam-reference-data
bus_version: arch-v1.0
frs: [FR6, FR7, NFR24]
depends_on_stories: [0.0.3]      # optional intra-graph prerequisites
status: dispatched               # dispatched | in-progress | in-review | done
---
# Story 0.1.4 — <title>
## Context (distilled, from ctam-architecture @ arch-v1.0)   ← what this story needs, not the whole arch
## Acceptance criteria (Gherkin, verbatim from the epic)
## Out of scope / boundaries
## Definition of done (tests, ArchUnit, Spectral, UAT hooks per repo-structure.md)
```

### Traceability ledger (`_bmad-output/planning-artifacts/delivery/ledger/` — sharded per epic)

One authoritative view of programme progress — the thing a fat orchestrator would give you, without the coupling. It is **sharded one file per epic** (`ledger/epic-0.x.yaml`) so multiple people update different epics without git conflicts; each shard carries epic-level `status`+`owner` and per-story `status`+`owner`+`pr` for "who is working on what" visibility (schema + concurrency rules in `delivery/ledger/README.md`):

```yaml
# ledger/epic-0.1.yaml
epic: epic-0.1
title: Upstream JOH/MRD reference data is ingested
repo: ctam-reference-data
status: in-progress            # epic rollup: not-started | in-progress | blocked | in-review | done
owner: alice
stories:
  - story: 0.1.4
    repo: ctam-reference-data
    frs: [FR6, FR7, NFR24]
    bus_version: arch-v1.0
    status: done               # not-started | dispatched | in-progress | in-review | done
    owner: bob
    pr: https://github.com/hmcts/ctam-reference-data/pull/12
```

Reverse lookups it enables: *which stories cover FR6?* · *which repos are on which bus version?* · *what's blocked vs. buildable-now?* · *who owns each epic/story?* · *is every FR/NFR delivered?*

## Human gates and the git-write constraint

Claude does not perform git operations in this programme (per the repo-root [`CLAUDE.md`](../../../CLAUDE.md); enforced by the `.claude/hooks/block-git-writes.sh` hook in this workspace). That is a **feature of this model, not friction**: each repo boundary is a deliberate human gate. Claude *prepares* work (generates packets, writes code, surfaces diffs); the human reviews and commits via VSCode — which is exactly what per-repo CODEOWNERS/branch-protection exist to enforce. Dispatch and signal steps likewise produce reviewable diffs in `ctam-analysis`, committed the same way.

## Parallel execution

Because polyrepo has no shared runtime state, stories whose dependencies are satisfied can be implemented concurrently — one isolated Claude session (or git worktree) per repo. The `dispatch-graph.yaml` makes the safe-to-parallelise set explicit at any moment. Recommended ceiling: parallelise across *repos*, serialise *within* a repo (per-repo history stays linear and reviewable).

## What this means for the two planning homes

- **`ctam-analysis` (this workspace)** stays the canonical author of PRD/architecture/epics/stories and gains two new control-plane artefacts: `delivery/dispatch-graph.yaml` and `delivery/ledger/` (traceability ledger, sharded per epic).
- **`ctam-architecture`** becomes the *published* context bus — a mirror/publish target of the canonical architecture, tagged per version (`arch-vN`), consumed by every service repo as a pinned submodule. When it is scaffolded, this operating-model shard travels into it with the rest of the architecture, per [`./repo-structure.md`](./repo-structure.md)'s `decisions/` + `architecture/` layout.

## Bootstrapping order (first moves)

1. Publish `ctam-architecture` and tag `arch-v1.0` (the current architecture set becomes the first bus version).
2. Encode `dispatch-graph.yaml` + initialise the per-epic `delivery/ledger/` shards in this workspace.
3. Scaffold `ctam-shared-infrastructure` (no `depends_on`) via `ctam-scaffold.sh`; wire its `_arch/` submodule + `CLAUDE.md`.
4. Dispatch epic 0.0's stories → execute → signal. Then follow the graph: mock-auth / reference-data / notification (parallelisable) → authorisation → UI shell.
```
