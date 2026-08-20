---
id: agent-rules
title: CTAM Agent Delivery Rules — the how-we-work contract
status: draft
bus_version: unpublished (targets arch-v1.0)
last_updated: 2026-08-19
---

# CTAM Agent Delivery Rules

> The **how-we-work** contract for every CTAM Pathfinder Java service repo. Binding on AI agents (Claude Code) and on human developers alike.

## What this is — and what it is not

| | Answers | Lives in |
|---|---|---|
| **`project-context.md`** (control plane) | **What** to build: stack, naming, API shapes, table ownership | `ctam-analysis/_bmad-output/project-context.md` |
| **`architecture/conventions.md`** (this repo, published) | **What** the conventions are, in full detail | `_arch/architecture/conventions.md` |
| **`agent-rules/`** (this directory) | **How** to work: TDD discipline, modularity limits, uncertainty protocol, definition of done | `_arch/agent-rules/` |

These rules never restate a convention. Where a convention already exists, the rule **points at it**. A rule that duplicates `conventions.md` is a bug in this pack — one authored copy of every fact.

## Who this binds

Every session that edits code in one of the twelve Java execution units:

`ctam-mock-auth` · `ctam-reference-data` · `ctam-authorisation` · `ctam-notification` · `ctam-joh` · `ctam-absence` · `ctam-vacancy` · `ctam-booking` · `ctam-sitting` · `ctam-payment` · `ctam-itinerary` · `ctam-mi-feed`

**Not yet covered:** `ctam-ui` / `ctam-admin-ui` (React/TypeScript) and `ctam-shared-infrastructure` (Terraform/Helm). Those need their own packs — until they exist, the core rules (R1–R14) still apply to conduct, but there are no language-specific rules or enforcers for them.

## How these rules reach a service repo

Per the delivery operating model (`delivery-operating-model.md` — canonical in the control plane at `ctam-analysis/_bmad-output/planning-artifacts/architecture/` until the architecture set is published here), this repository is the **context bus**. A service repo embeds it as a git submodule pinned to an exact tag:

```
ctam-{service}/
├── CLAUDE.md          # generated from agent-rules/enforcement/claude/CLAUDE.md.template
│                      # — the always-on core; names the pinned bus version
├── _arch/             # submodule → ctam-architecture @ arch-vN
│   ├── agent-rules/   # THIS directory — read on demand, per the index in CLAUDE.md
│   └── architecture/  # conventions.md, data-tables.md, …
└── docs/stories/<id>.md
```

The rules therefore behave exactly like the rest of the bus: **one authored copy**, version-pinned, adopted by a deliberate submodule bump PR. They never change under a repo's feet mid-story.

**Setting that shape up in a new repo, step by step:** [`../runbooks/github-setup.md`](../runbooks/github-setup.md) — manual GitHub web-UI repo creation, branch protection, `CODEOWNERS`, and the per-repo wiring of this pack (`_arch` pin, generated `CLAUDE.md`, `.claude/` hooks) with a verification step.

## Publication status (read this first)

The architecture payload **is now published here** (`architecture.md`, `architecture/*.md`, `prd.md`) by
`ctam-analysis/scripts/publish-arch.sh`, so citations of the form `_arch/architecture/conventions.md`
resolve. Two things to know:

- **Those files are mirrors — never hand-edit them.** The canonical source is
  `ctam-analysis/_bmad-output/planning-artifacts/`; see [`../architecture/PUBLISHED.md`](../architecture/PUBLISHED.md).
  `agent-rules/` itself is **not** a mirror — it is authored here.
- **The `arch-v1.0` tag is not published yet.** Until it is, no service repo can pin this bus and no
  `_arch/` submodule can be added. Tagging is the remaining half of bootstrap step 1 in the delivery
  operating model.

Not published here yet: `diagrams/`, `sequence-diagrams/` and `architecture/analysis/` — nothing in this
pack cites them. Add them to `publish-arch.sh` when a consumer needs them, rather than copying files by hand.

## Rule ID namespaces

Rule IDs are **permanent**. A withdrawn rule keeps its ID and is marked withdrawn; IDs are never recycled. This is what makes a citation in a PR or a story packet resolvable years later.

| Prefix | Domain | File |
|---|---|---|
| **R** | Core non-negotiables (always in context) | [`00-core.md`](./00-core.md) |
| **T** | Tests & the TDD loop | [`10-tdd.md`](./10-tdd.md) |
| **M** | Modularity, size limits, layering | [`20-modularity.md`](./20-modularity.md) |
| **C** | API contracts & error shapes | [`30-api-contracts.md`](./30-api-contracts.md) |
| **P** | Persistence, entities, Liquibase | [`40-data-and-liquibase.md`](./40-data-and-liquibase.md) |
| **S** | Security, secrets, logging | [`50-security-and-logging.md`](./50-security-and-logging.md) |
| **W** | Session & workflow protocol | [`60-session-protocol.md`](./60-session-protocol.md) |
| **Q** | Definition of done / quality gate | [`90-definition-of-done.md`](./90-definition-of-done.md) |

No collision with the programme's existing namespaces: `FR`/`NFR` (requirements), `D` (locked decisions), `G` (gaps), `A` (assumptions), `AR` (architecture requirements).

## Enforcement

Prose states a rule once; code enforces it once. The mapping — **every rule ID → its enforcer, and the rules that have none** — is in [`enforcement/README.md`](./enforcement/README.md). A rule whose enforcer column reads *review only* is a known soft spot, deliberately visible rather than implied.

Three enforcers, three jobs, no overlap:

- **Spotless** — formatting only. Never a structural opinion.
- **Checkstyle** — size and complexity limits inside a file.
- **ArchUnit** — relationships between types and packages.

Plus **JaCoCo** (coverage floor), **PIT** (mutation threshold), **Spectral** (OpenAPI ruleset), **Pact** (contract verification), and two **Claude Code hooks** (`block-git-writes`, `require-red-test`).

## Amending these rules

Additive, auditable, never retroactive — the same path as any other convention change:

1. Sprint Change Proposal in `ctam-analysis/_bmad-output/planning-artifacts/`, plus a `changelog.md` entry.
2. Change lands here; this repo is tagged `arch-v(N+1)`.
3. Each service repo adopts it by an explicit submodule bump PR. **Repos are not force-retrofitted** — consistent with `conventions.md` → *When patterns evolve*.

A rule may be **tightened** for new code at any time. Existing code is brought up to a tightened rule only when a story next touches it — never as an unrequested sweep (R14).

## Provenance of pinned tool versions

Verified 2026-08-19; re-verify at scaffold time (R7 applies to this pack too):

| Tool | Version | Note |
|---|---|---|
| Checkstyle | `14.0.0` | Builds and parses Java 25 sources |
| Spotless Gradle plugin | `8.10.0` | |
| JaCoCo | `0.8.14` | First release with **official** Java 25 support (0.8.13 was experimental) |
| ArchUnit | `1.5.0` (`archunit-junit5`) | See the JUnit-platform caveat in [`enforcement/README.md`](./enforcement/README.md) |
| gradle-pitest-plugin | `1.19.0` | |
| pitest | `1.25.9` | Java 25 mutator fixes landed in 1.25.8 |
| pitest-junit5-plugin | `1.2.3` | |
