---
type: 'Architecture'
title: 'Architecture Decision Document'
description: 'architecture.md is the architectural index. Implementation-detail content (code-tree inventories, gap and assumption registers, the per-service convention catalogue, per-table inventory, sequence…'
resource: 'architecture.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-06-11'
stepsCompleted: ['step-01-init', 'step-02-context', 'step-03-starter', 'step-04-decisions', 'step-05-patterns', 'step-06-structure', 'step-07-validation', 'step-08-complete']
lastStep: 8
status: 'complete'
completedAt: '2026-05-06'
amendedAt: '2026-06-11'
amendmentSource: '_bmad-output/planning-artifacts/sprint-change-proposal-2026-06-10.md'
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/sprint-change-proposal-2026-06-10.md'
  - '_bmad-output/brainstorming/brainstorming-session-2026-05-05-1600.md'
  - 'docs/architecture/asis/functional-modules.md'
  - 'docs/architecture/asis/data-dependencies.md'
  - 'docs/architecture/asis/integration-dependencies.md'
workflowType: 'architecture'
project_name: 'ctam-analysis'
productCodename: 'CTAM Pathfinder'
user_name: 'Ramnish'
date: '2026-06-11'
---

# Architecture Decision Document

`architecture.md` is the **architectural index**. Implementation-detail content (code-tree inventories, gap and assumption registers, the per-service convention catalogue, per-table inventory, sequence diagrams, changelog history) lives in sibling files under [`./architecture/`](./architecture/) and is referenced from this file in place. Read this file for the *what and why*; follow links into the siblings for the *how*.

## Contents

1. [System context — at a glance](#system-context--at-a-glance)
2. [How this document is structured](#how-this-document-is-structured)
3. [Project Context Analysis](#project-context-analysis)
   1. [Requirements Overview](#requirements-overview)
   2. [Technical Constraints & Dependencies](#technical-constraints--dependencies)
   3. [Cross-Cutting Concerns Identified](#cross-cutting-concerns-identified)
   4. [Architecture-phase decisions still open](#architecture-phase-decisions-still-open)
4. [Starter Template Evaluation](#starter-template-evaluation)
   1. [Foundational Principles](#foundational-principles)
   2. [Primary Technology Domain](#primary-technology-domain)
   3. [Starter Options & Selection](#starter-options--selection)
   4. [Initialisation Flow, Build Tool, Dependency Inventory, Per-service Conventions](#initialisation-flow-build-tool-dependency-inventory-per-service-conventions)
5. [Core Architectural Decisions](#core-architectural-decisions)
   1. [Decision Priority Analysis](#decision-priority-analysis)
   2. [Data Architecture](#data-architecture)
   3. [Authoritative Table Ownership Mapping](#authoritative-table-ownership-mapping)
   4. [Authentication & Security](#authentication--security)
   5. [API & Communication Patterns](#api--communication-patterns)
   6. [Frontend Architecture](#frontend-architecture)
   7. [Infrastructure & Deployment](#infrastructure--deployment)
   8. [Deployment topology — single Azure region, multi-AZ HA](#deployment-topology--single-azure-region-multi-az-ha)
   9. [Decision Impact Analysis](#decision-impact-analysis)
   10. [TBDs Resolved by This Step](#tbds-resolved-by-this-step)
6. [Implementation Patterns & Consistency Rules](#implementation-patterns--consistency-rules)
7. [Project Structure & Boundaries](#project-structure--boundaries)
   1. [Repository Strategy & List](#repository-strategy--list)
   2. [Complete Project Directory Structures](#complete-project-directory-structures-per-service--ui--ctam-architecture)
   3. [Architectural Boundaries](#architectural-boundaries)
   4. [Requirements to Structure Mapping](#requirements-to-structure-mapping)
   5. [Cross-Cutting Concerns to File Locations](#cross-cutting-concerns-to-file-locations)
   6. [Integration Points — Internal](#integration-points--internal-communication)
   7. [Integration Points — External](#integration-points--external)
   8. [Data Flow — Canonical Operational Cycle](#data-flow--canonical-operational-cycle-journey-2-from-prd--courts-wave-2)
   9. [File Organisation, Development Workflow, Deployment Pipeline](#file-organisation-development-workflow-deployment-pipeline)
   10. [Wave rollout flow (Phase 9+)](#wave-rollout-flow-phase-9-jurisdiction-first)
8. [Architecture Validation Results](#architecture-validation-results)
   1. [Coherence Validation](#coherence-validation-white_check_mark)
   2. [Requirements Coverage Validation](#requirements-coverage-validation-white_check_mark)
   3. [Implementation Readiness Validation](#implementation-readiness-validation-white_check_mark)
   4. [Documented Gaps](#documented-gaps)
   5. [Assumptions](#assumptions)
   6. [Architecture Readiness Assessment](#architecture-readiness-assessment)
   7. [Implementation Handoff](#implementation-handoff)
9. [External References](#external-references)
10. [Changelog](#changelog)

## System context — at a glance

![CTAM Pathfinder System Context — high-level service map and key interactions](./architecture/diagrams/system-context.png)

*High-level service map. For detail, see the relevant section in this document or its siblings.*

## How this document is structured

| Sibling file | Contents |
|---|---|
| [`./architecture/starter-template.md`](./architecture/starter-template.md) | HMCTS Crime SpringBoot starter — initialisation flow, Gradle build tool rationale, dependency inventory, per-service CTAM Pathfinder conventions overlaid by the scaffolding script |
| [`./architecture/data-tables.md`](./architecture/data-tables.md) | Authoritative Table Ownership Mapping — CTAM Pathfinder tables grouped by owning service, including the two-tier reference-data ownership model (upstream-sourced `jo_*` / `mrd_*` tables + CTAM-owned tables) |
| [`./architecture/conventions.md`](./architecture/conventions.md) | Implementation Patterns & Consistency Rules — naming, structure, format, communication, process, enforcement |
| [`./architecture/repo-structure.md`](./architecture/repo-structure.md) | Per-service / UI / `ctam-architecture` directory structures, file organisation, deployment pipeline |
| [`./architecture/repository-strategy.md`](./architecture/repository-strategy.md) | Polyrepo strategy + the 15-repo list (per-service purpose and key functions) |
| [`./architecture/functional-requirements-coverage.md`](./architecture/functional-requirements-coverage.md) | All 60 FRs listed by capability area, with architectural support per group |
| [`./architecture/non-functional-requirements-coverage.md`](./architecture/non-functional-requirements-coverage.md) | All 42 NFRs listed by category, with architectural support per group |
| [`./architecture/sequence-diagrams/`](./architecture/sequence-diagrams/) | Mermaid sequence diagrams: user-initiated absence-to-reconciliation flow; scheduled payment-batch flow |
| [`./architecture/gaps.md`](./architecture/gaps.md) | Documented Gaps register — G1–G9 series with mitigations and owners |
| [`./architecture/assumptions.md`](./architecture/assumptions.md) | Assumptions register — A1–A37 with type and verification path |
| [`./architecture/changelog.md`](./architecture/changelog.md) | Version history v1.0 → v2.6 with pre-v1.8 anchor → current location redirect table |

**Published to the context bus (not a sibling shard):** the **agent delivery rules** live at `ctam-architecture/agent-rules/` — the *how we work* contract for the twelve Java execution units (evidence-based TDD, hard modularity limits, cite-or-ask uncertainty protocol, definition of done) plus a runnable enforcement pack (ArchUnit, Checkstyle, Gradle quality gate, Spectral, `verify.sh`, target-repo `CLAUDE.md` and hooks). Authored on the bus rather than here so there is **one** authored copy that every service repo consumes by pinned submodule, per [`./architecture/delivery-operating-model.md`](./architecture/delivery-operating-model.md). See [`./sprint-change-proposal-2026-08-19.md`](./sprint-change-proposal-2026-08-19.md).

Refactor history: the single-file `architecture.md` was split into the index + sibling structure above in v1.8 (Strategy B).

## Project Context Analysis

### Requirements Overview

**Functional Requirements (60, in 9 capability areas — renumbered 2026-06-10: the Phase 0 ETL FR was retracted and FR58–FR61 became FR57–FR60).** CTAM Pathfinder is 11 services (revised v2.2 — `ctam-configuration` dropped; per-service config in Spring profiles + Key Vault; a shared `ctam_configuration_values` table holds cross-service policy values), in three clusters:

- **Domain services** — JOH, Absence, Vacancy, Booking, Sitting, Payment. Operational chain: Manage JOHs → Absence → Vacancy → Booking → Sitting → Payment → Reconciliation. (*JOH — Judicial Office Holder — is the umbrella term[^d11]; the service is `ctam-joh`.*)
- **Cross-cutting services** — Reference Data (facade over a two-tier datastore: upstream-sourced JOH eLinks + MRD tables, read-only in CTAM, plus CTAM-owned tables — revised D3/FR6), Authorisation (gates every call; carries roles + jurisdiction + Region/Area scope[^d8]/FR2), Notification (transactional email).
- **Read-model services** — Itinerary, MI Feed. Both use SQL JOINs over the shared database.

Architectural implications:

- **One synchronous cross-service write**: `POST /bookings` marks the linked vacancy as filled in the same transaction (FR30, R5) per Principle 1. Retry safety uses native DB primitives — see *Data Architecture*.
- **Read-model federation**: SQL JOINs over the shared schema. Indexed joins meet the Forward Look NFR (≤ 30 s p95, NFR8).
- **Working-pattern sitting generation** (FR13, FR35): owned by JOH; produces records that Sitting manages from Phase 5 onwards.
- **Versioned content-type for Payment** (FR44 — `application/vnd.hmcts.jfeps+json` vs `+xlsx`). JFEPS shape is externally owned; verified for SSCS[^d11] (now wave 2). **ET wave-1 applicability unverified — G8.6**[^d13].
- **Per-service authorisation** (FR2, NFR13): every API call resolves principal → roles + **jurisdiction** + Region/Area scope through Authorisation. Implemented as middleware.
- **Upstream reference-data ingestion** (revised D3, NFR24): `ctam-reference-data` ingests the 15 `jo_*` entities from the JOH eLinks API (in-process scheduled sync) and MRD supplementary data from a weekly Excel feed (blob drop + scheduled pick-up). Tier-(a) tables are never hand-edited in CTAM; corrections happen at source.

**Non-Functional Requirements (42, in 8 categories):**

- **Performance** — page-level: ≤ 5 s dashboard, ≤ 30 s reports/Forward Look (APEX baseline). API: ≤ 500 ms p95 read, ≤ 1 s p95 write. Capacity ~50–100/region; ~200–500 national.
- **Security** — TLS only; encryption at rest; AuthN via HMCTS IdP SSO; AuthZ owned by CTAM Pathfinder; no bank details, no case-level data; aligned with GFS-7.
- **Accessibility** — WCAG 2.2 AA; tested per UI page per phase.
- **Integration** — OIDC issuer (mock auth Phase 0–8; HMCTS IdP from pre-Phase-9); JFEPS/Liberata unchanged (verified for SSCS, now wave 2; **ET wave-1 applicability unverified, G8.6**[^d13]); HMCTS email; DA&I MI Feed; **JOH eLinks API + MRD weekly Excel feed are MVP integrations** (NFR24 reframed 2026-06-10[^d11] — was "no eLinks integration in MVP").
- **Observability** — log-based MVP only[^d7]; structured logs + correlation IDs; OpenTelemetry → Application Insights.
- **Data privacy & sovereignty** — Azure UK regions only; UK GDPR + DPA 2018; no case-level data.
- **Reliability** — available during HMCTS hours; per-wave rollback; single Azure region (UK South) with multi-AZ HA; rollout isolation at the app tier via per-(jurisdiction, region) activation flags (FR57). DR is an **open gap** — see [`./architecture/gaps.md` G3.6](./architecture/gaps.md).
- **Maintainability** — API-as-Product (versioned, OpenAPI, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details); per-service deployment; manual UAT scripts per domain service (FR60 / NFR41); Postman collections per phase.

**Scale & complexity:** 11-service API backend + UI. Complexity drivers: JFEPS/Liberata payment integration, JOH eLinks + MRD upstream ingestion, cross-cutting jurisdiction-aware authorisation, jurisdiction-first phased rollout, judicial regulatory environment, manual UAT against the jurisdiction's incumbent system (`[ET-INCUMBENT-TBD]` for ET wave 1 — G8.4; ListAssist for SSCS wave 2; APEX for Courts waves 3+)[^d13].

### Technical Constraints & Dependencies

**Locked from PRD:**

- **Stack:** Java 25 (LTS) + Spring Boot 4 + Kubernetes + Microsoft Azure (UK regions only).
- **Coordination:** REST-first synchronous; no event stream, no message bus, no webhook fabric.
- **Read-model strategy:** SQL JOINs over the shared schema; no API federation, no cache fallback.
- **Identity:** OIDC issuer (mock auth Phase 0–8; HMCTS IdP from pre-Phase-9 cutover); CTAM Pathfinder owns Authorisation; password/session/account lifecycle external. Two distinct user populations[^d9]: JOHs (IdP email → `jo_people` → `personnel_number` → CTAM JOH UUID in `ctam_joh_identities`) and HMCTS admin staff (CTAM-internal staff identity table). Both populations resolve to a CTAM-assigned UUID; `personnel_number` is the upstream link, not the CTAM identifier.
- **Data residency:** Azure UK regions only (no personal data leaves the UK).
- **No bank details, no case-level data** anywhere by contract.
- **JOH eLinks API + MRD are MVP integrations** (NFR24 reframed[^d11]); other HR systems remain out of MVP scope.
- **CTAM scope boundary[^d12]:** system of record for JOH availability and scheduling only — case management, panel composition, and hearing types live in external systems that consume CTAM's APIs; no external system writes into CTAM.

**External systems (not controlled by CTAM Pathfinder):**

- **HMCTS IdP** — pre-Phase-9 hard dependency; mock auth covers Phase 0–8.
- **JOH eLinks API** — canonical upstream source for the 15 `jo_*` judicial-holder entities[^d3]. Pulled by `ctam-reference-data`'s scheduled sync; read-only in CTAM; corrections at source (Judicial Office). No data flows upstream from CTAM.
- **MRD (Master Reference Data)** — supplementary judicial reference data (notably JOH Specialisations). Weekly Excel feed for MVP (public MRD APIs not yet available); transitions to API integration when MRD APIs ship.
- **JFEPS-compatible Excel format** for Payment — externally owned; treated as a versioned content-type. Verified for SSCS[^d11] (now wave 2); **ET wave-1 applicability unverified — G8.6**[^d13].
- **HMCTS email infrastructure** for transactional notifications.
- **DA&I MI Feed consumers** (post-MVP) — they call CTAM Pathfinder APIs.
- **External case-management systems** (ET case management — system TBC per G8.5; SSCS case management (GAPS); Courts Listing systems) — consume CTAM's APIs from Phase 9 onward[^d12]; never write into CTAM.
- **Scheduling incumbents** — used by UAT users to compare behaviour per wave (`[ET-INCUMBENT-TBD]` for ET wave 1 — unidentified, G8.4; ListAssist for SSCS wave 2; APEX for Courts waves 3+)[^d13]. No programmatic linkage to CTAM Pathfinder's CI or runtime.

**Data bootstrap (no legacy migration — revised D3 + D9):** CTAM Pathfinder migrates nothing from ListAssist or APEX. Judicial-holder reference data is ingested from JOH eLinks + MRD (source-of-truth integration, not migration); historical data stays in the cohort's incumbent system. User and authorisation records (`auth_*` tables) are bootstrapped by programme-management / operational mechanisms outside the PRD's scope; every bootstrapped user must resolve to an IdP principal before that user's wave cutover. The Phase 0 Data Migration ETL is **retracted**; `ctam-architecture/migration/` is no longer a deliverable.

### Cross-Cutting Concerns Identified

Concerns that recur across most services and are addressed at the platform layer:

- **Authorisation enforcement** — every API call resolves principal → roles + jurisdiction + Region/Area scope through Authorisation (FR2, FR3). Implemented as middleware. Jurisdiction is a first-class hierarchical attribute[^d8] sourced from `jo_jurisdictions`.
- **Reference Data is single-owner, two-tier** — `ctam-reference-data` owns every reference-data table in the shared schema (FR7). **Tier (a) upstream-sourced** (`jo_*` from JOH eLinks; `mrd_*` from MRD): read-only in CTAM, refreshed by the ingestion mechanisms, corrections at source. **Tier (b) CTAM-owned** (regions, offices, calendar, operational vocabularies): maintained in CTAM — DBAs via SQL in MVP[^d10], admin UI post-MVP. Separate tables preserve lineage (FR6). Reads: direct SQL on the reference-data tables (no caching per Principle 2). Reference-data API responses are jurisdiction-filtered[^d8].
- **Per-jurisdiction + Region/Area scoping** — domain operations default-scope by jurisdiction and Region/Area from the Authorisation context (FR2, FR49). Cross-region operations are explicit.
- **Per-(jurisdiction, region) phased activation**[^d8][^d11] — CTAM Pathfinder access is gated by `ctam_auth_user_activation_flags` (FR57); the flag rows carry the (jurisdiction, region) tuple so cutover flips include both in the `WHERE` clause. Authorisation distinguishes "active in CTAM Pathfinder" from "exists in CTAM Pathfinder".
- **Retry safety via native DB primitives** — natural-key uniqueness, optimistic locking, pessimistic row locking. No custom idempotency-key tables. Detail in *Data Architecture* and [`./architecture/data-tables.md`](./architecture/data-tables.md).
- **API-as-Product compliance** — versioned contract, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details, OpenAPI per service (FR58).
- **Manual UAT** (FR60 / NFR41) — jurisdiction-incumbent-experienced users compare CTAM Pathfinder vs the incumbent per service per wave (`[ET-INCUMBENT-TBD]`-experienced users for ET wave 1; ListAssist-experienced users for SSCS wave 2; APEX-experienced users for Courts waves 3+)[^d13]; sign-off is the wave-cutover gate. No automated incumbent-comparison in CI.
- **Forbidden data** — no bank details (FR47); no case-level data (FR54). Enforced at the schema and API boundary.

### Architecture-phase decisions still open

The PRD lists 12 TBDs. 5 are programme-management decisions (capacity, ops hours, pilot region, cross-region wave handling, migration owners) — tracked in the PRD risk register, not here. The 7 architecture-phase decisions resolved here:

| # | TBD | Step where resolved |
|---|---|---|
| 1 | Rate limit policy | Step 4 (API & Communication) |
| 2 | UI framework family | Step 4 (Frontend Architecture) |
| 3 | Service-to-service authentication mechanism | Step 4 (Authentication & Security) |
| 4 | Log retention period | Step 4 (Infrastructure & Deployment) |
| 5 | API versioning specifics | Step 4 (API & Communication) |
| 6 | Historical-data access policy | Step 4 (Infrastructure & Deployment) |
| 7 | APEX ⇄ IdP identity-key scheme *(reframed 2026-06-11 — identity resolution at sign-in[^d9])* | Step 4 (Authentication & Security) |

**Architecture-phase decisions deferred to architecture by the PRD (SCP 2026-06-10), now resolved:**

| # | Decision deferred to architecture by the PRD | Resolution |
|---|---|---|
| 8 | `ctam-judge` → `ctam-joh` rename[^d11] | **Full rename** — service, repo, DB role (`ctam_joh`), and table names. Nothing is built yet, so the rename costs nothing now versus a guaranteed costlier rename after Phase 1. |
| 9 | JOH eLinks sync mechanism[^d3] | **In-process scheduled sync** — a `@Scheduled` task inside `ctam-reference-data` pulls the JOH eLinks API nightly and full-refresh-upserts the `jo_*` tables. No new service principal, no new deployable. Detail in *Data Architecture*. |
| 10 | MRD Excel ingestion mechanism[^d3] | **Blob drop + scheduled pick-up** — the weekly Excel lands in an Azure Blob container; a `@Scheduled` task in `ctam-reference-data` polls, validates, and upserts the `mrd_*` tables. Detail in *Data Architecture*. |
| 11 | Admin-staff canonical identifier[^d9] | **CTAM-assigned UUID** on `ctam_auth_staff_identities`, with IdP email as the lookup key — mirroring the JOH email → personnel-number pattern. Detail in *Authentication & Security*. |
| 12 | Integrations-first Phase 0 sequencing + integration-component hosting *(SCP 2026-06-17)* | **`ctam-reference-data` is the first service scaffolded.** The JOH eLinks + MRD ingestion is carved out as the **first Phase 0 epic**, decoupled from the auth/UI slice it was previously bundled into. Ingestion stays **in-process** inside `ctam-reference-data` (reaffirms #9/#10); **a separate `ctam-integrations` repo is declined** — tier-(a) tables are owned solely by `ctam_reference_data` (AR49), so a new deployable would break the single-writer invariant and reopen the service-auth gap (G7) for no resilience gain. Per the **AR53 first-consumer rule**, the **shared Azure estate Terraform relocates from `ctam-authorisation` to `ctam-reference-data`**. *(The shared-estate relocation part of this decision is **superseded by #13**.)* The jurisdiction-filtered Reference Data **read API remains downstream of auth** (needs `JWTFilter` for token validation + `authz/check` for the jurisdiction it filters on, D8), so it lands immediately *after* the auth epic, not in the first phase. See [`../sprint-change-proposal-2026-06-17.md`](../sprint-change-proposal-2026-06-17.md). |
| 13 | Shared infrastructure moves to a dedicated repo — CNP alignment *(SCP 2026-07-06)* | **Supersedes the AR53 "colocated first-consumer" rule from #12.** Per the HMCTS Cloud Native Platform standard that product-level shared infrastructure lives in a `{product}-shared-infrastructure` repo, the **shared Azure estate** (AKS, PostgreSQL, ACR, APIM, App Insights, Key Vault) moves **out of `ctam-reference-data`** into a new dedicated repo, **`ctam-shared-infrastructure`** (16 repos total). It is provisioned and **independently verified** in the new **Epic 0.0** — 5 stories, each a Terraform layer with a deploy-time acceptance test — ahead of any service. Service repos keep only their **own** per-repo Terraform. **AR53 revised.** Story 0.1.1 reduces to scaffold-and-deploy-onto-estate. Phase 0: 5 → 6 epics, 14 → 19 stories. **No code impact** (implementation not started). See [`../sprint-change-proposal-2026-07-06.md`](../sprint-change-proposal-2026-07-06.md). |

## Starter Template Evaluation

### Foundational Principles

#### Principle 1: API for Workflows, Shared Database for Simple Data Access

**APIs are the boundary for workflows. The shared database is the integration mechanism for simple cross-service reads and writes.**

- **Workflows go via API** — multi-step operations with business rules, state transitions, or orchestration (Booking creation, Payment processing, Absence approval).
- **Single-field cross-service updates can be direct DB writes** — e.g. Booking marks its linked vacancy as filled; Payment updates the booking's payment lifecycle status. Each owning service grants which tables/columns other services may write via explicit DB role grants (see *Data Architecture*).
- **Cross-service reads are direct SQL JOINs** — Itinerary, MI Feed, and Reference Data reads query the shared schema directly. No API fan-out, no cache.

The database is **one global PostgreSQL instance with a single shared schema**. Cross-service access is gated by **per-service DB roles with explicit grants**. Table ownership is encoded in the table name — **every CTAM-owned table carries the `ctam_` prefix**; upstream-sourced tier-(a) tables carry their source-system prefix (`jo_`, `mrd_`) — and enforced by ArchUnit fitness functions in CI.

**Why one schema, not schema-per-service:** 11 services, one team, one domain. Schema-per-service costs 11 schemas + grants + cross-schema FK overhead + per-PR coordination, with no concrete benefit at MVP. One schema supports the same DB-level access control via per-service roles.

**Why per-service DB roles, not one shared role:** per-service roles are the seam for any future schema-per-service or service extraction. ~10 minutes/role on Day 1; expensive to retrofit. They also give defense-in-depth (a Sitting repo can't write to Payment tables — DB rejects), DB-layer signal for the post-MVP user-action audit[^d7], and a reversible decision (start broad, tighten as patterns become visible).

**No shared runtime code library.** Each service owns its own cross-cutting concerns, even at the cost of boilerplate. **Changing a cross-cutting concern in one service never forces redeployment of any other** (NFR40).

What is shared:

- **The PostgreSQL database** (one instance, one schema, per-service roles with explicit grants).
- **API contracts** — OpenAPI specs, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) envelope, content-type negotiation. Specification, not runtime code.
- **API spec artefacts (Maven-format, published by Gradle `maven-publish`)** — `uk.gov.hmcts.ctam:api-ctam-{service}:{version}`. Contract, not runtime code.
- **Runtime infrastructure services** (Authorisation, Reference Data, Notification) — by API call (workflows) or direct DB read (simple lookups).
- **Scaffolding templates** (HMCTS Crime SpringBoot template) — at scaffold time, then forked.
- **CI/CD and operational conventions** (Gradle idioms, OpenTelemetry → Application Insights ingestion contract, Liquibase baseline) — by convention and tooling, not library.

Duplicated per service: custom `JWTFilter`; `@ControllerAdvice` ([RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) + retry-safety status mapping); structured-logging config. ~300–500 lines per service × 11 services. The HMCTS starter encodes most of it.

#### Principle 2: No Premature Optimisation

**Performance optimisations are added when measurement justifies them.** At MVP:

- No Reference Data cache — direct SELECT from the Reference Data tables (both tiers).
- No distributed cache (Redis).
- No service mesh (Istio/Linkerd) — Spring Security + AKS DNS + JWTFilter are sufficient.
- No read replicas — one PostgreSQL instance is adequate at this scale.
- No async messaging — REST-first synchronous is the default.

Each is added only when measurement shows a need.

### Primary Technology Domain

API backend: Java + Spring Boot 4 on AKS in Azure UK regions. 11 independently-deployable Spring Boot services, each scaffolded once from the HMCTS starter and owned independently. UI framework is a separate decision (Step 4 Frontend Architecture).

### Starter Options & Selection

| Option | Verdict |
|---|---|
| **HMCTS internal Java/Spring Boot starter** (`hmcts/service-hmcts-crime-springboot-template`) | ✅ **Selected.** Confirmed via review (2026-05-06). Encodes Logstash JSON logging, health checks, OpenTelemetry → App Insights, IdP integration patterns (custom `JWTFilter`), and security defaults. **Helm chart and Spring Cloud Azure Key Vault are not in the template baseline** — CTAM Pathfinder scaffolding script adds them (G1.4a, G1.4b). |
| **Spring Initializr** | Fallback only. Same per-service-fork model; HMCTS-specific patterns added manually. |
| **JHipster** | ❌ Rejected. Heavyweight; bundles identity/frontend/database/Docker conflicting with locked decisions. |
| **Spring Cloud Microservices archetype** | ❌ Rejected. Service discovery / config server / circuit breakers — not needed under REST-first synchronous + Kubernetes. |
| **Custom CTAM Pathfinder Platform Library** | ❌ Rejected on the no-shared-runtime-library principle. |

**Why the HMCTS starter:** scaffold-time inheritance, not runtime dependency. Each service is forked at scaffold time and owns its own copy from then on. Consistent with the foundational principles.

### Initialisation Flow, Build Tool, Dependency Inventory, Per-service Conventions

See [`./architecture/starter-template.md`](./architecture/starter-template.md).

## Core Architectural Decisions

### Decision Priority Analysis

**Critical (block implementation):** Database technology + table-ownership/per-service-role model · Service-to-service authentication mechanism · API versioning · UI framework · API gateway / rate-limiting layer.

**Important (shape architecture):** Migration tooling for schema changes · APEX ⇄ IdP identity-key scheme · Log retention · Historical-data access policy · HA topology (single Azure region multi-AZ in UK South; HMCTS-judicial-region rollout isolation at application tier). DR scope is an open gap — see [`./architecture/gaps.md` G3.6](./architecture/gaps.md).

**Deferred (post-MVP per Principle 2):** Reference Data caching · Distributed cache (Redis) · Service mesh · Read replicas · APIM advanced features.

### Data Architecture

**Database:** PostgreSQL on Azure Database for PostgreSQL Flexible Server, UK regions only. Version 17 (16 acceptable if HMCTS prefers). Reasons: relational domain; mature; lower-cost than Azure SQL; HMCTS open-source preference.

**Topology:** one global instance, one shared schema, per-service DB roles.

- **One PostgreSQL Flexible Server instance** (not per-region, not per-service); sized for the full user population.
- **One logical database**, one shared schema (e.g. `ctam`).
- **Table ownership** encoded by table name (below) + per-service DB roles with explicit grants (below).

**Table naming and ownership (revised 2026-06-11 — ownership is in the prefix):**

- **CTAM-owned tables** — `ctam_` prefix, entity-plural: `ctam_absences`, `ctam_vacancies`, `ctam_bookings`, `ctam_sittings`, `ctam_payments`, `ctam_payment_schedules`, `ctam_regions`, `ctam_offices`, `ctam_calendar_periods`, plus the CTAM-owned vocabulary tables. The prefix makes CTAM ownership visible at a glance against the upstream-sourced tables. No `_overlays` suffix pattern — JOH operational state over upstream entities is named directly (`ctam_joh_ticket`, `ctam_joh_location`).
- **Upstream-sourced tables** — source-system-prefixed: `jo_*` (15 JOH eLinks entities, e.g. `jo_people`, `jo_jurisdictions`, `jo_tickets`) and `mrd_*` (MRD entities). The prefix marks tier-(a) lineage: read-only in CTAM, written exclusively by the ingestion mechanisms (FR6/FR7).
- **Service-internal or ambiguous tables** — service-prefixed: `ctam_payment_reconciliations`, `ctam_notification_dispatches`, `ctam_auth_user_roles`.
- **JOH operational-state tables** — owned by `ctam-joh`, keyed by `joh_id` (uuid → `ctam_joh_identities`, the CTAM-assigned canonical JOH identifier): `ctam_working_patterns`, `ctam_joh_ticket`, `ctam_joh_location`, `ctam_jurisdictional_splits`.
- **Ownership table** in [`./architecture/data-tables.md`](./architecture/data-tables.md).
- **The team that writes the Liquibase changeset creating the table owns it.** The `db/changelog/NNN-*.sql` lives in the owning service's repo.

**ArchUnit fitness functions in CI:**

- No two services' migrations create overlapping tables.
- DB role grants match the documented ownership.
- Each service's role has full privileges on its own tables, and only explicitly-granted privileges on others.

**Cross-service access:**

| Access pattern | Allowed | Mechanism |
|---|---|---|
| Service reads its own tables | ✅ Always | Spring Data JPA |
| Service writes its own tables | ✅ Always | Spring Data JPA |
| Service reads another service's tables | ✅ For SELECT-granted | Direct SQL JOIN; no API roundtrip |
| Service writes a single field on another service's table | ✅ For UPDATE-granted columns | Direct UPDATE in writer's transaction; pessimistic row lock recommended |
| Service performs a workflow on another service's data | ❌ Direct DB; ✅ via API | Owning service's REST endpoint |
| Service writes non-granted columns/tables | ❌ Forbidden | DB rejects |

**Foreign keys within the shared schema** are allowed and encouraged (e.g. `ctam_bookings.joh_id REFERENCES ctam_joh_identities(id)`). Domain tables reference JOHs by `joh_id` (uuid) — the CTAM-assigned canonical JOH identifier[^d9]; `ctam_joh_identities.personnel_number` is the stable link to `jo_people`. The eLinks sync **never hard-deletes** `jo_people` rows (departures are marked inactive), and `ctam_joh_identities` rows are never deleted, so CTAM domain FKs are insulated from upstream churn.

**Per-service DB roles with explicit grants** — `ctam_joh`, `ctam_booking`, etc. (one per service; `ctam_mock_auth` for dev/integration). `ALL` privileges on owned tables. Cross-table access granted explicitly: `GRANT SELECT ON ctam_vacancies TO ctam_booking; GRANT UPDATE (filled, filled_at) ON ctam_vacancies TO ctam_booking;`. Grants live in Liquibase changelogs owned by the table-owning service. **Day 1: grants start broad, tighten as patterns become visible.** Tier-(a) tables (`jo_*`, `mrd_*`) are INSERT/UPDATE-able by `ctam_reference_data` only (the ingestion writer); every other role gets at most SELECT — the DB enforces "read-only in CTAM".

**Forward compatibility:** per-service DB roles are the seam for future schema-per-service or service-extraction without connection-layer code changes.

**Data modelling:** Spring Data JPA + Hibernate. Per-service entities, repositories, and queries. No shared entity classes. Another service's whitelisted tables are `@Immutable` JPA entities in the consuming service.

**Schema evolution: Liquibase** (`liquibase-core` + the Spring Boot Liquibase starter). Per-service `src/main/resources/db/changelog/` with a `db.changelog-master.yaml` master file referencing formatted-SQL changesets (`NNN-name.sql`). Changesets apply on application startup. **Liquibase is for CTAM Pathfinder's DDL only — not for loading upstream data** (see *Upstream reference-data ingestion* below).

**Two-tier reference-data ownership (revised D3 + FR6/FR7, 2026-06-10):**

| Tier | Tables | Written by | Corrections |
|---|---|---|---|
| **(a) Upstream-sourced** | `jo_*` (15 JOH eLinks entities) + `mrd_*` (MRD entities) | The ingestion mechanisms only (`ctam_reference_data` role) — never hand-edited in CTAM | At source: Judicial Office for `jo_*`; the MRD team for `mrd_*`. Picked up by the next sync. **No data flows upstream from CTAM.** |
| **(b) CTAM-owned** | `ctam_regions`, `ctam_offices`, `ctam_calendar_periods`, operational vocabularies, plus JOH operational-state overlays owned by `ctam-joh` | DBAs via direct SQL per operational runbooks in MVP[^d10]; admin UI post-MVP. Never overwritten by upstream sync. | Within CTAM |

`ctam-reference-data` is a **facade over the CTAM-owned datastore** populated by these ingestion paths: consumers use its versioned read API (or direct SQL per Principle 1) without needing to know which upstream source an entry originates from. Separate tables preserve lineage; the API exposes both tiers as appropriate but does not blend them.

**Upstream reference-data ingestion (replaces the retracted Phase 0 ETL):**

- **JOH eLinks sync** — an in-process `@Scheduled` task inside `ctam-reference-data` pulls the JOH eLinks API **nightly** and full-refresh-upserts the 15 `jo_*` tables. Upserts key on the upstream natural key (`personnel_number` for `jo_people`); **for every `jo_people` row the sync also mints, if absent, a `ctam_joh_identities` row — a stable CTAM JOH UUID keyed to `personnel_number` — so CTAM's canonical JOH identifier exists eagerly for every known JOH** (single-writer: `ctam_reference_data`). Rows absent upstream are **marked inactive, never hard-deleted** (protects FKs from domain tables); `ctam_joh_identities` rows are likewise never deleted. Sync runs, outcomes, and row counts are recorded in `ctam_sync_status` (CTAM-internal tracking entity[^d3]). No new service principal and no new deployable: the task writes the service's own tables in-process, sidestepping the G7 service-auth question entirely; the only credential is the outbound JOH eLinks API credential, held in Key Vault.
- **MRD ingestion** — the MRD team's **weekly Excel feed** lands in a dedicated Azure Blob container; a `@Scheduled` task in `ctam-reference-data` polls the container, validates the workbook (shape, vocabulary, referential checks), upserts the `mrd_*` tables, and archives the file (retained for lineage/audit). Idempotent per file. The blob-drop seam swaps cleanly for direct MRD API integration when MRD's public APIs ship — only the reader changes, not the tables.
- **Failure handling** — a failed sync leaves the previous good state in place (each ingestion is transactional per entity set); failures surface via structured logs + `ctam_sync_status` for ops triage. Reference data is at most one cycle stale, never partially written.
- **Jurisdiction hierarchy** — sourced directly from `jo_jurisdictions`[^d8]. The parent-child shape is preserved natively if upstream provides it, or established on ingest. No separate tagging step.
- **User/authorisation data is not ingested** — `auth_*` tables are strictly CTAM-internal[^d9], populated by programme-management / operational mechanisms outside the PRD's scope. Dev/CI environments are seeded by one-off scripts as before.

**Read models:** SQL JOINs across the shared schema. Itinerary and MI Feed run joins across `jo_people` (+ `ctam-joh` overlay tables), `ctam_absences`, `ctam_vacancies`, `ctam_bookings`, `ctam_sittings`, `ctam_payments` (read-only via SELECT grants). Indexed joins meet the ≤ 30 s Forward Look NFR (NFR8).

**Caching:** none at MVP (per Principle 2). Added per-service post-MVP if measurement shows the need.

**Validation:** JSR-380 (Bean Validation 3.0) on request DTOs and entity fields, enforced by Spring Web's `@Valid`.

**Retry safety and concurrency control.** Native PostgreSQL + JPA constructs. No custom `*_idempotency_keys` tables. Three native mechanisms cover the three problems:

| Problem | Mechanism | Failure response |
|---|---|---|
| **Retry of a successful create** ("duplicate create") | Natural-key + unique-constraint dedup at the DB layer. Every domain entity's logical unique key is encoded as a `uq_{table}_{columns}` constraint in Liquibase DDL. A retry's `INSERT` violates the constraint; PostgreSQL raises a unique violation; the `@ControllerAdvice` translates `DataIntegrityViolationException` (unique-violation kind) to `409 Conflict` with [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) `business-rule`. | `409 Conflict` |
| **Two clients editing the same record concurrently** ("lost update") | Optimistic concurrency control via JPA `@Version` (an `integer NOT NULL DEFAULT 0` column on every domain entity that supports update). Update endpoints accept the `If-Match: "v{n}"` header; mismatch → JPA throws `OptimisticLockingFailureException`; `@ControllerAdvice` translates to `412 Precondition Failed`. | `412 Precondition Failed` |
| **Cross-row workflow that must see consistent state on a related record** (e.g. Booking creation that flips the linked vacancy's `filled` flag per R5) | Pessimistic row locking via Spring Data JPA `@Lock(LockModeType.PESSIMISTIC_WRITE)` on the relevant repository method (translates to `SELECT ... FOR UPDATE`). The transaction holds the lock on the related row from read-time through commit. A retry sees the now-updated row and is rejected by the unique-constraint dedup above. | `409 Conflict` (via the unique-constraint path) |

**Per-entity convention:**

- `version integer NOT NULL DEFAULT 0` column → `@Version` on the JPA entity.
- A documented natural-key unique constraint (`uq_{table}_{columns}`) on every table that supports create.
- For workflows that update a related row, the repository method uses `@Lock(LockModeType.PESSIMISTIC_WRITE)`.

**`Idempotency-Key` HTTP header:** not implemented at MVP. Reserved as an escape hatch where the operation has no natural unique key and no related row to lock. Introduced per-endpoint if such a case arises post-MVP.

**Audit trail (separate concern):** the historical "who changed what when" record is the user-action audit on the D7 post-MVP roadmap. Audit answers after-the-fact questions; the three mechanisms above prevent operational duplication. Independent.

### Authoritative Table Ownership Mapping

See [`./architecture/data-tables.md`](./architecture/data-tables.md). The fitness function checks that every Liquibase-created table appears there with the correct owning service.

### Authentication & Security

#### Phasing of Authentication: Mock-First, Real IdP Later

Phases 0–8 use `ctam-mock-auth`. Real HMCTS IdP integration is a pre-Phase-9 deliverable — a configuration cutover.

**`ctam-mock-auth` (Phase 0 deliverable):**

- OIDC `authorization_code` flow for human users (`/oauth2/authorize`, `/oauth2/token`, `/oauth2/jwks`, `/oauth2/userinfo`).
- OAuth `client_credentials` grant for batch service principals (initially `ctam-payment-batch`).
- JWTs for a fixed roster of test users covering all user roles × representative jurisdiction + Region/Area combinations, spanning **both identity populations** (JOH users resolvable against seeded `jo_people` rows; admin-staff users resolvable against seeded `ctam_auth_staff_identities` rows).
- User roster mirrors what the Phase 0 dev/CI scripts seed into CTAM Pathfinder Authorisation.
- Spring Authorization Server. Deployed to AKS dev/integration alongside other Phase 0 services.
- **Production safeguard:** refuses to start with the `production` Spring profile. CI lint blocks production manifests that reference the mock-auth issuer URL.

**Environments:** local dev, CI, unit and integration tests use mock auth. Integration and staging run on mock until the pre-Phase-9 cutover. Production runs on real HMCTS IdP only.

**Why mock-first:** decouples CTAM Pathfinder build from the HMCTS IdP team's roadmap; lets developers work without IdP credentials. Reduces Risk #6 (IdP integration timing) from a Phase 0 blocker to a pre-Phase-9 prerequisite.

**Real HMCTS IdP cutover (pre-Phase-9):**

- **Triggers:** G1.1 (HMCTS IdP supports OIDC for human authN), G1.2 (HMCTS IdP supports `client_credentials` for batch — or an alternative per G7.1), G1.3 (principal export/query API for bootstrap verification).
- **Mechanism:** Spring profile flip. Every service's OIDC `issuer-url` switches from mock auth to HMCTS IdP. No code change.
- **Identity portability:** identity resolution keys on the IdP **email** claim (looked up against `jo_people` for JOHs, `ctam_auth_staff_identities` for admin staff), which is issuer-agnostic — the mock-to-real cutover does not invalidate any identity mapping.
- **Verification:** before staging cutover, a verification job confirms every bootstrapped user (both populations) maps to a real IdP principal.
- **Test suite:** every automated suite (unit, Testcontainers integration, contract) and per-service manual UAT must pass against real IdP in staging before Phase 9 pilot.

#### End-user Authentication

End-user authentication: OIDC. End-user authorisation: CTAM Pathfinder Authorisation service.

Each service runs a custom `JWTFilter` (HMCTS Crime template pattern, `io.jsonwebtoken:jjwt`):

1. Validate JWT signature and issuer against the issuer's JWKS (mock auth in Phase 0–8; HMCTS IdP from pre-Phase-9). Public keys cached per the issuer's cache headers.
2. Extract principal identity (sub, email) from JWT claims.
3. Call `POST /authz/check` against CTAM Pathfinder Authorisation. Authorisation resolves the IdP email to the **canonical CTAM identifier**[^d9] — the **CTAM JOH UUID** via `jo_people` → `personnel_number` → `ctam_joh_identities` for JOH users, or the **CTAM-assigned staff UUID** via `ctam_auth_staff_identities` for HMCTS admin staff — then returns roles + **jurisdiction** + Region/Area scope + activation flag (FR57). Both populations share the same authorisation model; only the identity-lookup path differs. CTAM Pathfinder's authz state lives in Authorisation, not the IdP — this differs from the template's claims-only approach.
4. Store the result in a request-scoped `AuthDetails` bean.

The filter caches authorisation decisions for the request lifecycle only.

#### Inter-service Authentication

Two patterns at MVP:

**Pattern 1 — JWT propagation** (user-initiated cross-service calls):

- The upstream service's outbound HTTP client copies the inbound `Authorization: Bearer <user-jwt>` header onto the outbound call. The downstream service's `JWTFilter` validates the same JWT against the IdP's JWKS and resolves authz via `POST /authz/check`.
- Implementation: per-service Spring Boot 4 `RestClient` interceptor (~10 lines). See [`./architecture/conventions.md`](./architecture/conventions.md) → "JWT propagation".

**Pattern 2 — Service-principal authentication** (batch / scheduled components without an upstream user):

- The case at MVP is `ctam-payment-batch` — runs on a schedule, picks up bookings ready for payment, generates the JFEPS Excel, dispatches via Notification.
- Authenticates via OAuth 2.0 `client_credentials` against the OIDC issuer. `ctam-mock-auth` in Phase 0–8; production issuer per [`./architecture/gaps.md` G7.1](./architecture/gaps.md) (default recommendation: Azure Workload Identity).
- Service token attached as `Authorization: Bearer <service-token>` on outbound calls. The receiving service's `JWTFilter` validates via the same JWKS path as human JWTs.
- Service-principal records live in `ctam_auth_users` (with a `principal_kind` flag); `ctam-authorisation` resolves their permissions the same way. Registrations live in `mock_oauth_clients` at MVP.

**Other non-runtime auth:** Phase 0 dev/CI seeding via one-off scripts (no runtime API call). *(The operator-initiated production ETL and its G4.7 refinement flag are retired with the ETL itself — revised D3, 2026-06-10.)*

**Resolves PRD TBD #3:** JWT propagation for user-initiated calls; service principals (mock-auth in non-prod) for the payment batch; production issuer per G7.1.

#### Identity Resolution (two populations)

**(Reframes the original TBD #7 resolution — the APEX ⇄ IdP ETL matching scheme is retired with the ETL.)** Identity resolution now happens **at sign-in**,[^d9]:

- **JOH users** — the IdP email claim is looked up against `jo_people` to resolve the `personnel_number`, which maps (via `ctam_joh_identities`) to the **CTAM JOH UUID — the canonical, stable CTAM identifier for JOHs**. Email is the lookup key and `personnel_number` the upstream link; neither is the CTAM identifier. The CTAM UUID stays stable even if a `personnel_number` is reissued or upstream data changes.
- **HMCTS admin staff** (RSU, Court users, Tribunal Caseworkers, Finance/Payment Authoriser, MI/Reporting) — not present in JOH eLinks data. The IdP email is looked up against **`ctam_auth_staff_identities`**, a CTAM-internal staff identity table owned by `ctam-authorisation`. Canonical identifier: a **CTAM-assigned UUID** — consistent with the pack's UUID-PK convention and independent of upstream identifier schemes CTAM can't validate at MVP. Populated by programme-management / operational mechanisms outside the PRD's scope.
- **Unresolvable principals** (valid IdP JWT, no match in either lookup) are rejected at the `JWTFilter` boundary with an [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) authorisation problem — same handling as a non-activated user.
- The lookup result is part of the `POST /authz/check` response and cached for the request lifetime only, like every other authz decision.

#### API Security Strategy

- TLS-only on every endpoint; HTTP rejected at the ingress layer.
- Custom `JWTFilter` order: ① TLS / header normalisation ② JWT signature + issuer validation ③ `POST /authz/check` ④ populate `AuthDetails` ⑤ business logic.
- Secret management: Azure Key Vault via Spring Cloud Azure Key Vault (startup-time + actuator `/actuator/refresh`).

**Encryption:** TLS 1.3 minimum (TLS 1.2 fallback acceptable); Azure-managed encryption keys for PostgreSQL by default; CMK only if HMCTS security policy requires.

### API & Communication Patterns

**API style: REST-first synchronous.** No event bus, no message queue, no webhook fabric.

**API versioning: URI prefix major versioning. (Resolves PRD TBD #5.)** `/v1/johs`, `/v2/johs`. Backwards-compatible additions stay within the major version. Deprecation signalling: `Deprecation` header per [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) (date-stamp value, e.g. `Deprecation: @1735689600`) + `Sunset` header per [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594) (RFC-date value); minimum 6-month internal / 12-month external window before removal.

**Build / version metadata** is served by Spring Boot Actuator's `/actuator/info` (populated by `gradle-git-properties`), ops-restricted at the APIM layer. The OpenAPI spec is the consumer-facing contract.

**Rate limiting: Azure API Management at ingress. (Resolves PRD TBD #1.)** 100 req/sec/principal default; 10 req/sec/principal for MI Feed; 200 req/sec burst (sliding 1-second window). The `429 Too Many Requests` status code is per [RFC 6585](https://datatracker.ietf.org/doc/html/rfc6585); the `Retry-After` response header is per [RFC 9110 §10.2.3](https://datatracker.ietf.org/doc/html/rfc9110#section-10.2.3).

**Error handling:** [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details (`application/problem+json`). Per-service `@ControllerAdvice` converts domain exceptions. Standard `type` URIs: `/errors/validation`, `/errors/authorisation`, `/errors/business-rule`, `/errors/dependency`, `/errors/conflict`. Correlation ID echoed in the response.

**API documentation:** Swagger Core. Each service's OpenAPI 3.x spec is published by Gradle (via the `maven-publish` plugin) as a Maven-format artefact (`uk.gov.hmcts.ctam:api-ctam-{service}:{version}`) to the internal artefact repository; consumers pull it at compile time. Postman collections per phase derived from the spec (FR42 / NFR42). The artefact is contract, not runtime code.

**Service-to-service communication:** REST over HTTPS. Service discovery via Kubernetes DNS (`http://ctam-joh.{namespace}.svc.cluster.local:8080`). No service mesh. Synchronous workflows only. Retry safety via native DB primitives — see *Data Architecture*.

### Frontend Architecture

**Two UI repos with the same stack and conventions, separated by audience** (v2.10); **only `ctam-ui` is in MVP scope**[^d10]:

- **`ctam-ui`** — business-user-facing SPA, **MVP**. Per-domain operational modules (JOH, Absence, Vacancy, Booking, Sitting, Payment, Itinerary, Reports). Audience: RSU operational users, Court users, Tribunal Caseworkers, JOHs, Judges' Clerks, Finance/Payment Authoriser, MI consumers — both cohorts' role sets per wave.
- **`ctam-admin-ui`** — admin-facing SPA, **post-MVP**[^d10]. Tier-(b) CTAM-owned Reference Data maintenance (FR6) and User & Role admin (FR4); future surfaces reserved for per-(jurisdiction, region) activation toggle and audit log viewer. In MVP these operations are performed by DBAs via direct SQL per operational runbooks; admin-write API endpoints on `ctam-reference-data` and `ctam-authorisation` are likewise post-MVP — both APIs ship read-only in MVP. *(Tier-(a) upstream-sourced reference data never gets a CTAM write surface in any phase — corrections happen at source per FR6.)*

The split prevents admin workflows from leaking into business users' nav, gives each repo its own CI/CD and CODEOWNERS, and matches the backend's per-service polyrepo discipline (minimise shared code, accept duplication, gain independence). Both repos use the same SSO + Authorisation pattern; admin gating happens at the `ctam-authorisation` layer via role assignment.

**Framework (both):** React 18.x + TypeScript 5.x. (Resolves PRD TBD #2.) Common in HMCTS applications; aligns with `govuk-react`.

**Component library (both):** GOV.UK Design System — required for WCAG 2.2 AA (NFR17). `ctam-admin-ui` uses a distinct accent in its header/nav so the admin surface is visually unambiguous.

**State management (both):** TanStack Query for server state; Zustand or React Context for UI state; React Hook Form for form state (pairs with JSR-380 backend validation via OpenAPI-generated clients).

**Routing (both):** React Router 6.x.

**API client (both):** generated per backend service from the OpenAPI spec (`openapi-typescript-codegen` or `orval`). Generated clients live in each UI repo and are regenerated in its own CI. No shared client library across services or between the two UI repos.

**Build tool (both):** Vite 5.x.

**Styling (both):** GOV.UK Design System CSS (Sass-compiled). Per-component CSS modules for extensions. No Tailwind.

**Testing (both):** Vitest (unit) + React Testing Library (components) + Playwright (E2E) + axe-core (accessibility). `ctam-ui` has one Playwright suite per backend phase; `ctam-admin-ui` (post-MVP) gets one suite per admin module (Reference Data, User & Role).

**Performance (both):** route-based code splitting via `React.lazy` + Suspense. Vite tree-shaking and minification. No PWA at MVP.

**Deployment:** each UI repo is independently deployed to Azure Static Web Apps (or Blob Storage + CDN) on its own hostname. Independent rollout — admin surface can deploy without touching business surface, and vice versa.

### Infrastructure & Deployment

**Infrastructure provisioning: Terraform** (HMCTS standard; decision 2026-06-11 — no Bicep, no portal click-ops). **Product-level *shared* infrastructure lives in its own dedicated repo, `ctam-shared-infrastructure`** (HMCTS Cloud Native Platform `{product}-shared-infrastructure` standard; decision #13, 2026-07-06 — supersedes the earlier "colocated first-consumer" rule). Under this rule: the shared estate (AKS, PostgreSQL Flexible Server, ACR, APIM instance + base policies, Application Insights / Log Analytics, Key Vault) is provisioned and independently verified in `ctam-shared-infrastructure` (Epic 0.0), ahead of any service; each service repo carries Terraform for its own Key Vault namespace and service-specific resources (e.g. the MRD blob storage in `ctam-reference-data`; the Static Web App in `ctam-ui`). Per-environment stacks (`dev` / `staging` / `production`); `ctam-scaffold.sh` adds the per-service `terraform/` skeleton. Division of labour: **Terraform provisions the estate; Helm deploys workloads onto it; Liquibase owns DB schema** — no overlap. State backend + plan/apply pipeline arrangement: [`./architecture/gaps.md` G9](./architecture/gaps.md).

**Hosting:** Azure Kubernetes Service (AKS), single cluster in UK South, multi-AZ node pools. Pod anti-affinity (`topology.kubernetes.io/zone`) distributes replicas across AZs. Min 2 replicas/service; HPA tunes upward. Rollout isolation (jurisdiction-first, then per-region) is enforced at the app tier via per-(jurisdiction, region) activation flags (FR57), not infrastructure. DR is an open gap — see [`./architecture/gaps.md` G3.6](./architecture/gaps.md).

**Database hosting:** Azure Database for PostgreSQL Flexible Server. One global instance, zone-redundant HA in UK South — primary in one AZ, standby in another, synchronous replication, automatic failover (<60 s). Microsoft-managed continuous backup; PITR; encryption at rest. Geo-redundant backup is part of the DR decision (G3.6).

**UI hosting:** Azure Static Web Apps (or Blob Storage + CDN if Static Web Apps is operationally complex for HMCTS).

**Secret management:** Azure Key Vault, one namespace per service. Secrets mounted at startup via Spring Cloud Azure Key Vault.

**CI/CD:** per-service Azure DevOps Pipelines or GitHub Actions (HMCTS standard). Each service has its own pipeline. Pipelines push Docker images to ACR, then deploy via Helm to AKS.

**Environment configuration:** Spring profiles (`dev`, `staging`, `production`); secrets in Key Vault. App Configuration only if runtime tuning without redeployment becomes a need.

**Observability** (log-based MVP[^d7], HMCTS Crime template):

- Logback with Logstash JSON encoder; async appender.
- OpenTelemetry exports to Application Insights via OTel Collector.
- Log fields: `timestamp`, `level`, `service`, `correlation-id`, `principal-id`, `event-type`, `message`, `error-category`, `error-code`.
- Spring Boot Actuator: `/actuator/health`, `/actuator/info` (from `gradle-git-properties`), `/actuator/readiness`. The `/actuator/*` namespace is ops-restricted at the APIM layer. `/actuator/metrics` and Prometheus endpoint are not exposed at MVP[^d7].
- OTel trace sampling: 100% in dev/staging; tunable in production.

**Log retention:** 30 days hot in App Insights; 90 days cold in Log Analytics archive. (Resolves PRD TBD #4.) Pre-GA review against HMCTS retention policy may extend it.

**Historical-data access:** historical data stays in the cohort's incumbent system and is accessed there as needed (revised D3 — no migration of any kind). For Courts waves (3+): read-only APEX bridge for 12 months after each region's cutover, then a one-shot extract; APEX retires fully when every region has passed its window (resolves PRD TBD #6, partial; the 12-month length is pending programme confirmation). **For ET wave 1: the historical-access arrangement cannot be scoped until the incumbent is identified (G8.4)** — settle in the ET-cohort readiness assessment[^d13]. For SSCS wave 2: ListAssist (the SSCS scheduling tool) is replaced — the historical-access window for ListAssist scheduling data is programme-managed and should be settled as part of the SSCS-cohort readiness assessment. (GAPS, the SSCS case-management system, is retained, not decommissioned.)

**Scaling:** Kubernetes HPA per service. CPU/memory triggers; min 2 replicas; max replicas tuned per service after capacity stabilises.

### Deployment topology — single Azure region, multi-AZ HA

Production runs in UK South across three availability zones. DR is an open gap — see [`./architecture/gaps.md` G3.6](./architecture/gaps.md).

"Region" has two meanings in this document and the PRD:

| Concept | Meaning | Enforced by |
|---|---|---|
| **Azure region** | Geographic Azure deployment region. Each contains multiple availability zones (AZs) — physically separate datacentres on independent power/network. | Infrastructure: production = UK South. HA via multi-AZ within UK South. DR target region is held in G3.6. |
| **HMCTS judicial region** | The per-region boundary *within* a jurisdiction. Per D8 (reframed 2026-06-10), the rollout boundary is **jurisdiction first, then per-region within jurisdiction** — wave 1 is the whole **Employment Tribunals** jurisdiction[^d13]; wave 2 is the whole SSCS jurisdiction; waves 3+ are Courts jurisdictions with per-region granularity (Northern, Western, etc.). | Application tier: per-user activation flag in `ctam_auth_user_activation_flags` carrying the (jurisdiction, region) tuple (FR57). No infrastructure isolation per jurisdiction or HMCTS region. |

NFR38 ("region-isolated deployments") means the rollout-boundary sense — a wave in one (jurisdiction, region) does not disrupt another's users. Enforced at the application tier, not by separate clusters or DNS endpoints.

#### HA topology — multi-AZ within UK South

| Component | Multi-AZ setup |
|---|---|
| **AKS** | One production cluster; node pools span all three AZs. Pod anti-affinity (`topology.kubernetes.io/zone`); min 2 replicas/service. AKS control plane is Microsoft-managed and zone-redundant. |
| **PostgreSQL Flexible Server** | Zone-redundant HA — primary + standby in different AZs, synchronous replication, automatic failover (<60 s). One instance is not a single-AZ point of failure within UK South. (G6.2 for full-region-loss residual risk; G3.6 for DR.) |
| **Azure Key Vault** | Microsoft-managed zone-redundancy in UK South (Premium tier; verify Standard). One Key Vault per service (or per service-environment). |
| **Application Insights / Log Analytics** | Microsoft-managed regional service; AZ-level redundancy is Microsoft's responsibility. One workspace shared across CTAM Pathfinder services. |
| **Azure API Management** | Premium SKU with zone-redundancy enabled. |
| **Azure Static Web Apps (UI)** | Microsoft-managed regional service; CDN-fronted globally. |
| **Azure Container Registry** | Zone-redundant (Premium SKU). |
| **Azure Front Door / DNS** | Single DNS endpoint (e.g. `ctam.production.hmcts.gov.uk`) routes to UK South ingress. Not per-HMCTS-region. |

Single-AZ failure within UK South is tolerated transparently: AKS reschedules pods; PostgreSQL fails over to the standby AZ. Full UK South region loss is the residual risk at MVP — see G6.2 and G3.6.

#### Jurisdiction/region rollout isolation — application tier only

| Concern | Mechanism |
|---|---|
| Migrated-wave users authenticate; non-migrated users do not | `ctam_auth_user_activation_flags` keyed by (jurisdiction, region) (FR57); `JWTFilter` rejects non-activated users. Cutover flip: `UPDATE ctam_auth_user_activation_flags SET activated = TRUE WHERE jurisdiction = '…' AND region = '…'` per the rollout runbook. |
| One wave's deployment doesn't disrupt another | Rolling deployments per-service across the cluster; the activation flag contains the change |
| Cross-region workflow during partial rollout | Per-wave decision (Risk #1); some workflows operate mixed-mode, some are gated, some are manual |

**Consequences:** no per-HMCTS-region AKS clusters, DNS, or Key Vaults. Per-service Helm values are per-environment (`values-dev.yaml`, `values-staging.yaml`, `values-production.yaml`).

### Decision Impact Analysis

**Implementation Sequence:**

1. **Phase 0 prerequisites** — Azure subscription + UK regions; the shared Azure estate **Terraform-provisioned in `ctam-shared-infrastructure`** (AKS, shared global PostgreSQL Flexible Server with single shared schema + per-service DB roles, ACR, APIM, App Insights, Key Vault — provisioned and independently verified in **Epic 0.0** per decision #13 / SCP 2026-07-06, ahead of any service; supersedes the earlier colocated first-consumer rule); HMCTS Crime SpringBoot template forked into CTAM Pathfinder scaffolding script (incl. per-repo `terraform/` skeleton). *(HMCTS IdP feature confirmation deferred to pre-Phase-9; see point 8.)*
2. **Phase 0 mock authentication** — `ctam-mock-auth` deployed as Spring Authorization Server-based service. Issues OIDC tokens for human user roster; **issues service tokens via `client_credentials` for `ctam-payment-batch`**.
3. **Phase 0 services** — built per HMCTS starter pattern, each with own DB role + table set, OpenAPI spec, Postman collection, Helm chart, in this order (integrations-first carve-out, decision #12 / SCP 2026-06-17): **(a) `ctam-reference-data` first** — scaffold + the two ingestion mechanisms: the in-process scheduled JOH eLinks sync (nightly, `jo_*` tables + `ctam_sync_status`) and the MRD blob-drop pick-up (weekly, `mrd_*` tables); this is the programme's first deliverable and first external integration. **(b) `ctam-authorisation`** — consumes the shared estate (no longer provisions it). **(c) the Reference Data read API** — depends on (b) for `JWTFilter` + jurisdiction resolution. **(d) `ctam-notification`**. *(A shared `ctam_configuration_values` table is created by the `ctam-architecture` Liquibase baseline changelog ahead of `ctam-reference-data`; SELECT-granted to every CTAM Pathfinder service role.)*
4. **Dev/CI environments seeded by one-off scripts** — representative `jo_*`/`mrd_*` fixtures + tier-(b) reference data + a representative user roster spanning both identity populations. *(Production reference data arrives via the ingestion mechanisms; production user/authorisation records are bootstrapped by mechanisms outside the PRD's scope[^d9] — the Phase 0 Data Migration ETL is retracted.)*
5. **Phase 0 API gateway** — Azure API Management with default rate-limit policies (TBD #1 resolution).
6. **Phase 0 UI shell** — one Vite + React + GOV.UK Design System scaffold deployed to Azure Static Web Apps: `ctam-ui` (business), carrying the role-scoped Home shell. *(`ctam-admin-ui` is post-MVP[^d10]; MVP admin operations are DBA-via-SQL per runbook.)*
7. **Phases 1–8** — domain services per the brainstorming sequence (JOH → Absence → Vacancy → Booking → Sitting → Payment → Itinerary → MI Feed); each adds its own tables, OpenAPI spec, Postman collection, and a `ctam-ui` module. **No legacy-data migration in any phase** — revised D3: reference data is ingested from JOH eLinks + MRD; historical data stays in the incumbents.
8. **Pre-Phase-9 — Real HMCTS IdP integration cutover** — confirm G1.1, G1.2 (client_credentials for batch — re-opened v2.6), G1.3. Switch staging `issuer-url` from mock auth to HMCTS IdP via Spring profile. Run the bootstrap-verification pass (every user in both populations maps to a real IdP principal). Re-execute full automated test suite + per-service manual UAT scripts before opening wave 1. **The ET-cohort readiness assessment[^d13] must be signed off — and G8.4 (ET incumbent) closed — before the wave-1 cutover plan is finalised.**
9. **Phase 9+** — jurisdiction-first rollout waves on production with real HMCTS IdP[^d13]: wave 1 = **Employment Tribunals** (incumbent `[ET-INCUMBENT-TBD]`, G8.4); wave 2 = SSCS (replacing ListAssist; GAPS case management retained); waves 3+ = Courts jurisdictions per-region (replacing APEX/JI). App Insights retention and the incumbent historical-access arrangement activated per wave.

**Cross-Component Dependencies:**

- **Authorisation service** — every `JWTFilter` calls it. Outage → outage of CTAM Pathfinder. Mitigations: min 3 replicas; per-request-lifetime caching; circuit-breaker fail-closed (deny).
- **Reference Data tables** — read directly via SQL JOINs by every service; no caching at MVP. A Reference Data *service* outage (the API + the ingestion tasks) blocks API reads and pauses upstream sync only; direct-SQL reads are served from the tables, which retain the last good sync state. Mitigation: PostgreSQL HA.
- **JOH eLinks API** — upstream dependency for reference-data freshness, not availability: an eLinks outage means data is at most one sync cycle stale; CTAM keeps serving from its own tables. The identity lookup (`jo_people`) reads CTAM's tables, not the live API, so sign-in does not depend on eLinks uptime.
- **HMCTS IdP** — every authentication depends on it. IdP outage is HMCTS-wide.
- **Azure API Management** — all external client requests flow through it. Mitigation: Premium SKU with zone-redundancy.
- **PostgreSQL (one shared global instance)** — outage affects every service. Single-AZ failure tolerated by zone-redundant HA. Single-DB blast radius and full-region-loss residual risk: G6.2 and G3.6 in [`./architecture/gaps.md`](./architecture/gaps.md).

### TBDs Resolved by This Step

| # | TBD | Resolution |
|---|---|---|
| 1 | Rate limit policy | Azure API Management at ingress; 100 req/sec/principal default; 10 req/sec/principal for MI Feed; 200 req/sec burst |
| 2 | UI framework family | React + TypeScript + GOV.UK Design System + Vite |
| 3 | Service-to-service auth | **Two patterns at MVP**: JWT propagation (forward inbound user JWT) for user-initiated calls; OAuth `client_credentials` (via `ctam-mock-auth` in non-prod; production issuer per G7.1) for the payment-processing batch service principal |
| 4 | Log retention | 30 days hot in App Insights; 90 days cold in Log Analytics archive |
| 5 | API versioning | URI prefix major versioning (`/v1/`); 6-month internal / 12-month external deprecation; `Deprecation` header per [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745); `Sunset` header per [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594) |
| 6 | Historical-data access | Historical data stays in the incumbent[^d3]. Courts waves (3+): read-only APEX bridge for 12 months post-region-cutover; one-shot extract thereafter. **ET wave 1: unscopeable until G8.4 names the incumbent**[^d13]; settle in the ET-cohort readiness assessment. SSCS wave 2: ListAssist scheduling-data historical-access window settled in the SSCS-cohort readiness assessment (GAPS case management retained). |
| 7 | Identity-key scheme *(reframed 2026-06-11; revised 2026-07-09)* | Runtime identity resolution at sign-in: IdP email → `jo_people` → `personnel_number` → **CTAM JOH UUID (`ctam_joh_identities`)** for JOHs; IdP email → `ctam_auth_staff_identities` → CTAM-assigned UUID for admin staff. Both populations key on a CTAM-assigned UUID; `personnel_number` is the upstream link only. The APEX ⇄ IdP ETL matching scheme is retired with the ETL. |

## Implementation Patterns & Consistency Rules

See [`./architecture/conventions.md`](./architecture/conventions.md). Patterns are enforced by code review, CI lint, contract tests, and ArchUnit fitness functions — not by a shared library.

## Project Structure & Boundaries

### Repository Strategy & List

See [`./architecture/repository-strategy.md`](./architecture/repository-strategy.md).

### Complete Project Directory Structures (per-service / UI / ctam-architecture)

See [`./architecture/repo-structure.md`](./architecture/repo-structure.md).

### Architectural Boundaries

**API:** every service is exposed at `https://api.ctam.{environment}.hmcts.gov.uk/{service-name}/v1/...` via APIM. Within AKS, services call each other via Kubernetes DNS. External traffic is TLS-only via APIM. No service is reachable directly from outside the cluster.

**Service:** one Spring Boot app per service; one container image; one Helm chart. One shared PostgreSQL Flexible Server with one shared schema. One Azure Key Vault namespace per service. One Application Insights workspace shared by all services (correlation IDs join logs).

**Data:**

- A service owns its tables and is the only writer (except for cross-service single-field updates per Principle 1).
- Cross-service reads: SQL JOINs on whitelisted tables.
- Cross-service writes: direct SQL on whitelisted columns (explicit `UPDATE` grants).
- FKs within the shared schema are encouraged. Domain tables reference JOHs by `joh_id` (uuid) → `ctam_joh_identities`; `personnel_number` is the upstream link to `jo_people`.
- Reference Data is single-owner, two-tier (FR6/FR7): tier-(a) `jo_*`/`mrd_*` tables written only by the ingestion mechanisms; tier-(b) CTAM-owned tables maintained in CTAM. Other services read both directly via SQL.
- Forbidden data: no bank-detail or case-level columns anywhere. Case management, panel composition, and hearing types are external-system concerns[^d12] — no tables for them in CTAM.
- No legacy transactional history anywhere in CTAM[^d3]; historical data stays in the cohort's incumbent. CTAM Pathfinder domain tables are empty at wave cutover.

**UI Boundaries:** **two SPAs** (v2.10) — `ctam-ui` (business, **MVP**) and `ctam-admin-ui` (admin, **post-MVP[^d10]**). Each SPA contains multiple modules; each module imports its generated API client; cross-module communication via TanStack Query cache + React Context. No code-sharing between the two SPAs — same stack and conventions, but independent repos, pipelines, and deployments. Admin workflows (tier-(b) Reference Data maintenance per FR6, User & Role admin per FR4) live exclusively in `ctam-admin-ui` and never appear in `ctam-ui`'s nav; in MVP those operations are DBA-via-SQL per runbook.

**External Systems:** HMCTS IdP (every authentication); JOH eLinks API (inbound reference-data pull, scheduled); MRD (inbound weekly Excel via blob drop); JFEPS/Liberata (outbound only via Notification → email — verified for SSCS, now wave 2; **ET wave-1 applicability unverified, G8.6**); HMCTS Email (outbound only); incumbents during build (manual UAT only — `[ET-INCUMBENT-TBD]` for wave 1, ListAssist for wave 2, APEX for waves 3+); APEX during Courts rollout (read-only for migrated users for 12 months, served separately); external case-management systems (outbound — they consume CTAM's APIs from Phase 9, never write in,[^d12]; ET: system TBC per G8.5; SSCS: **GAPS** — retained case management; Courts: Listing systems); DA&I (inbound only, post-MVP).

### Requirements to Structure Mapping

| Capability area (FR group) | Lives in |
|---|---|
| Identity & Authorisation (FR1–FR5) | `ctam-authorisation` repo (incl. `ctam_auth_staff_identities` + the `jo_people` identity lookup) + per-service `config/JWTFilter.java`, `config/AuthDetails.java`, `client/AuthorisationClient.java`. **FR4 (User & Role admin)** surface is post-MVP `ctam-admin-ui`[^d10]; DBA-via-SQL per runbook in MVP. |
| Foundational Data Management (FR6–FR9) | `ctam-reference-data` (incl. the JOH eLinks sync + MRD ingestion tasks and the two-tier table set), `ctam-notification` repos + per-service direct JPA reads from the Reference Data tables. **FR6 tier-(b) maintenance** surface is post-MVP `ctam-admin-ui`[^d10]; DBA-via-SQL per runbook in MVP. Tier (a) has no CTAM write surface in any phase. **Configuration**: per-service Spring profiles + Key Vault; shared `ctam_configuration_values` table (no API) for cross-service policy values, schema-managed by `ctam-architecture` Liquibase baseline changelog. |
| JOH Records & Working Patterns (FR10–FR18) | `ctam-joh` repo (JOH operational-state overlays keyed by `joh_id` → `ctam_joh_identities`); profile *views* compose tier-(a) `jo_*` data with the overlays via `ctam-reference-data`'s read API (FR11, FR15) |
| Absence Workflow (FR19–FR22) | `ctam-absence` repo |
| Vacancy & Cover (FR23–FR28) | `ctam-vacancy` repo. Booking marks the linked vacancy as filled within Booking's transaction (per Principle 1; see *Data Architecture*). |
| Booking Management (FR29–FR34) | `ctam-booking` repo |
| Sitting Management (FR35–FR40) | `ctam-sitting` repo |
| Payment & Reconciliation (FR41–FR47) | `ctam-payment` repo (batch component + reconciliation API) |
| Itineraries & Reporting (FR48–FR54) | `ctam-itinerary` and `ctam-mi-feed` repos |
| Platform Operations (FR55–FR60) | Cross-cutting: per-service implementations + `ctam-architecture` scaffolding script |

### Cross-Cutting Concerns to File Locations

| Concern | Per-service file location |
|---|---|
| Custom `JWTFilter` + `AuthDetails` request-scoped bean (FR2) | `src/main/java/.../config/JWTFilter.java` + `config/AuthDetails.java` |
| Authorisation client called by `JWTFilter` (FR2 — CTAM Pathfinder variance from template) | `src/main/java/.../client/AuthorisationClient.java` |
| Reference Data direct SQL access (FR7) | JPA repositories pointing at whitelisted Reference Data tables |
| Jurisdiction + Region/Area scoping middleware | `src/main/java/.../config/RegionScopeFilter.java` (scopes by jurisdiction and Region/Area from the authz context) |
| Per-(jurisdiction, region) phased activation check (FR57) | Resolved in `JWTFilter` via authz path |
| Retry safety (FR45, FR30) | Native DB primitives — see *Data Architecture* and [`./architecture/data-tables.md`](./architecture/data-tables.md). No filter, custom table, or client class. |
| [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details error handling (FR58) | `src/main/java/.../error/GlobalExceptionHandler.java` |
| OpenAPI 3.x generation (FR58) | `src/main/java/.../config/OpenApiConfig.java` (Swagger Core); spec published by Gradle (`maven-publish`) as a Maven-format artefact (`uk.gov.hmcts.ctam:api-ctam-{service}`) |
| Structured logging (FR59) | `src/main/resources/logback-spring.xml` + `config/CorrelationIdFilter.java` |
| Manual UAT scripts (FR60 / NFR41 revised) | `docs/uat/` per service (domain services only); not in `src/test/` |
| Upstream ingestion (FR6/FR7, NFR24 — `ctam-reference-data` only) | `src/main/java/.../ingestion/JohElinksSyncTask.java` + `ingestion/MrdExcelIngestionTask.java` (`@Scheduled`); sync state in `ctam_sync_status` |
| Forbidden-data invariants (FR47, FR54) | DB schema (no relevant columns) + DTO validation in `dto/` |

### Integration Points — Internal Communication

```
      ┌──────────────────────┐    ┌────────────────────────┐
      │   ctam-ui (business)  │    │ ctam-admin-ui (admin)   │
      │        [MVP]         │    │      [post-MVP, D10]   │
      └──────────┬───────────┘    └────────────┬───────────┘
                 │                              │
                 └──────────┬───────────────────┘
                        │ HTTPS
              ┌─────────▼─────────┐
              │ Azure API         │
              │ Management        │   ←─── rate limits applied here
              └─────────┬─────────┘
                        │
   ┌────────────────────┼────────────────────┐
   ▼                    ▼                    ▼
┌─────────┐        ┌─────────┐         ┌──────────┐
│ Domain  │        │ Domain  │   ...   │ Read-    │
│ services│        │ services│         │ models   │
└─────┬───┘        └─────┬───┘         └────┬─────┘
      │ HTTPS within AKS (Kubernetes DNS, JWT propagation or service-token)
      ▼                  ▼                  ▼
┌──────────────────────────────────────────────┐
│  Authorisation (gates every call; two-       │
│    population identity lookup)               │
│  Reference Data (read direct from tables;    │
│    ingests JOH eLinks + MRD upstream)        │
│  ctam_configuration_values (shared infra table)   │
│  Notification (write-only, email send)       │
└──────────────────────────────────────────────┘
```

**Synchronous call patterns by frequency:**

- Every service → Authorisation API (per-request, request-lifetime cache).
- Every service → Reference Data tables (direct SQL; no caching at MVP).
- Booking → in-transaction direct DB update on the linked vacancy (no API roundtrip per Principle 1).
- Itinerary read-model → SQL JOIN across domain tables in the shared schema (single indexed query).
- MI Feed read-model → SQL JOIN across CTAM Pathfinder domain tables (single aggregate query).

### Integration Points — External

| External system | Direction | CTAM Pathfinder service interacting | Pattern |
|---|---|---|---|
| HMCTS IdP | inbound (human authN) | Every service's `JWTFilter` validates user JWTs via JWKS; **Authorisation** maps to CTAM Pathfinder roles | OIDC `authorization_code` for human users; JWT signature validation via JWKS (`io.jsonwebtoken:jjwt`); cross-service calls forward the user's JWT (Pattern 1). **Pre-Phase-9 dependency only** — mock auth covers Phase 0–8; cutover is a Spring profile change. |
| HMCTS IdP / Azure Workload Identity (production issuer per G7.1) | inbound (service-principal authN for batch) | `JWTFilter` validates batch service tokens via the same JWKS path | OAuth 2.0 `client_credentials` for `ctam-payment-batch`; **non-prod via `ctam-mock-auth` (mock_oauth_clients)**. (Pattern 2.) |
| JOH eLinks API | inbound (reference data — MVP per NFR24) | Reference Data (in-process scheduled sync) | Nightly REST pull; full-refresh upsert into the 15 `jo_*` tables; soft-deactivation, never hard-delete; sync state in `ctam_sync_status`. Outbound credential in Key Vault. **No data flows upstream from CTAM.** |
| MRD (Master Reference Data) | inbound (reference data — MVP per NFR24) | Reference Data (scheduled blob pick-up) | Weekly Excel feed dropped into a dedicated Azure Blob container; validated, upserted into `mrd_*` tables, file archived for lineage. Transitional until MRD public APIs ship — then the reader swaps for an API client. |
| JFEPS / Liberata | outbound | Payment + Notification | JFEPS-Excel via email to Payment Authoriser; manual upload by authoriser. Verified for SSCS[^d11] (now wave 2); **ET wave-1 applicability unverified — G8.6**[^d13]. |
| HMCTS email | outbound | Notification | SMTP / Microsoft Graph (HMCTS standard) |
| Azure Application Insights | outbound (logs + traces) | All services | OpenTelemetry → OTel Collector → App Insights as export target |
| Azure Key Vault | inbound (secrets) | All services | Spring Cloud Azure Key Vault at startup |
| Scheduling incumbents — `[ET-INCUMBENT-TBD]` / ListAssist / APEX (manual UAT only) | n/a | UAT users from domain services' user roles | Jurisdiction-incumbent-experienced users compare side-by-side per FR60 / NFR41 (`[ET-INCUMBENT-TBD]` for wave 1 — G8.4; ListAssist for wave 2; APEX for waves 3+)[^d13]. No HTTP scraping, DB read, or CI hook. |
| APEX (during Courts rollout window) | inbound (read-only for migrated users) | None — APEX served separately | Out-of-band; not a CTAM Pathfinder integration |
| External case-management systems (ET case management — TBC per G8.5; SSCS: GAPS; Courts Listing) | outbound (from Phase 9,[^d12]) | Domain services' / read models' public APIs | They consume CTAM's JOH availability + booking APIs; **no external system writes into CTAM**. Contract design lands with wave onboarding. |
| DA&I | inbound (post-MVP) | MI Feed | REST API calls; service-token authenticated |

### Data Flow — Canonical Operational Cycle (Journey 2 from PRD — Courts, waves 3+)

*(Journeys were renumbered 2026-06-10; wave positions retargeted 2026-08-07[^d13]: the canonical RSU cycle below is now Journey 2 (Courts, waves 3+). Journey 1 is the **ET cover-coverage journey for wave 1** — same service chain, absence → vacancy → booking → sitting → payment, with ET roles; **its detail is provisional pending the ET as-is pack, G8.5**. The SSCS Tribunal Caseworker panel-coverage journey exercises the same chain for wave 2. The flow below remains the canonical reference.)*

All services share one PostgreSQL DB (one schema). Each service writes its own tables; cross-service simple writes use DB role grants (Principle 1). Workflows go via API.

The cycle has two halves — user-initiated (Court User and RSU) and batch/external (payment batch + Liberata). Each has its own sequence diagram.

**User-initiated half** — see [`./architecture/sequence-diagrams/absence-to-reconciliation.md`](./architecture/sequence-diagrams/absence-to-reconciliation.md)

1. **Court User** logs an absence with cover requested — `POST /v1/absences` (FR19); ack email to the JOH.
2. **RSU** approves the absence — `POST /v1/absences/{id}/approve` (FR21). Approval triggers vacancy auto-creation per **R4** — `POST /v1/vacancies` (FR23).
3. **RSU** records a fee-paid booking against the vacancy — `POST /v1/bookings` (FR29). The booking creation and the in-transaction mark-as-filled on the linked vacancy are atomic, per **R5** (FR30); ack email (FR32). Persistence detail: see *Data Architecture*.
4. **Court User** confirms the sitting after the day — `POST /v1/bookings/{id}/confirm` (FR31, FR37). Booking is now confirmed and **eligible for payment** (no synchronous payment trigger — the batch picks it up).
5. **RSU** reconciles after Liberata has paid — `POST /v1/payments/{id}/reconcile` (FR46); manual at MVP, automated reconciliation feed is post-MVP.

**Batch / external half** — see [`./architecture/sequence-diagrams/payment-batch-flow.md`](./architecture/sequence-diagrams/payment-batch-flow.md)

1. **Scheduler** (Kubernetes CronJob or Spring `@Scheduled`) triggers `ctam-payment-batch` on its configured cadence.
2. The batch authenticates as a service principal via OAuth `client_credentials` against `ctam-mock-auth` (non-prod; production issuer per [`./architecture/gaps.md` G7.1](./architecture/gaps.md)).
3. The batch SQL-JOINs over confirmed bookings + sittings without an existing payment record, generates the JFEPS Excel, and persists `ctam_payments` + `ctam_payment_schedules` (FR41–FR45). Bookings flagged `payment_requested`.
4. The batch calls Notification (with bearer service token) to dispatch the schedule to the configured Payment Authoriser (FR43).
5. The **Payment Authoriser** uploads the schedule to JFEPS / Liberata (out-of-band).
6. **Liberata** processes the payment and pays the JOH.

### File Organisation, Development Workflow, Deployment Pipeline

See [`./architecture/repo-structure.md`](./architecture/repo-structure.md).

### Wave rollout flow (Phase 9+, jurisdiction-first)

Per-wave production cutover[^d8][^d13] — wave 1 = the **Employment Tribunals** jurisdiction; wave 2 = the SSCS jurisdiction; waves 3+ = Courts jurisdictions per-region — is gated on:

1. All automated FR/NFR tests (unit, integration, contract, E2E) passing for the in-scope user roles.
2. **Manual UAT signed off** — jurisdiction-incumbent-experienced users for every applicable in-wave role have walked the per-service UAT scripts (FR60 / NFR41 revised): `[ET-INCUMBENT-TBD]`-experienced users (ET role set *provisional*, G8.5) for wave 1; ListAssist-experienced users (RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI) for wave 2; APEX-experienced users (RSU, Court, Judge, Clerks, Finance, MI) for waves 3+.
3. Data readiness verified for the wave: reference data current per `ctam_sync_status` + MRD feed; user/authorisation records bootstrapped and verified against IdP principals for the wave's (jurisdiction, region) scope.
4. **For wave 1 only:** the ET-cohort readiness assessment[^d13] signed off, the ET as-is analysis pack complete (G8.5), and G8.4 closed (incumbent named).
5. Programme sign-off (operational readiness, communication to migrating users).

Rollback path: revert the wave's activation flags (FR57, keyed by jurisdiction + region) → users return to the incumbent (`[ET-INCUMBENT-TBD]` for wave 1 — **rollback target undefined until G8.4 closes**; ListAssist for wave 2; APEX for waves 3+).

## Architecture Validation Results

### Coherence Validation ✅

**Decision compatibility:**

- **Stack** (Java 25 + Spring Boot 4.1.0 + Gradle Groovy DSL + PostgreSQL 17 + Liquibase + AKS + Azure UK + OpenTelemetry → App Insights + Key Vault + APIM, per HMCTS Crime template) — current GA, mutually compatible, Azure-native or first-party on Azure.
- **Foundational principles** (API for workflows + shared DB for simple data access; no premature optimisation; no shared runtime library) — consistent with polyrepo, per-service Spring Boot, per-service Helm, one PostgreSQL with per-service roles, per-service OpenAPI specs as Maven-format artefacts (published by Gradle), and per-service boilerplate.
- **REST-first synchronous + SQL read-model federation** — workflows go via API; read models query the shared DB directly. No event bus.
- **Mock-first authentication + OIDC for humans + two inter-service patterns (JWT propagation, service-principal `client_credentials` for batch)** — issuer-agnostic OIDC contract; mock-to-real cutover is a configuration change.
- **GOV.UK Design System + WCAG 2.2 AA + axe-core** — GDS components are built to WCAG 2.2 AA.

**Pattern consistency:** Step 5 patterns match Step 4 decisions — DB naming (`snake_case`, plural tables, `uuid` PKs); API naming (`camelCase` JSON, plural resources, `/v1/`, RFC 9457 problem-details, ISO 8601); Java package layout (`uk.gov.hmcts.ctam.{service}.{layer}`); communication (typed clients, correlation-ID propagation, native DB retry safety).

**Structure alignment:** per-service repos enable phased rollout and independent deployment; per-environment Helm values + zone-redundant AKS provide HA for NFR34/NFR35/NFR37; NFR38 is satisfied at the app tier via FR57 activation flags; Postman collections per phase satisfy NFR42; `ctam-architecture` holds ADRs and scaffolding without runtime coupling; `ctam-mock-auth` is isolated so production never references it.

No contradictions found.

### Requirements Coverage Validation ✅

- **Functional Requirements Coverage (FR1–FR60)** — see [`./architecture/functional-requirements-coverage.md`](./architecture/functional-requirements-coverage.md).
- **Non-Functional Requirements Coverage (NFR1–NFR42)** — see [`./architecture/non-functional-requirements-coverage.md`](./architecture/non-functional-requirements-coverage.md).

All 60 FRs and 42 NFRs have explicit architectural support.

### Implementation Readiness Validation ✅

All 7 architecture-phase TBDs from the PRD are resolved (see *TBDs Resolved by This Step*).

**Structure:** 15 repos with per-repo trees; per-service standard layout to file level; two UI repos (`ctam-ui` business, MVP + `ctam-admin-ui` admin, post-MVP[^d10]) with per-module structure; architecture repo with ADRs/scaffolding/aggregated specs; isolated mock-auth repo; integration points mapped; requirements-to-structure mapping covers all 9 FR capability areas.

**Patterns:** naming, structure, format, communication, and process conventions defined with examples. Enforcement: CI lint, ArchUnit, Spectral, Pact, code review checklist.

### Documented Gaps

See [`./architecture/gaps.md`](./architecture/gaps.md). Critical gaps: none — no gap blocks implementation.

### Assumptions

See [`./architecture/assumptions.md`](./architecture/assumptions.md).

### Architecture Readiness Assessment

**Status: READY WITH DOCUMENTED GAPS. Confidence: High.**

*(Scope note: this assessment covers the build architecture (Phases 0–8). The **wave-1 cutover** additionally requires the **ET-cohort readiness assessment**[^d13] — covering JOH eLinks API integration readiness (including `jo_jurisdictions` coverage of ET, G8.1), MRD feed ingestion readiness, the two-population identity model, jurisdiction-aware authorisation, and `[ET-INCUMBENT-TBD]`-experienced UAT panel coverage (blocked on G8.4) — plus the **ET as-is analysis pack** (G8.5) under `docs/architecture/asis/`. The SSCS-cohort assessment and SSCS as-is pack become wave-2 gates. Prior readiness reports assessed the Courts cohort + the now-retracted ETL.)*

All checklist items pass. No critical gaps block implementation. Mock-first authentication reclassifies G1.1, G1.2, G1.3 from Phase 0 blockers to pre-Phase-9 prerequisites. Phase 0 HMCTS dependencies reduce from 5 to 2 (G1.4 starter, G1.5 email); the JOH eLinks API contract and MRD feed arrangements are new Phase 0 external dependencies introduced by the revised D3 (tracked in [`./architecture/gaps.md` G8](./architecture/gaps.md)). Risk #6 (HMCTS IdP integration timing) is mitigated.

**Why high confidence:**

- Aligned with PRD's locked decisions; the 7 architecture-phase TBDs are resolved without contradiction.
- The two foundational principles and the no-shared-library rule are applied consistently through Steps 3–6.
- Step 5 pattern definitions are concrete and CI-enforceable (Spotless, ArchUnit, Spectral, Pact, axe-core).
- Polyrepo structure matches phased rollout[^d8] and per-service deployment independence (NFR40).
- Mock-first authentication removes the HMCTS IdP roadmap from the Phase 0–8 critical path.

**Strengths:**

- **Simplification** — event bus, shared library, and monorepo all rejected.
- **Multi-AZ HA in UK South** — single-AZ failure is tolerated transparently. Wave rollout isolation (NFR38) is at the app tier via (jurisdiction, region) activation flags (FR57), not per-region infrastructure.
- **No shared library** — cross-cutting concerns are per-service, removing redeployment coupling.
- **API-as-Product enforcement** — versioning, OpenAPI, RFC 9457 problem-details, RFC 9745 + RFC 8594 deprecation signalling — all CI-enforced.
- **Manual UAT in the rollout gate** — `docs/uat/` per service; jurisdiction-incumbent-experienced users sign off per role per wave as the wave-cutover gate.
- **Mock-first authentication** decouples the build from the HMCTS IdP roadmap.
- **Upstream ingestion without new moving parts** — the eLinks sync and MRD pick-up run in-process inside `ctam-reference-data`: no new deployable, no new service principal, and identity lookup reads CTAM's own tables so sign-in never depends on eLinks uptime.

**Post-MVP enhancements (not blocking):** Mermaid / C4 diagrams in `ctam-architecture/diagrams/`; sample ADRs; per-service OpenAPI snippets; service mesh (only if observability or mTLS demands grow); caching (only if measurement shows the need); App Configuration for runtime tuning.

### Implementation Handoff

**For AI agents:**

- Follow the architectural decisions in Steps 3–6.
- Use the patterns in [`./architecture/conventions.md`](./architecture/conventions.md) across all 11 services and the UI.
- Apply the two foundational principles: (1) API for workflows; shared DB for simple data access; (2) no premature optimisation. No shared runtime library.
- Per-service work happens in the service's own repo. Cross-service work happens via API contracts.
- Phase 0–8 authentication is `ctam-mock-auth` only (`authorization_code` for humans; `client_credentials` for the payment batch). Real HMCTS IdP starts at the pre-Phase-9 cutover.
- Raise gaps via PR against this document.

**First implementation steps:**

1. Confirm Phase 0 prerequisites: Azure subscription + UK regions; Terraform state backend + plan/apply pipeline arrangement (G9); HMCTS Java/Spring Boot starter; HMCTS Email transport.
2. Build the CTAM Pathfinder scaffolding script at `ctam-architecture/scaffolding/ctam-scaffold.sh`, layered on the HMCTS starter, with CTAM Pathfinder conventions baked in.
3. Ship `ctam-mock-auth` (Spring Authorization Server; refuses to start with `production` profile; supports `authorization_code` and `client_credentials`).
4. Ship the three Phase 0 cross-cutting services: Reference Data (including the JOH eLinks scheduled sync, the MRD blob pick-up, and the two-tier `jo_*`/`mrd_*`/CTAM-owned table set), Authorisation (including `ctam_auth_staff_identities` and the two-population identity lookup), Notification. The shared `ctam_configuration_values` table is created by `ctam-architecture`'s Liquibase baseline changelog. Confirm the JOH eLinks API contract and the MRD blob-drop arrangement early — both are Phase 0 external dependencies (G8).
5. Deploy Phase 0 to dev. Exercise API-as-Product standards (versioning, OpenAPI, RFC 9457 problem-details, deprecation signalling). Validate Postman collections. Run automated tests. Manual UAT starts in Phase 1.
6. Resolve programme-management dependencies before Phase 9.
7. Begin Phase 1 (JOH service — `ctam-joh`). Expand across Phases 2–8 in dependency order.
8. Pre-Phase-9: real HMCTS IdP cutover — verify G1.1, G1.2, G1.3; switch staging `issuer-url` to HMCTS IdP (and resolve production service-principal issuer per G7.1); rehearse cutover; re-run automated tests + manual UAT against real IdP. Complete the ET-cohort readiness assessment[^d13] — and close G8.4 — before finalising the wave-1 cutover plan.

## External References

Every IETF / standards reference cited in this architecture, with canonical links:

| Reference | Title / Subject | Link |
|---|---|---|
| RFC 9457 | Problem Details for HTTP APIs (current; obsoletes RFC 7807 — `application/problem+json` content type and field shape unchanged) | [datatracker.ietf.org/doc/html/rfc9457](https://datatracker.ietf.org/doc/html/rfc9457) |
| RFC 7807 | Problem Details for HTTP APIs (obsoleted by RFC 9457; retained for historical citations) | [datatracker.ietf.org/doc/html/rfc7807](https://datatracker.ietf.org/doc/html/rfc7807) |
| RFC 9745 | The Deprecation HTTP Response Header Field (March 2025; `Deprecation` header value is a date timestamp, e.g. `Deprecation: @1735689600`) | [datatracker.ietf.org/doc/html/rfc9745](https://datatracker.ietf.org/doc/html/rfc9745) |
| RFC 8594 | The Sunset HTTP Header Field (defines `Sunset: <RFC-date>`) | [datatracker.ietf.org/doc/html/rfc8594](https://datatracker.ietf.org/doc/html/rfc8594) |
| RFC 9110 | HTTP Semantics (defines `Retry-After` in §10.2.3; obsoletes RFC 7231) | [datatracker.ietf.org/doc/html/rfc9110](https://datatracker.ietf.org/doc/html/rfc9110) |
| RFC 6585 | Additional HTTP Status Codes (defines `429 Too Many Requests` in §4) | [datatracker.ietf.org/doc/html/rfc6585](https://datatracker.ietf.org/doc/html/rfc6585) |
| RFC 6648 | Deprecating the "X-" Prefix and Similar Constructs in Application Protocols | [datatracker.ietf.org/doc/html/rfc6648](https://datatracker.ietf.org/doc/html/rfc6648) |
| RFC 1123 | Requirements for Internet Hosts — Application and Support (the "RFC 1123 date" format used by HTTP-date / `Sunset` header) | [datatracker.ietf.org/doc/html/rfc1123](https://datatracker.ietf.org/doc/html/rfc1123) |
| OpenAPI Specification 3.1 | Standard, programming-language-agnostic interface description for HTTP APIs | [spec.openapis.org/oas/v3.1.0](https://spec.openapis.org/oas/v3.1.0.html) |
| WCAG 2.2 AA | Web Content Accessibility Guidelines 2.2, Level AA | [www.w3.org/TR/WCAG22/](https://www.w3.org/TR/WCAG22/) |

## Changelog

See [`./architecture/changelog.md`](./architecture/changelog.md). **Latest:** v4.0 (2026-08-07) — wave-1 pilot retargets from SSCS to the **Employment Tribunals** jurisdiction; SSCS moves to wave 2, Courts to waves 3+; D13 supersedes D11; new gaps G8.4 (ET incumbent unidentified), G8.5 (ET as-is pack / role taxonomy), G8.6 (JFEPS applicability to ET). Earlier: v3.2 (2026-06-11) — `ctam_` prefix on every CTAM-owned table; `_overlays` suffix retired (`ctam_joh_ticket`, `ctam_joh_location`); `jo_sync_status` → `ctam_sync_status`. Earlier: v3.1 (2026-06-11) — Terraform mandated for all infrastructure provisioning (HMCTS standard); colocated first-consumer ownership (shared estate in `ctam-authorisation`'s `terraform/`; per-service resources per repo); new gap G9.1 (state backend + pipeline). Earlier: v3.0 (2026-06-11) — Sprint Change Proposal 2026-06-10 cascade: SSCS-first wave framing[^d11]; no-legacy-migration / two-tier reference-data ownership with JOH eLinks + MRD ingestion (revised D3, FR6/FR7, NFR24); two-population identity model with `ctam_auth_staff_identities`[^d9]; jurisdiction as first-class hierarchical dimension[^d8]; D12 scope boundary; `ctam-judge` → `ctam-joh` full rename; FR renumbering (FR58–FR61 → FR57–FR60); D10 admin-UI-post-MVP reconciliation. Earlier: v2.9 — DB-level detail (column references, SQL operations, DDL) consolidated into *Data Architecture* (new *Retry safety and concurrency control* subsection); abstracted everywhere else. Vocabulary tables renamed for clarity: `fee_payment_statuses` → `judge_fee_entitlements`; `payment_statuses` → `ctam_payment_lifecycle_statuses`. Reference-data vocabulary corrected against the docs (`judge_types`, `ctam_session_types`, `ctam_absence_types`, `ctam_booking_statuses`, `ctam_payment_lifecycle_statuses`, `ctam_reconciliation_statuses`, `judge_fee_entitlements`, `ctam_regions`, `ctam_calendar_periods`). New tooling: `scripts/build-html.sh` (pandoc-based HTML site under `html/`); `sql/mock_ref_data.sql` + `sql/mock_judge_data.sql` (mock data, every value cross-referenced to the docs). Earlier: v2.8 — DR consolidated as a single open gap (G3.6); v2.7 — RFC citations updated to current RFCs + External References appendix.

[^d3]: Revised D3 (2026-06-10) — no data migration from any legacy system; judicial-holder reference data is ingested from the JOH eLinks API and MRD.
[^d7]: D7 — MVP observability is log-based; user-action audit is post-MVP.
[^d8]: D8 — rollout is jurisdiction-first, then per-region; jurisdiction is a first-class hierarchical attribute.
[^d9]: Restructured D9 (2026-06-10; refined 2026-07-09 per SCP) — two user populations. JOHs resolve IdP email → `jo_people` → `personnel_number` → a **CTAM-assigned JOH UUID** (`ctam_joh_identities`, owned by `ctam-reference-data`); HMCTS admin staff via the CTAM-internal staff identity table. Both key on a CTAM-assigned UUID; `personnel_number` is the upstream link only, insulating CTAM domain data from upstream churn. No legacy user migration.
[^d10]: D10 (2026-05-15) — admin UI is post-MVP; MVP admin operations are DBA-via-SQL per operational runbooks.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
[^d12]: D12 (2026-06-10) — CTAM is the system of record for JOH availability and scheduling only; case and hearing management live in external systems.
