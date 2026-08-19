---
type: 'Architecture Shard'
description: 'Decision: 11 service repos + 1 mock-auth repo + 2 UI repos (business + admin) + 1 architecture/scaffolding repo. No monorepo, no Gradle root project.'
resource: 'architecture/tobe/repository-strategy.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-05-07'
parent: ../architecture.md
title: Repository Strategy & List
last_updated: 2026-05-07
---

# Repository Strategy & List

> Sibling of [`../architecture.md`](../architecture.md). The parent links here from its *Project Structure & Boundaries* section.

## Repository Strategy: Polyrepo

**Decision:** 11 service repos + 1 mock-auth repo + 2 UI repos (business + admin) + 1 architecture/scaffolding repo + 1 shared-infrastructure repo. No monorepo, no Gradle root project.

A monorepo would either share `build.gradle` config (breaks no-shared-coupling), coordinate releases (breaks per-region phased rollout independence), or add Bazel-style hermetic build complexity that CTAM Pathfinder's requirements don't need.

Polyrepo gives each service its own repo, pipeline, release cadence, CODEOWNERS, branch protection, and review policy. What stays cross-repo: API contracts (OpenAPI specs), the architecture documents and ADRs, the scaffolding script.

## Repository List

| Repo | Phase | Purpose | Key Functions |
|---|---|---|---|
| **`ctam-shared-infrastructure`** | 0 | Product-level **shared Azure estate**, per the HMCTS Cloud Native Platform `{product}-shared-infrastructure` standard. **Terraform only — no deployable workload.** | Provision and **independently verify** the shared estate — AKS + node pools, PostgreSQL Flexible Server, ACR, APIM + base policies, Application Insights / Log Analytics, Key Vault — in **Epic 0.0**, ahead of any service; own Terraform state backend + plan/apply pipeline (gaps.md G9). |
| **`ctam-architecture`** | 0 | Architecture index + siblings, ADRs, scaffolding script. *(The `migration/` ETL is retracted — revised D3, 2026-06-10.)* | Maintain architecture docs and ADRs; generate new service repos via `ctam-scaffold.sh`. |
| **`ctam-mock-auth`** | 0 | OIDC issuer for dev / CI / integration (human users **and** batch service principals). **Never deployed to production.** | Issue JWTs via OIDC `authorization_code` for human users; **issue service tokens via OAuth `client_credentials`** for batch components (initially `ctam-payment-batch`); refuse to start with `production` profile (G5.3). |
| **`ctam-reference-data`** | 0 | Owns all 33 reference-data tables — tier (a) upstream-sourced (15 `jo_*` + `mrd_*`) and tier (b) CTAM-owned (`ctam_regions` / `ctam_offices` / `ctam_calendar_periods` + vocabularies), plus `ctam_sync_status` and `ctam_joh_identities` (the CTAM-assigned JOH identifier, minted during the eLinks sync). **First domain service scaffolded** (integrations-first sequencing, decision #12 / SCP 2026-06-17); **deploys onto the shared estate provisioned in `ctam-shared-infrastructure`** (Epic 0.0, AR53 revised); carries only its own per-repo Terraform (MRD storage, Story 0.1.4). | In-process JOH eLinks nightly sync + MRD weekly blob pick-up (tier a — the programme's first deliverable and first external integration); versioned read API (jurisdiction-filtered[^d8] — downstream of auth, lands after the auth epic); tier-(b) maintenance by DBAs via SQL in MVP[^d10]; reads happen via direct SQL by other services. |
| **`ctam-authorisation`** | 0 | Owns the 6 Authorisation tables; **the per-request authz authority**. | Manage `ctam_auth_users`, `ctam_auth_staff_identities`, `ctam_auth_roles`, `ctam_auth_user_roles`, `ctam_auth_user_region_scopes`, `ctam_auth_user_activation_flags`; expose `POST /authz/check` with two-population identity resolution (IdP email → `jo_people` → `personnel_number` → `ctam_joh_identities` CTAM JOH UUID for JOHs; → `ctam_auth_staff_identities` CTAM UUID for admin staff,[^d9]); enforce per-(jurisdiction, region) phased activation (FR57). |
| **`ctam-notification`** | 0 | Outbound transactional email dispatch. | Send booking ack (FR32) / absence ack / JFEPS-shaped payment-schedule emails (FR43); record dispatch log; retry on transient failure. |
| **`ctam-joh`** | 1 | JOH operational state — working patterns + ticket/location overlays + jurisdictional split, keyed by `joh_id` → `ctam_joh_identities`. *(Renamed from `ctam-joh`[^d11]; the canonical JOH person record is `jo_people`, owned by Reference Data.)* | Manage working patterns (FR12); generate forward sittings (FR13); manage ticket overlays (FR15b) and location overlays (FR17); jurisdictional splits with 100% sum constraint (FR16); JOH search/profile views compose `jo_*` + overlays (FR10, FR11). |
| **`ctam-absence`** | 2 | Absence records + approval workflow. | Create / approve / NTBF-flag / sickness-extend (FR19–FR22); on approval, call Vacancy to create cover-required vacancies (R4); send acknowledgements via Notification. |
| **`ctam-vacancy`** | 3 | Cover-requirement records + per-day breakdown. | Create vacancies (FR23, FR24); manage `ctam_vacancy_days` (FR25); accept `filled` / `filled_at` UPDATEs from Booking. |
| **`ctam-booking`** | 4 | Fee-paid bookings + verification. | Create / verify / cancel fee-paid bookings (FR29, FR31); within the booking transaction, mark the target vacancy as filled (R5, Principle 1); retry-safe via native DB primitives (see [`../architecture.md`](../architecture.md) → *Data Architecture*). |
| **`ctam-sitting`** | 5 | Salaried-judge sittings + verification. | Maintain sitting records (generated from working patterns); confirm and verify sittings (FR37); AM/PM session split (FR38); post-verification re-open via RBAC (FR40 — RSU Admin only at MVP, with mandatory justification + audit; no external RFC process); work-type override on confirmation. |
| **`ctam-payment`** | 6 | Payment processing + reconciliation. JFEPS-shaped Excel output. **Two parts: a synchronous API (RSU reconciliation) and a scheduled batch component (`ctam-payment-batch`).** | **Batch component** (scheduled; runs as service principal `ctam-payment-batch` per v2.6): SQL JOIN read across confirmed bookings + sittings without an existing payment record; generate JFEPS Excel (FR41–FR44); persist payments and schedules; call Notification with bearer service token to dispatch the schedule (FR43). **Synchronous API**: RSU lists unreconciled payments and marks them reconciled (FR46). FR45 retry safety via native DB primitives (see [`../architecture.md`](../architecture.md) → *Data Architecture*). **Never stores bank details** (NFR14). |
| **`ctam-itinerary`** | 7 | Operational read model. **No own tables** — SQL JOINs across judges, absences, vacancies, bookings, sittings. | Court itinerary view; Judge itinerary view (scoped to own profile per R2); Forward Look (≤ 30 s p95 — NFR8). |
| **`ctam-mi-feed`** | 8 | Aggregate MI read model. **No own tables**. | Standard reports (utilisation, sittings, payments) with same parameter shape as APEX; aggregate-only — **no case-level data** (NFR23); Excel/PDF export; DA&I consumer interface (post-MVP). |
| **`ctam-ui`** | 0–8 | **Business-user-facing SPA**, modules per domain. Excludes admin workflows. | Per-phase UI module replicating APEX functional surface for business roles (RSU operational work, Court users, Judges, Judges' Clerks, Finance/Payment Authoriser, MI); role-scoped Home with Outstanding-Actions tiles (FR55); SSO via HMCTS IdP / mock auth; GOV.UK Design System with WCAG 2.2 AA (NFR17). |
| **`ctam-admin-ui`** | 0 | **Admin-facing SPA**, separated from business workflows. Same stack as `ctam-ui` but distinct repo, pipeline, and deployment. | Reference Data maintenance (FR6 — Regions, Offices, judicial vocabularies, calendar / financial-year boundaries with named-owner sign-off); User & Role admin (FR4 — system administrators update role and Region/Area assignments for migrated and new users). **Post-MVP repo[^d10]** — in MVP these operations are DBA-via-SQL per runbook. Future admin surfaces reserved: per-(jurisdiction, region) activation flag dashboard (FR57), post-MVP user-action audit viewer (D7 roadmap). Same SSO + Authorisation pattern as `ctam-ui`. |

**16 repos total** (11 production services + 2 UI + architecture + mock-auth + shared-infrastructure). `ctam-shared-infrastructure` is Terraform-only (no deployable workload); `ctam-mock-auth` is dev/integration-only and never deploys to production.

**Why split admin and business UI:** business operational workflows (judges, absences, vacancies, bookings, sittings, payments, itineraries, reports) are continuously evolving with HMCTS judicial process. Admin work (managing the controlled vocabularies and user role assignments those workflows depend on) is lower-cadence, higher-stakes (a wrong Region rename or role flip cascades into operational chaos), and has a different audience (system administrators, not RSU/Court/Judges). Keeping them in separate repos gives independent CI/CD, independent rollout, distinct CODEOWNERS, and prevents accidental coupling — for example, admin-only screens cannot leak into a business user's nav by misconfiguration. Same as the backend's per-service polyrepo discipline: minimise shared code, accept duplication, gain independence.

[^d8]: D8 — rollout is jurisdiction-first, then per-region; jurisdiction is a first-class hierarchical attribute.
[^d9]: Restructured D9 (2026-06-10; refined 2026-07-09 per SCP) — two user populations. JOHs resolve IdP email → `jo_people` → `personnel_number` → a **CTAM-assigned JOH UUID** (`ctam_joh_identities`); HMCTS admin staff via a CTAM-internal identity table. Both key on a CTAM-assigned UUID; `personnel_number` is the upstream link only. No legacy user migration.
[^d10]: D10 (2026-05-15) — admin UI is post-MVP; MVP admin operations are DBA-via-SQL per operational runbooks.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
