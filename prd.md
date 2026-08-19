---
type: 'PRD'
title: 'Product Requirements Document - ctam-analysis'
description: 'Author: Ramnish'
resource: 'prd.html'
tags: [ctam-pathfinder, prd, employment-tribunals]
timestamp: '2026-06-17'
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation-skipped', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish', 'step-12-complete']
workflowCompleted: true
completedAt: '2026-05-05'
lastEdited: '2026-06-17'
editHistory:
  - date: '2026-05-15'
    workflow: 'bmad-correct-course'
    changes: 'D10 (Admin UI deferred post-MVP); no gh CLI constraint; FR4/FR6/FR56/FR58 scoped per D10; Phase 0 epic stories restructured 18 → 11.'
  - date: '2026-06-10'
    workflow: 'bmad-correct-course'
    changes: 'D11 (SSCS-first pilot wave) + D12 (CTAM scope = availability/scheduling, not case/hearing management). D3 superseded (no migration; JOH eLinks + MRD facade). D5 reframed (jurisdiction-incumbent UAT). D8 reframed (jurisdiction-first, then per-region; jurisdiction as hierarchical first-class attribute). D9 restructured (two distinct user populations: JOH via jo_people + admin staff via CTAM-internal table). D10 SQL-ETL sub-clause superseded. FR57 (Phase 0 ETL) retracted; FR58–FR61 renumbered FR57–FR60. New FRs amended: FR1, FR2, FR4, FR6, FR7, FR10–FR18, FR23, FR27, FR29, FR32, FR33, FR34, FR35, FR36, FR39, FR57, FR60. NFR24 flipped (eLinks in MVP). Executive Summary rewritten. Glossary additions: GAPS, JOH, Jurisdiction, MRD, RTJ, SSCS, Tribunal Member, Tribunal Panel. Authentication Model reframed. User Journeys: SSCS Journey 1 added; existing journeys renumbered 1→2 … 5→6. Phase-by-Phase Journey Mapping table + Integration Requirements table updated. See sprint-change-proposal-2026-06-10.md.'
  - date: '2026-06-10'
    workflow: 'bmad-validate-prd + bmad-edit-prd'
    changes: 'Validation revealed Success Criteria + Product Scope + NFR cohort sections were not threaded into the 21-edit SSCS-pivot cascade. Edit pass applied 10 edit proposals covering: User Success / Business Success / Technical Success / Measurable Outcomes table rewrites for D11 alignment (Section A); MVP / Explicit Exclusions / Growth Features / Vision rewrites for D11 alignment (Section B); NFR section intro + NFR13 + NFR21 + NFR32 + NFR36 + NFR38 + NFR41 cohort sweep (Section C). PRD now internally consistent with D1–D12. Validation rating expected to lift from 4/5 to 5/5.'
  - date: '2026-06-17'
    workflow: 'bmad-validate-prd (+ Fix Simpler Items)'
    changes: 'Re-validation (12 steps; report prd-validation-report-2026-06-17.md) found 0 blocking issues, 4/5. Three residual SSCS-pivot staleness items fixed in-place: (1) Domain §Technical Constraints "User records … migrated from APEX in Phase 0" → bootstrap model (no APEX migration), restoring consistency with revised D3 / restructured D9; (2) API Backend section legacy "JI"/"Judge" naming → "CTAM Pathfinder" / "JOH (ctam-joh)" and the Reference Data "admin-gated POST/PUT" endpoint → read-only over both tiers (D10/D11); (3) Journey Requirements Summary "five journeys" → "six". The integrations-first restructure (SCP 2026-06-17) did not touch the PRD; these predated it.'
  - date: '2026-08-07'
    workflow: 'bmad-correct-course'
    changes: 'D13 (ET-first pilot wave) supersedes D11 for wave ordering: wave 1 = Employment Tribunals (ET), wave 2 = SSCS, waves 3+ = Courts per HMCTS judicial region. D5 re-parameterised (wave-1 parity reference), D8 wave sequence restated, D11 marked superseded. No FR or NFR added, removed or renumbered; ~12 reworded where their prose names a jurisdiction or incumbent (FR6, FR7, FR44, FR57, FR60, NFR21, NFR24, NFR32, NFR36, NFR38, NFR41). Target Users: ET working set added as PROVISIONAL pending the ET as-is pack; SSCS set preserved verbatim at wave 2. Journey 1 rewritten as the ET wave-1 journey (structural placeholder — service chain settled, ET specifics provisional) with the SSCS journey preserved as a wave-2 variant; journey count stays at six. Glossary: 5 ET entries added (Employment Tribunals, Employment Judge, Regional Employment Judge, Non-legal member, [ET-INCUMBENT-TBD]); SSCS/ListAssist/GAPS/RTJ/Tribunal Member/Tribunal Panel relabelled to wave 2. ET scheduling incumbent is UNIDENTIFIED — recorded as the placeholder token [ET-INCUMBENT-TBD] throughout (gap G8.4); ET role taxonomy provisional (G8.5); JFEPS applicability to ET unverified (G8.6). No epic added, removed or resequenced; no code impact (implementation not started). Business case retargeted to ET as a settled decision, with two supporting-evidence items outstanding. See sprint-change-proposal-2026-08-07.md.'
  - date: '2026-08-13'
    workflow: 'bmad-correct-course'
    changes: 'D14 — programme renamed RAM to CTAM (Court and Tribunals Availability Management). Naming-only cascade applied uniformly across every surface: product codename (CTAM Pathfinder), 17 repository names (ctam-*), owned-table prefix (ctam_) and index names (uq_ctam_*), Java root package (uk.gov.hmcts.ctam), API-spec artefact coordinates (api-ctam-{service}), shared schema name (ctam), DNS hostnames, and adjectival prose (CTAM-owned / CTAM-assigned / CTAM-internal / CTAM-overlay). Upstream jo_ / mrd_ and dev-only mock_ prefixes untouched. No FR or NFR added, removed, renumbered or reworded in substance; no epic, story, decision, gap or assumption changed; no code impact (implementation not started). New glossary entry: CTAM. Dated reports, SCPs and prior changelog entries rewritten in place for uniform searchability; git history is the point-in-time record. See sprint-change-proposal-2026-08-13.md.'
productCodename: 'CTAM Pathfinder'
releaseMode: 'phased'
inputDocuments:
  - '_bmad-output/brainstorming/brainstorming-session-2026-05-05-1600.md'
  - 'docs/architecture/asis/functional-modules.md'
  - 'docs/architecture/asis/data-dependencies.md'
  - 'docs/architecture/asis/integration-dependencies.md'
workflowType: 'prd'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 1
  projectDocs: 3
  projectContext: 0
classification:
  projectType: 'api_backend'
  projectTypeOverrides:
    - 'ux_ui in scope per D4'
    - 'visual_design in scope per D4'
    - 'user_journeys in scope per D4'
  domain: 'govtech'
  domainNotes: 'UK HMCTS — judicial operations; HMCTS/WCAG accessibility, GDS service standard, UK GDPR, FOI/transparency.'
  complexity: 'high'
  projectContext: 'brownfield-rebuild'
  classificationRationale: 'Scoring during Advanced Elicitation: api_backend (24) vs web_app (22) vs saas_b2b (18); govtech (29) vs legaltech (10). api_backend is composed of 11 APIs; UX/journeys is in scope because D4 requires UI replication.'
---

# Product Requirements Document - ctam-analysis

**Author:** Ramnish
**Date:** 2026-05-05

## Document Map

CTAM Pathfinder is HMCTS's greenfield platform for judicial scheduling across **Tribunals and Courts**. 11 services, modern UI, Azure-deployed. It pilots on the **Employment Tribunals (ET)** jurisdiction in wave 1[^d13], replaces **ListAssist** (the SSCS judicial-scheduling tool) in SSCS in wave 2, and the as-is **JI application on unsupported Oracle APEX (OPT)** in Courts in waves 3+. Built in isolation from the incumbents; cutover is jurisdiction by jurisdiction, then per region within Courts. *(ET's scheduling incumbent is not yet identified — gap G8.4.)*

| Section | Contents |
|---|---|
| Executive Summary | What CTAM Pathfinder is and why it is being built |
| Project Classification | Project type, domain, complexity |
| Success Criteria | Definition and measures of success |
| Product Scope | MVP, growth, vision |
| User Journeys | How users flow through CTAM Pathfinder |
| Domain-Specific Requirements | UK govtech compliance, technical, integration constraints |
| API Backend Specific Requirements | The 11-service API surface |
| Project Scoping & Phased Development | MVP scope, build phases, rollout waves |
| Functional Requirements (FR1–FR60) | Capability contract |
| Non-Functional Requirements (NFR1–NFR42) | Quality-attribute contract |
| Decisions Log (D1–D12) | Programme-level decisions |
| Glossary, References | Acronyms and source documents |

## Executive Summary

**CTAM Pathfinder** is HMCTS's API-driven greenfield platform for judicial scheduling — the planning, allocation, confirmation and payment of sittings and hearings for Judicial Office Holders (JOHs). It will be rolled out **jurisdiction by jurisdiction**[^d8][^d13], starting with the **Employment Tribunals (ET)** jurisdiction in wave 1, continuing with the **SSCS Tribunals jurisdiction** in wave 2, and then the **Courts jurisdiction** (Civil, Family, Crown) across the HMCTS judicial regions in waves 3+.

Two incumbent arrangements are replaced:

- **ListAssist** — the SSCS judicial-scheduling tool through which SSCS Tribunals schedule judicial sittings today. Replaced by CTAM Pathfinder in **wave 2**[^d13]. (GAPS, the SSCS case-management system, is **retained**, not decommissioned — analogous to the external case-management systems that consume CTAM's APIs per D12.)
- **JI / Oracle APEX (OPT)** — HMCTS's Courts judicial scheduling application. Unsupported with a fixed end-of-life. Replaced in **waves 3+** (Phase 11+), one HMCTS judicial region per wave.[^d13]

The same 11-service architecture serves both jurisdictions (Domain / Cross-cutting / Read-model). A modern UI replaces each legacy UI as the jurisdiction migrates. CTAM Pathfinder exposes versioned APIs that HMCTS programmes (DA&I, finance, Actuals, Scheduling & Listing) consume directly, replacing today's export-file-by-email integration.

**Terminology note:** existing JI / CTAM Pathfinder documents use "judge" as the dominant term for the people whose schedules are managed. To accommodate the Tribunals jurisdictions — where panels include non-judge members (in ET, non-legal "lay" members from the employer-side and employee-side panels[^d13]; in SSCS, Medical Members, Disability-Qualified Members and Disability (Other) Members) who are not judges in the Courts sense — the project adopts **Judicial Office Holder (JOH)** as the umbrella term going forward. "Judge" remains valid where the meaning is specifically a judge (Circuit Judge, District Judge, salaried Tribunal Judge, fee-paid Recorder, etc.); JOH is used wherever the meaning includes non-judge panel members.

**Target users:**

*Employment Tribunals jurisdiction (wave 1) — **PROVISIONAL**. Applicable roles will be enumerated against the **ET as-is analysis pack** (gap G8.5; parallel to the JI pack under `docs/architecture/asis/`), which does not yet exist. Working set, pending confirmation:*

- Regional Employment Judges — JOHs
- Employment Judges, salaried and fee-paid — JOHs
- Non-legal ("lay") members — employer-side and employee-side panels — JOHs
- ET scheduling / listing admin staff (exact role titles TBC)
- Finance / Payment Authoriser (shared — **JFEPS path applicability to ET unverified, gap G8.6**)
- MI / Reporting User (shared across jurisdictions)

*SSCS Tribunals jurisdiction (wave 2)[^d13] — as previously enumerated against the ListAssist as-is analysis pack. Working set:*

- Regional Tribunal Judges (RTJ) — JOHs
- Tribunal Judges, salaried and fee-paid — JOHs
- Tribunal Members — Medical, Disability-Qualified, Disability (Other) — JOHs
- Tribunal Caseworkers / scheduling admin
- Finance / Payment Authoriser (shared with Courts jurisdiction — JFEPS path preserved[^d11])
- MI / Reporting User (shared with Courts jurisdiction)

*Courts jurisdictions (waves 3+) — ~11 roles, scoped by HMCTS judicial Region and Area:*

- RSU / Judicial Team (Admin, Full Access, Verifier / Read-only)
- Court users (Full Access, Enhanced CJ, Limited / Read-only)
- Judges, Judges' Clerks, Presiding Judges / Clerks — JOHs and their support staff
- Finance / Payment Authoriser
- MI / Reporting User

*Operational platform support (OPT Support in the legacy JI system; equivalents in ListAssist and the ET incumbent) is handled by external HMCTS roles and is not a CTAM Pathfinder user role.*

**Problems being solved:**

1. **The incumbents have replacement drivers.** In Courts, APEX is unsupported with a fixed end-of-life. In Tribunals/SSCS, judicial scheduling runs on ListAssist, which CTAM Pathfinder replaces in wave 2. (GAPS, the SSCS case-management system, is retained, not decommissioned.) **In Tribunals/ET — the wave-1 pilot — the incumbent and its replacement driver are not yet established (gap G8.4); this is an open item for the ET-cohort readiness assessment.**[^d13]
2. **The export-only integration model** (Excel, PDF, email) does not scale to upcoming HMCTS programmes (Actuals, Scheduling & Listing reforms, DA&I MI consumption).
3. **Both legacy UIs are dated.** CTAM Pathfinder provides a modern, accessible, performant UI replicating each jurisdiction's legacy functional surface[^d4].

**Success:** the **Employment Tribunals** jurisdiction migrated to CTAM Pathfinder in wave 1[^d13] (its scheduling incumbent replaced — system not yet identified, gap G8.4); the SSCS jurisdiction migrated in wave 2 with ListAssist replaced for SSCS scheduling (GAPS case management retained); every HMCTS Courts judicial region migrated in waves 3+ with APEX/JI retired; downstream consumers integrating via API; future HMCTS programmes building on CTAM Pathfinder's APIs.

### Key characteristics

1. **Greenfield, not strangler.** Neither ListAssist nor APEX supports strangler decomposition (the ET incumbent is unassessed — G8.4). CTAM Pathfinder is built end-to-end before any user moves; the legacy system in each jurisdiction runs unchanged for non-migrated users during phased rollout. No dual-write, no event bus, no synchronisation layer.

2. **Simplification.** REST-first synchronous coordination; Strategy A federated read models (Itinerary, MI Feed); no event stream; no webhook surface; log-based audit and observability for MVP[^d7] with structured user-action audit on the post-MVP roadmap.

3. **The jurisdiction's incumbent system is the behavioural reference, verified by manual UAT[^d5][^d11].** UAT is performed by users with hands-on experience of *that jurisdiction's* incumbent system — `[ET-INCUMBENT-TBD]`-experienced users (ET role set *provisional*, G8.5) for wave 1; ListAssist-experienced users (RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI) for wave 2; APEX-experienced users (RSU, Court, Judge, Judges' Clerks, Finance, MI) for waves 3+. They compare CTAM Pathfinder behaviour against the incumbent side-by-side. No automated comparison harness; legacy systems are not co-managed[^d6].

4. **Phase 0 as platform smoke-test.** Reference Data is sourced from JOH eLinks API + MRD[^d11][^d3] (no ETL, no legacy migration); user identity is split between JOH records (via `jo_people`) and a CTAM-internal admin-staff table[^d9]. API-as-Product standards (versioning, OpenAPI, deprecation via [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) + [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594)) are exercised on **Reference Data read endpoints** and Authorisation lookups before any domain service is built. Admin-write API endpoints (and the admin UI that would consume them) are deferred post-MVP[^d10].

5. **Per-jurisdiction, per-region phased cutover[^d8][^d13].** Wave 1 is the Employment Tribunals jurisdiction. Wave 2 is the SSCS Tribunals jurisdiction. Waves 3+ are Courts regions, one HMCTS judicial region per wave, with all applicable in-region roles together. Migrated users do not use the legacy system; non-migrated users do not use CTAM Pathfinder. No contention or synchronisation.

6. **One decomposition serves every jurisdiction[^d13][^d12].** The same 11 services cover ET and SSCS alike: non-judge member sub-types — in ET, non-legal ("lay") members from the employer-side and employee-side panels (*provisional, G8.5*); in SSCS, Medical, Disability-Qualified and Disability (Other) Members — are additional JOH types handled by `ctam-joh`, `ctam-booking` and `ctam-sitting`. Panel composition for specific cases and hearing-type tracking live in **external case-management systems**[^d12], not in CTAM.

**Why now:** the **Employment Tribunals** jurisdiction is the chosen wave-1 pilot[^d13]. SSCS follows in wave 2, where ListAssist (the SSCS judicial-scheduling tool) is replaced (GAPS case management is retained). APEX is unsupported with its own end-of-life and is replaced in waves 3+. HMCTS programmes need integration patterns the export-only legacy cannot deliver. Each month on the legacy systems delays API integration for the wider ecosystem.

## Project Classification

| Dimension | Value |
|---|---|
| **Project Type** | `api_backend` — composed of 11 APIs |
| **Project Type override** | `ux_ui`, `visual_design`, `user_journeys` are in scope[^d4] (modern UI replicates APEX layouts) |
| **Domain** | `govtech` (UK HMCTS — judicial operations) |
| **Domain notes** | UK compliance: HMCTS / WCAG accessibility, GDS service standard, UK GDPR, FOI / transparency. |
| **Complexity** | `high` |
| **Project Context** | `greenfield-rebuild` |
| **Classification rationale** | Scoring during Advanced Elicitation: `api_backend` 24, `web_app` 22, `saas_b2b` 18; `govtech` 29, `legaltech` 10. `api_backend` + UX override fits an API-first product with UI in scope. |

## Success Criteria

### User Success

Each role can complete its legacy workflow on CTAM Pathfinder without re-training, and faster or no slower than the **cohort's incumbent system** (`[ET-INCUMBENT-TBD]` for the ET jurisdiction in wave 1 — G8.4; ListAssist for the SSCS jurisdiction in wave 2; APEX for Courts jurisdictions in waves 3+):

**Employment Tribunals jurisdiction (wave 1)** — *role set provisional pending the ET as-is pack (G8.5); parity comparison blocked on G8.4*:

- **Regional Tribunal Judges (RTJ) / Tribunal Caseworkers**: manage tribunal-member availability, working patterns, tickets, absences, vacancies. Vacancy auto-creation from approved absences works end-to-end (R4).
- **Tribunal Judges (salaried and fee-paid)**: itinerary and forward look filtered to authorised JOHs only (R2). No case-level data exposure.
- **Tribunal Members (Medical, Disability-Qualified, Disability (Other))**: itinerary scoped to authorised JOHs only; Specialisations and tickets visible from JOH eLinks + MRD per FR15.

**Courts jurisdictions (waves 3+):**

- **RSU / Judicial Team**: maintain JOHs, working patterns, tickets, absences, vacancies. Vacancy auto-creation from approved absences works end-to-end (R4).
- **Court users**: confirm sittings and bookings with comparable or fewer clicks than APEX. AM/PM split, work-type editing, and verifier sign-off (County Courts) preserved.
- **Judges and Judges' Clerks**: itinerary and forward look filtered to authorised JOHs only (R2). No case-level data exposure.

**Shared across all jurisdictions:**

- **Finance / Payment Authoriser**: JFEPS-compatible Excel via the same email mechanism (verified for SSCS[^d11], now wave 2; unchanged for Courts waves 3+). **ET wave-1 applicability is unverified — gap G8.6**[^d13].
- **MI / Reporting**: standard reports with the same parameter filters as the incumbent. Excel and PDF export preserved. Aggregate-only.
- **All roles**: WCAG 2.2 AA UI; performance baseline meets the cohort's incumbent page-level NFRs (per the Courts/APEX baseline per NFR1–NFR5; each wave verifies against its own incumbent's equivalent operations per that cohort's readiness assessment — **for ET wave 1 this is blocked on G8.4**)[^d13].

### Business Success

- **Legacy retirement** — the ET scheduling incumbent replaced for ET in wave 1 (system not yet identified — G8.4, so the retirement benefit cannot yet be stated); ListAssist (SSCS judicial scheduling) replaced for SSCS in wave 2 (GAPS case management retained, not decommissioned); Oracle APEX (OPT) decommissioned as every Courts judicial region migrates in waves 3+.[^d13]
- **Strategic integration platform** — Tribunals is served from wave 1 (ET) and wave 2 (SSCS)[^d13]; the post-MVP commitment is at least one further HMCTS programme (Actuals, Scheduling & Listing) integrating via API by `TBD post-MVP date`, replacing the export workflow.
- **Continuity** — zero unpaid JOHs due to cutover. Payment exports to JFEPS/Liberata continue uninterrupted across every rollout wave (ET wave 1 — **subject to G8.6**; SSCS wave 2; Courts waves 3+).
- **Delivery** — phase-by-phase cadence (Phase 0 → 8 build, then per-jurisdiction-then-per-region rollout[^d8] reframed). Specific dates are programme-management territory.

### Technical Success

- **All 11 services live** — Reference Data, Authorisation, Notification, **JOH** (`ctam-joh`[^d11] — was `ctam-judge`), Absence, Vacancy, Booking, Sitting, Payment, Itinerary, MI Feed (Phases 0 → 8). Per-service config: Spring profiles + Key Vault. Cross-service policy values: shared `ctam_configuration_values` table.
- **Phase 0 ingestion correctness**[^d11][^d3] — JOH eLinks API integration live and serving the 15 `jo_*` entities; MRD weekly Excel feed ingested and exposed via `ctam-reference-data`'s read API; `ctam-authorisation` resolves IdP email → personal_number (JOH) or staff identifier (admin)[^d9]. *(The previous "100% of Reference Data lists ETL'd + 100% of active APEX users loaded" criterion is retracted along with the Phase 0 Data Migration ETL.)*
- **Behavioural parity**[^d5] — manual UAT script per domain service, walked by **jurisdiction-incumbent-experienced users**: `[ET-INCUMBENT-TBD]`-experienced users (ET role set *provisional*, G8.5) for wave 1; ListAssist-experienced users (RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI) for wave 2; APEX-experienced users (RSU, Court, Judge, Judges' Clerks, Finance, MI) for waves 3+. Sign-off is the wave gate.
- **API-as-Product** from Phase 0 — versioned contract, OpenAPI spec, deprecation policy ([RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) `Deprecation` + [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594) `Sunset`) per service.
- **Performance NFRs** met or exceeded (≤ 5 s dashboard refresh; ≤ 10 s list/filter; ≤ 15 s batch/annual; ≤ 30 s reports/Forward Look). Page-level NFRs are derived from the APEX baseline; each wave's cutover verifies these against that incumbent's equivalent operations as part of the cohort readiness assessment (**ET wave 1: blocked on G8.4**)[^d13].
- **Strategy A federated read models** (Itinerary, MI Feed) meet their NFRs at MVP, or Strategy C cache fallback is in place by the wave that needs it (Risk #9).
- **Log-based observability**[^d7] from Phase 1 — structured logs, correlation IDs, error categorisation, retention sufficient for pilot incident triage.

### Measurable Outcomes

| Outcome | Target | Source |
|---|---|---|
| Reference Data ingestion correctness | JOH eLinks API live with all 15 `jo_*` entities served via `ctam-reference-data` read API; MRD Excel feed ingested on the weekly cadence; consumer queries return jurisdiction-filtered results | D11 + revised D3 |
| User onboarding correctness | All in-wave users can sign in via HMCTS IdP SSO and resolve to a canonical identifier (personal_number for JOHs via `jo_people`; staff identifier for admin staff via the CTAM-internal staff identity table); zero ambiguous lookups | Restructured D9 |
| Payment export continuity at cutover | Zero failed JFEPS payment cycles attributable to cutover (ET wave 1, SSCS wave 2, or any Courts wave 3+) | Business success criterion above |
| Behavioural parity per domain service | 100% of manual UAT scripts (run by jurisdiction-incumbent-experienced users — `[ET-INCUMBENT-TBD]`-experienced for wave 1, ListAssist-experienced for wave 2, APEX-experienced for waves 3+ — comparing CTAM Pathfinder vs the incumbent) signed off before that wave's cutover | D5 reframed + FR60 |
| Per-wave feature parity | 100% of in-jurisdiction (waves 1–2) or in-region in-jurisdiction (waves 3+) role workflows demoed and signed off before wave cutover | D8 reframed + Risk #3 |
| Page-level performance | All page-level NFRs from `functional-modules.md` met or exceeded; each wave's cutover verifies against that incumbent's equivalent operations (ET wave 1 blocked on G8.4) | functional-modules.md cross-cutting NFRs |
| Forward Look (federated read) | ≤ 30 s for a Region under Strategy A; Strategy C cache fallback designed | JFL-NFR-01, Risk #9 |
| API consumer onboarding (post-MVP) | At least one external HMCTS programme (Actuals, Scheduling & Listing) integrating via API by `TBD` | Vision: strategic integration platform |
| MVP user-action audit | Not in MVP; on roadmap[^d7] | D7 |

## Product Scope

### MVP — Minimum Viable Product

The MVP is the smallest deliverable that supports phased per-jurisdiction-then-per-region rollout[^d8]. It comprises:

- **Phase 0 Foundations**[^d1][^d7][^d9][^d11]: Reference Data sourced from JOH eLinks API + MRD[^d3] (no ETL, no legacy migration); Authorisation with SSO and the two-population identity model[^d9]; Notification; API contracts (versioned + paper contracts for Itinerary / MI Feed); deployment platform (CI/CD); structured logging conventions[^d7]; stub Home / navigation shell. *(Per-service configuration via Spring profiles + Key Vault; shared `ctam_configuration_values` infrastructure table managed by `ctam-architecture` Liquibase baseline changelog.)*
- **All 11 services built** (Phases 0–8): Reference Data, Authorisation, Notification (Phase 0); **JOH (`ctam-joh`)**, Absence, Vacancy, Booking, Sitting, Payment (incl. Reconciliation) (Phases 1–6); Itinerary, MI Feed (Phases 7–8). *(Per-service config is Spring profiles + Key Vault; cross-service policy values use the shared `ctam_configuration_values` infrastructure table — no separate configuration service per arch v2.2.)*
- **Modern business-user UI** for all in-jurisdiction roles replicating the cohort's incumbent UI layouts[^d4] — every domain phase delivers its corresponding domain module end-to-end through `ctam-ui`. **Admin UI (`ctam-admin-ui`) is NOT in MVP**[^d10] (2026-05-15 scope decision); admin tasks in MVP — user/role/jurisdiction/Region-scope updates, activation toggles — happen via direct SQL by DBAs / platform engineers per operational runbooks. *(Reference Data is sourced upstream from JOH eLinks + MRD[^d11] — corrections happen at source, not in CTAM. Migration-report review is obsolete under D11.)*
- **Phase 9 — Pilot rollout (wave 1)**: the **Employment Tribunals jurisdiction** migrates[^d13], with all applicable in-jurisdiction roles, with feature-parity gating per Risk #3. (SSCS follows as wave 2; Courts regions as waves 3+.)
- **Behavioural parity with the jurisdiction's incumbent** verified through **manual UAT performed by jurisdiction-incumbent-experienced users** (D5 reframed; FR60) — `[ET-INCUMBENT-TBD]`-experienced users for wave 1, ListAssist-experienced users for wave 2, APEX-experienced users for waves 3+. There is no automated incumbent-comparison test harness in the MVP.
- **Log-based audit and observability**[^d7] — application logs only; no metrics platform, no traces, no structured user-action audit.

**Explicit exclusions from MVP** (post-MVP roadmap):

- Structured user-action audit (D7 roadmap)
- Metrics + traces + dashboards observability (D7 — log-based MVP only)
- Domain event stream / webhooks (architecturally rejected for MVP — REST-first)
- Active matching / allocation service (architecturally deferred[^d12] — CTAM exposes availability/traits; allocation is an external-system concern)
- Bi-temporal history
- Historical-data access at cutover (D3 superseded by D11 — no migration; historical scheduling data stays in the cohort's incumbent system: `[ET-INCUMBENT-TBD]` for ET (G8.4), ListAssist for SSCS, APEX for Courts; access policy per Risk #2 is a separate decision)
- **Admin UI (`ctam-admin-ui`) — entire admin-facing surface deferred post-MVP[^d10] (2026-05-15)**, including:
  - Reference Data maintenance UI — *retracted in its previously-defined form[^d11]* (`ctam-reference-data` is a facade over JOH eLinks + MRD; corrections happen at source, not in CTAM). A future decision will determine whether RSU users get a write surface that proxies upstream APIs, or whether maintenance stays entirely upstream.
  - Users / Roles / Scope admin UI (FR4's UI surface — auth tables populated by mechanisms outside the PRD scope[^d9]; DBAs maintain via direct SQL in MVP)
  - Activation Flag toggle UI (FR57 cutover in MVP via direct SQL by DBA per the rollout runbook)
  - Admin "Send Test Email" + Delivery-Log viewer (Notification integration testing in MVP via Postman against Mailpit)
- **Admin-write API endpoints** on `ctam-authorisation` — read-only surfaces only in MVP; write endpoints ship with the admin UI post-MVP. *(Admin-write endpoints on `ctam-reference-data` are retracted under D11 since the data is upstream-sourced.)*

### Growth Features (Post-MVP)

- **Admin UI (`ctam-admin-ui`) — full repo + auth wrapper + admin theme + MVP-deferred modules**[^d10]:
  - Reference Data maintenance — *scope dependent on D11 follow-up decision* (whether RSU users get a write surface that proxies upstream APIs to JOH eLinks / MRD, or whether maintenance stays entirely upstream). CTAM-owned reference-data tables (FR6 tier (b)) get a maintenance surface either way.
  - Users & Roles admin: search, role edits, jurisdiction + Region/Area scope edits, activation toggle (UI surface of FR4 + FR57)
  - Notification utilities: "Send Test Email" + delivery-log viewer
- **Admin-write API endpoints** ship alongside the admin UI: on `ctam-authorisation` — `PUT /v1/admin/users/{id}/{roles|jurisdictions|region-scopes|activation}`. *(`ctam-reference-data` admin-write endpoints retracted under D11 — the upstream-sourced tier is read-only; the CTAM-owned tier (b) may get write endpoints depending on the D11 follow-up decision.)*
- **Wave-by-wave rollout — Courts cohort**: Phase 10..N — Courts jurisdictions (Civil, Crime, Family, Crown) migrate per-region, wave by wave, until all Courts judicial regions are on CTAM Pathfinder and APEX is retired.
- **Structured user-action auditing** (D7 roadmap commitment) — who did what, when, with before/after values for write operations.
- **Full observability** — metrics + traces + dashboards beyond the log-based MVP minimum.
- **External API consumer onboarding** — DA&I migrates from export-based MI to API-based MI Feed; future programmes (Actuals, Scheduling & Listing) onboard onto CTAM Pathfinder's APIs. *(Tribunals is wave 1 itself[^d11], not a future programme to onboard.)*
- **Historical-data access policy** at cutover — read-only incumbent-system bridge (`[ET-INCUMBENT-TBD]` for ET / ListAssist for SSCS / APEX for Courts), or one-shot export, or policy-of-no-access (Risk #2).
- **Cross-region workflow handling** matures from per-wave manual coordination (Risk #1) to system-supported flows (Courts cohort waves 3+).

### Vision (Future)

- **Strategic integration platform** for HMCTS judicial scheduling — all current judicial jurisdictions on a single API-driven foundation (Tribunals/ET served in wave 1[^d13]; Tribunals/SSCS in wave 2; Courts/Civil, Courts/Crime, Courts/Family, Courts/Crown in waves 3+). Future jurisdictions (other Tribunals types, Magistrates) extend the same model when the programme expands.
- **Real-time data flow** to downstream systems (DA&I, finance, performance teams) — potentially via event streams or webhooks if integration patterns demand it (architecturally deferred today[^d12]; revisitable when justified).
- **Active matching / allocation** capability beyond today's filter-as-hint approach — *external to CTAM[^d12]* (CTAM exposes JOH availability/traits; case-management or listing systems perform the matching).
- **Automated reconciliation feed** from JFEPS to CTAM Pathfinder, replacing today's manual flag-as-reconciled step.
- **Bi-temporal / audit-grade compliance trail** if regulatory scope demands it (today out of scope; revisitable).

## User Journeys

### Journey 1 — ET scheduling admin: managing JOH availability for Employment Tribunal cover (wave 1 — ET jurisdiction)

> **⚠ PROVISIONAL — structural placeholder.** The service chain below (absence → vacancy → booking → sitting → payment) is **settled** and jurisdiction-agnostic; it is the same chain Journey 2 exercises for Courts. Every **ET-specific detail** — persona, role titles, JOH types, the out-of-system advertising process, venue and session vocabulary — is **unconfirmed pending the ET as-is analysis pack (gap G8.5)**, and the incumbent comparison is blocked on **G8.4**. Do not treat the ET specifics below as researched: complete this journey when the pack lands.

**Persona:** an ET scheduling/listing admin (exact role title TBC — G8.5). They record absences and ensure Employment Judges and non-legal ("lay") members are scheduled to cover Employment Tribunal sittings. (CTAM tells them who is available; the external case-management system tells them what cover is needed — CTAM does not manage hearings[^d12].)

**Trigger:** a JOH files an absence for the week of date X. The external ET case-management system (system TBC — G8.5) has flagged scheduled hearings needing cover that week.

**Steps:**

1. The absence appears on the admin's "Outstanding Actions" tile on the Home dashboard.
2. They open the absence. CTAM displays the JOH's profile (sourced from `jo_people` per FR11), appointment type (sourced from `jo_appointments`), Specialisations (sourced from MRD), tickets/authorisations (tier-(a) `jo_tickets` + CTAM-overlay per FR15), and the dates of absence.
3. They approve the absence. CTAM auto-creates a vacancy (FR23) pre-populated with JOH type, jurisdiction (ET), date range.
4. They advertise the vacancy out-of-system (**the ET process is TBC — G8.5**; CTAM's availability view per FR18 + FR27 helps them shortlist).
5. Another eligible JOH confirms availability.
6. They create a booking in CTAM (FR29) — JOH, jurisdiction = ET, tribunal venue, date range, session type. The vacancy is marked filled (FR30).
7. CTAM emails the JOH a booking acknowledgement (FR32).
8. After the hearings happen (managed externally[^d12]), they confirm the sitting (FR37) in CTAM, recording whether the JOH actually sat.
9. The payment batch generates a JFEPS schedule (FR42) for the confirmed sitting. **JFEPS applicability to ET is unverified — gap G8.6.**
10. The external case-management system reads the booking via CTAM's API and updates its own case-to-JOH allocation records.

**Outcome:** the cover cycle completes in fewer clicks than the ET incumbent (comparison blocked on G8.4). JOH availability and bookings are recorded in CTAM; the ET case-management system stays informed via APIs.

#### Wave-2 variant — SSCS Tribunal Caseworker panel coverage

*Preserved from the SSCS-first framing (D11) and re-sequenced to wave 2 by D13[^d13]. This variant is **researched and settled**, unlike the ET journey above.*

**Persona:** Asha, Tribunal Caseworker in an SSCS regional centre. Asha records absences and ensures Medical Members, Disability-Qualified Members, and Tribunal Judges are scheduled to cover SSCS sittings.

**Trigger:** Dr. M, an SSCS Medical Member, files an absence for the week of date X. The external case-management system has flagged scheduled SSCS hearings that need a Medical Member that week.

The steps are the same chain as above, with SSCS specifics: the vacancy is pre-populated with JOH type (Medical Member) and jurisdiction (SSCS); Asha advertises out-of-system per the standard SSCS process (phoning available Medical Members); Dr. P, another Medical Member with the right Specialisations, confirms; the booking records a tribunal venue and session type.

**Outcome:** Asha completes the cover cycle in fewer clicks than ListAssist. JOH availability and bookings are recorded in CTAM; the SSCS case-management system (GAPS, retained) stays informed via APIs; JFEPS payment is unchanged from APEX.

### Journey 2 — RSU Admin: cover-creation through payment (waves 3+ — Courts canonical operational cycle)

**Persona:** Sam, RSU Admin in a regional office. Sam handles absences, vacancies, fee-paid allocations, booking confirmation, and reconciliation. (Payment-schedule generation is a scheduled batch — Sam confirms bookings/sittings, then reconciles after Liberata has paid; the batch generates and dispatches the JFEPS Excel in between.)

**Trigger:** A Court office logs an absence request for a salaried judge with cover required. The request appears in Sam's "Outstanding Actions" tile on the Home dashboard.

**Steps:**

1. Sam opens the absence from the dashboard tile. CTAM Pathfinder shows the judge's profile, dates, work-type and ticket fields, and an *Approve* action.
2. Sam approves. The system auto-creates a vacancy (R4) pre-populated with judge type, work type, ticket, and dates. Status: *Needs allocation*.
3. Sam advertises the vacancy out-of-system (same as APEX). A fee-paid judge replies.
4. Sam clicks *Create Booking*, picks the judge, fills the session details. The booking is created and the vacancy is marked filled in the same transaction (R5). An acknowledgement email is queued to the booked judge.
5. The Court confirms the sitting. Booking moves to *Confirmed* and becomes eligible for payment.
6. The payment batch runs on schedule, picks up confirmed bookings/sittings without payment records, generates the JFEPS Excel, and emails it to the Payment Authoriser. No user action.

**Outcome:** Sam completes the cycle in fewer clicks than APEX. JFEPS output lands at the same finance team.

### Journey 3 — Court user: daily sitting confirmation (waves 3+ — Courts)

**Persona:** Priya, Court user (Full Access) in a Crown Court office. Priya confirms yesterday's sittings — verifying they took place, recording actual work type, adjusting session duration. Confirmed sittings drive payment and MI.

**Trigger:** Priya logs in via SSO. Home shows a *Sittings awaiting confirmation* tile scoped to her office.

**Steps:**

1. Priya opens the sittings list, filtered to *yesterday, this office*.
2. For each sitting: confirm with one click; or open the row, change work-type (e.g. *Crime* → *Civil*, per functional-modules.md line 422), split AM/PM as needed.
3. For one fee-paid Recorder, the booking required confirmation rather than a sitting; same one-click flow in the Bookings list.
4. Priya finishes the day's confirmations in under five minutes.

**Outcome:** Yesterday's data is locked in for payment and MI before Priya's first coffee.

### Journey 4 — Judge: view itinerary and request absence (waves 3+ — Courts)

**Persona:** Justice Hawthorne, salaried Circuit Judge. Uses JI to see planned sittings and request absences (training, leave).

**Trigger:** Logs in via SSO on a tablet between hearings. The Judge Itinerary view loads scoped to their own profile (R2).

**Steps:**

1. Itinerary renders on tablet — accessible, responsive, performant.
2. Justice Hawthorne sees a clash with planned training next month, opens *Request Absence*.
3. Form: dates, type (training), notes. Submit.
4. Request routes to RSU for approval (functional-modules.md §4.5). Acknowledgement email sent via Notification.

**Outcome:** Request lands with RSU; the judge moves on to the next hearing.

### Journey 5 — DA&I analyst: consume MI Feed API instead of Excel exports (cohort-neutral; post-MVP)

**Persona:** Riya, DA&I analyst building monthly utilisation dashboards. Today she runs APEX reports, copy-pastes to Excel, transforms, then feeds her dashboard.

**Trigger:** Post-MVP, JI exposes the MI Feed API. Riya gets API credentials (her IdP principal, authorised by JI Authorisation) and writes a script.

**Steps:**

1. `GET /reporting/sittings` with region, judge type, date range. Returns aggregated JSON (no case-level data per REP-BR-NFR-03).
2. Replaces three APEX-export-and-transform steps.
3. Riya schedules the script nightly.
4. When the contract changes, the OpenAPI spec, versioned content-type, and `Deprecation`/`Sunset` headers tell Riya what changed and when.

**Outcome:** The export-and-transform manual chain is gone. Future programmes (Tribunals, Actuals) onboard onto the same APIs.

### Journey 6 — Edge case: cross-region fee-paid booking during partial rollout, Courts cohort (Risk #1)

**Persona:** Sam (from Journey 1) needs to book an off-circuit fee-paid judge. Judge's home region (B) is on CTAM Pathfinder; Sam's region (A) is still on APEX. Only applies during the rollout window.

**Trigger:** Sam needs to allocate a Region B fee-paid judge to a Region A vacancy.

**Steps:**

1. APEX (Region A) has the vacancy. CTAM Pathfinder (Region B) has the judge.
2. Per Risk #1 mitigation, the workflow falls back to manual coordination: Sam phones Region B's RSU; Sam records the booking in APEX with a manual reference to the Region B judge identifier.
3. APEX processes the booking. Region B's RSU records the booking in CTAM Pathfinder out-of-band.
4. When Region A migrates, the workflow disappears — both sides on CTAM Pathfinder.

**Outcome:** Cross-region operations continue with documented manual handling for the rollout window only. Risk #1 is operationally managed, not architecturally solved.

### Journey Requirements Summary

The six journeys reveal these capability areas (mapped to the 11-service decomposition):

| Capability area | Services / decisions involved |
|---|---|
| Authentication via SSO + Authorisation gating per role + Region/Area | Authorisation (cross-cutting); D9 (users + roles migrated) |
| Absence approval workflow → automatic Vacancy creation | Absence (domain), Vacancy (domain); R4 |
| Booking with `Vacancy.markFilled` orchestration | Booking (domain), Vacancy (domain); R5 |
| Sitting / Booking confirmation by Court users | Sitting (domain), Booking (domain) |
| Payment schedule generation in JFEPS-compatible Excel | Payment (domain) with versioned content-type |
| Booking acknowledgement and absence acknowledgement emails | Notification (cross-cutting) |
| Modern UI with accessibility, responsiveness, performance | UX-override[^d4] |
| Itinerary view scoped to own profile (Judges) | Itinerary (read model); Strategy A federation |
| Aggregated, case-level-stripped MI Feed API for DA&I | MI Feed (read model); REP-BR-NFR-03 |
| API-as-Product standards (versioning, OpenAPI spec, deprecation policy via `Deprecation` + `Sunset` headers) | All services per Phase 0[^d1] |
| Per-wave cross-boundary manual coordination | Programme management (not application capability); Risk #1 |

## Domain-Specific Requirements

### Compliance & Regulatory (UK govtech)

- **Accessibility — WCAG 2.2 Level AA**, required by the Public Sector Bodies (Websites and Mobile Applications) Accessibility Regulations 2018. Every domain phase delivers UI[^d4]; each phase's UI must be tested for WCAG 2.2 AA before cutover. APEX-era baseline is preserved at minimum; modern UI on new technology (per the user-experience uplift in the vision) targets a measurable improvement.
- **GDS Service Standard alignment** — HMCTS internal systems reference the GDS Service Standard as the bar for digital service quality. Full GDS service assessments are not always required for internal-only systems, but the principles (user research, accessibility, performance, security, simple-as-possible) apply.
- **UK GDPR and Data Protection Act 2018** — personal data scope is limited to user/judge identity, contact details, payroll numbers, and operational metadata. **CTAM Pathfinder does not hold case-level data** (REP-BR-NFR-03 from `functional-modules.md`); this remains a binding constraint.
- **HMCTS / MoJ Government Functional Standard 7 — Security** — protective marking, access control, secure development practices. Implementation aligns with HMCTS-approved technology stack and security frameworks.
- **MoJ authentication policy** — under SSO (per locked Authorisation decision), authentication policy is owned by the HMCTS IdP, not JI. JI's Admin module's password-change capability disappears (D9 + the noted absorption of the Admin module under SSO).
- **Freedom of Information Act 2000** — JI's aggregate sitting / utilisation data is FOI-exposable; the MI Feed API is aggregate-only by contract (REP-BR-NFR-03). Case-level data is forbidden by contract; this protects against FOI scope creep into individual hearings.
- **Government / HMCTS retention schedules** — data retention is determined by HMCTS policy. Note: migrated transactional history stays in APEX[^d3]; new transactional data starts fresh on CTAM Pathfinder. Retention obligations therefore span both systems during the rollout window.

### Technical Constraints

- **Encryption in transit** — latest TLS only (per programme-level security guidance and the standing rule on latest SSL/TLS versions). HTTP-only endpoints rejected.
- **Encryption at rest** — for personal data (judge records, user/role records, working patterns, payroll numbers).
- **No bank details exposure** (PAY-NFR-05) — JI never stores bank details; the finance system retains them. This is a hard architectural constraint, carried from APEX.
- **No case-level data exposure** (REP-BR-NFR-03) — Reports and MI Feed are aggregate-only. Case-level identifiers are not part of the JI data model.
- **Audit minimum (MVP)** — log-based[^d7]. Structured user-action audit (who did what, when, with before/after values) is a post-MVP roadmap commitment, not an MVP capability.
- **AuthN delegated to HMCTS IdP via SSO**; **AuthZ owned by CTAM Pathfinder's Authorisation service** per architectural decision. User records and role/scope mappings are **bootstrapped per the restructured D9** (by mechanisms outside this PRD's scope), keyed to the IdP principal — **there is no APEX migration**[^d9][^d3]. **HMCTS IdP password policy, session policy, and account lifecycle are wholly external to CTAM Pathfinder** — owned by central HMCTS org; CTAM Pathfinder inherits whatever the IdP enforces and does not duplicate or constrain it.
- **Performance NFRs** carried from APEX page-level baselines (≤ 5 s dashboard, ≤ 10 s list/filter, ≤ 15 s batch/annual, ≤ 30 s reports/Forward Look) — already enumerated in Success Criteria.
- **No JI involvement in payment processing** — JI generates the JFEPS-shaped Excel and emails it to a Payment Authoriser; the authoriser forwards to Liberata out-of-system. JI is not in the payment chain itself, only the schedule-generation chain.

### Technology Stack (locked)

- **API layer:** Java 25 (current LTS) with Spring Boot 4.
- **Runtime / orchestration:** Kubernetes — containerised deployment for every domain and cross-cutting service.
- **Cloud platform:** Microsoft Azure — all services deployed on the Azure platform. Production runs in Azure UK South; data residency is restricted to Azure UK regions per NFR31. Azure-native service choices (e.g. AKS, Azure Container Registry, Azure Key Vault, Azure Application Insights, Azure database services) are implementation decisions in the architecture phase.
- **UI stack:** modern UI[^d4]; specific framework family is an implementation decision in the architecture phase, not locked here.
- **Implications worth carrying forward:**
  - Spring Boot 4 + Java 25 fits REST-first synchronous coordination. The HTTP client, JSON content-type negotiation, and OpenAPI tooling are all standard.
  - Spring Actuator endpoints serve build/version metadata (`/actuator/info`, populated by `gradle-git-properties`) and Kubernetes liveness/readiness probes (`/actuator/health`, `/actuator/readiness`); the `/actuator/*` namespace is ops-restricted at the APIM layer. The OpenAPI spec (Swagger Core, published by Gradle via the `maven-publish` plugin as a Maven-format artefact) is the consumer-facing contract.
  - Kubernetes orchestration on Azure enables the per-region phased rollout[^d8] — region-scoped deployments, rolling updates, isolated rollbacks per wave.
  - Azure UK regions support UK GDPR and HMCTS data-sovereignty requirements (data residency in-country); avoids the need for Standard Contractual Clauses or transfer impact assessments that would apply if data left the UK.
  - Azure-native logging (Application Insights / Log Analytics) is a natural fit for the log-based audit / observability minimum[^d7]; structured logging conventions defined in Phase 0 should target Azure-native ingestion.

### Integration Requirements

| Integration | Direction | Phase | Mechanism | Notes |
|---|---|---|---|---|
| **HMCTS IdP (SSO)** | Inbound (AuthN) | Phase 0 | OIDC / SAML (per HMCTS standard) | Hard dependency; must be live in Phase 0 for any user-facing demo. Risk #6 in 1600 brainstorming. |
| **JOH eLinks API** *(MVP scope[^d11])* | Inbound (reference data) | Phase 0 | REST API (sync mechanism TBD architecture) | Canonical source for judicial-holder data — 15 `jo_*` entities listed in the revised D3. NFR24 reframed for MVP inclusion. |
| **MRD (Master Reference Data)** *(MVP scope[^d11])* | Inbound (reference data) | Phase 0 | Weekly Excel feed (transitional, until MRD APIs ship) | Supplementary attributes not in JOH eLinks — notably JOH Specialisations. See revised D3. |
| **JFEPS / Liberata** | Outbound (payment) | Phase 6 | JFEPS-compatible Excel via HMCTS email, forwarded by Payment Authoriser | **Unchanged from APEX** — same format, same mechanism, same human-in-the-loop. Verified for SSCS[^d11] (wave 2); **ET wave-1 applicability unverified — G8.6**[^d13]. |
| **HMCTS Email infrastructure** | Outbound (notifications) | Phase 0 / used Phase 1+ | SMTP via HMCTS email | Booking ack, absence ack, payment schedule. Required dependency. |
| **DA&I (MI Feed)** | Outbound (data) | Phase 8 | MI Feed REST API (Strategy A pull-based federation) | Replaces export-by-email; aggregate-only contract per REP-BR-NFR-03. |
| **External case-management systems** (ET case management — system TBC per G8.5; SSCS: GAPS; Courts Listing systems)[^d12] | Outbound (APIs) | From Phase 9 (wave 1 onward) | REST APIs from CTAM | CTAM exposes JOH availability + booking data for external case-management consumption. No reverse-write into CTAM (CTAM is the system of record for JOH scheduling). |
| **Future programmes** (Actuals, Scheduling & Listing reforms) | Outbound (APIs) | Post-MVP | REST APIs from CTAM | Vision-level; specific contract design happens when programme demand crystallises. (Tribunals removed from "future programmes" — ET is wave 1 and SSCS wave 2[^d13].) |

### Risk Mitigations (domain-specific)

- **Accessibility regression vs APEX.** APEX meets HMCTS accessibility commitments (HOME-NFR-04, MJ-NFR-05, etc.). CTAM Pathfinder must match or exceed. **Mitigation:** WCAG 2.2 AA testing per UI page in each domain phase; assistive-technology compatibility (keyboard navigation, ARIA labels for tabbed content) included in acceptance tests.
- **Data-protection regression.** APEX's constraints (no bank details, no case-level data) are binding for CTAM Pathfinder. **Mitigation:** these constraints are encoded as architectural rules — Payment service contract excludes bank fields; MI Feed and Reports schemas exclude case identifiers.
- **FOI exposure broadening.** A new API surface (MI Feed) creates new FOI questions about what data is published. **Mitigation:** MI Feed contract is aggregate-only and version-controlled; FOI scope is pre-determined by the contract, not by ad-hoc query capability.
- **Security clearance / vetting of implementation team.** Programme-management territory; not specified in this PRD. **Mitigation:** team members handling judicial / personal data work under HMCTS standard clearance levels.
- **HMCTS IdP integration timing.** SSO must be live in Phase 0; if HMCTS IdP integration slips, the MVP rollout is blocked. **Mitigation:** mock-IdP fallback for internal demo during Phase 0, contingency to wire to a different HMCTS-approved IdP if needed (carried from Risk #6 in 1600 brainstorming).
- **Reference Data + Users/Roles migration correctness** (D3 + D9 + Risk #13 + Risk #14) — already in the Risk register; restated here as a domain-specific concern because incorrect role assignments are a governance and access-control issue, not just a technical bug.

## API Backend Specific Requirements

### Project-Type Overview

CTAM Pathfinder is composed of 11 services in three clusters (revised v2.2 — `ctam-configuration` dropped; cross-service policy values live in a shared `ctam_configuration_values` table):

- **Domain services:** JOH (`ctam-joh`[^d11]), Absence, Vacancy, Booking, Sitting, Payment.
- **Cross-cutting services:** Reference Data, Authorisation, Notification. (Configuration is not a service — per-service Spring profiles + Key Vault, with a shared `ctam_configuration_values` table for cross-service policy values.)
- **Read-model services (federated):** Itinerary, MI Feed.

Every service is API-first with a versioned contract. Services are callable by the UI[^d4] and external consumers (DA&I, future programmes).

### Technical Architecture Considerations

- **Coordination:** REST-first synchronous. Services call each other directly (e.g. Booking → `Vacancy.markFilled`). No event stream, message bus, or webhook fabric.
- **Read-model federation:** Strategy A — fan-out at request time. Itinerary and MI Feed hold no data of their own. Strategy C (cached projection) is the designed fallback if Forward Look misses ≤ 30 s NFR (Risk #9).
- **Service-to-service auth:** internal calls use service-token / mTLS (specifics in architecture phase); external calls use the same SSO/IdP-derived principal as user calls.
- **Idempotency:** retryable writes (e.g. `POST /bookings`, `POST /payments/process`) accept an idempotency key. Mechanism in architecture phase.

### Endpoint Specifications

Endpoint shape is illustrative — definitive contracts are produced as Phase 0 paper artefacts[^d1] and in each domain phase as the service is built.

**Cross-cutting services (Phase 0):**

| Service | Representative endpoints |
|---|---|
| Reference Data | `GET /reference-data/regions`, `/offices`, `/judicial-vocabularies`, `/calendar` (read-only over both tiers, jurisdiction-filtered[^d8]); **no write endpoints in MVP** — tier (a) is corrected at source[^d11], tier (b) is DBA-via-SQL[^d10] |
| Authorisation | `POST /authz/check`, `GET /users/{id}/effective-permissions` |
| Configuration | Per-service: Spring profiles + `application.yml` + Azure Key Vault. Cross-service policy values: shared `ctam_configuration_values` table (read-only via direct SQL; no API). |
| Notification | `POST /notifications/send` (transactional emails: booking ack, absence ack, payment schedule) |

**Domain services (Phases 1–6):**

| Service | Representative endpoints |
|---|---|
| JOH (`ctam-joh`) | `GET /johs`, `GET /johs/{johId}` *(person record read-only, composed from `jo_people` via the CTAM JOH id; `?personnelNumber=` filter available)*, `POST /johs/{johId}/working-patterns`, `POST /johs/{johId}/tickets` *(CTAM-owned overlays)* |
| Absence | `POST/GET /absences`, `POST /absences/{id}/approve`, `POST /absences/{id}/extend` *(sickness only)* |
| Vacancy | `POST/GET /vacancies`, `POST /vacancies/{id}/markFilled` *(called by Booking, R5)*, `POST /vacancies/{id}/cancel` |
| Booking | `POST /bookings` *(accepts optional `vacancyId` and orchestrates `Vacancy.markFilled`)*, `POST /bookings/{id}/confirm`, `POST /bookings/{id}/cancel` |
| Sitting | `POST/GET /sittings`, `POST /sittings/{id}/confirm`, `POST /sittings/{id}/verify`, `POST /sittings/{id}/split` *(AM/PM)* |
| Payment | `POST /payments/process` *(eligible bookings → schedule)*, `GET /payments/{id}/schedule` *(content-type negotiated)*, `POST /payments/{id}/reconcile` |

**Read-model services (Phases 7–8):**

| Service | Representative endpoints |
|---|---|
| Itinerary | `GET /itineraries/courts/{officeId}` *(monthly / annual)*, `GET /itineraries/judges/{judgeId}`, `GET /itineraries/forward-look` |
| MI Feed | `GET /reporting/sittings`, `GET /reporting/utilisation`, `GET /reporting/vacancies`, `GET /reporting/bookings` *(all aggregate-only per REP-BR-NFR-03)* |

### Authentication Model

- **End-user authentication: HMCTS IdP via SSO** (OIDC or SAML — exact mechanism is HMCTS-IdP-side; CTAM Pathfinder integrates with whichever the IdP exposes).
- **End-user authorisation: CTAM Pathfinder's Authorisation service.** Per the restructured D9, CTAM Pathfinder serves two distinct user populations identified through different lookup paths: (a) **JOH users** — IdP email looked up against `jo_people` to resolve the personal number (the canonical CTAM identifier for JOHs); (b) **HMCTS admin staff** — a CTAM-internal staff identity table (not present in JOH eLinks data). Both populations share the same authorisation model. Every domain call resolves the principal's roles + **jurisdiction** + Region/Area scope via Authorisation before authorising the action.
- **HMCTS IdP password / session / account lifecycle policies are wholly external to CTAM Pathfinder** (per Step 5 Technical Constraints) — CTAM Pathfinder inherits whatever the IdP enforces.
- **Service-to-service authentication:** TBD in architecture phase; mTLS or service-token is the typical fit for the chosen Java/Spring/Kubernetes stack.
- **External consumer authentication** (DA&I MI Feed, future programmes): same IdP principal model where possible; service principals or API keys are an architecture-phase fallback if the IdP doesn't issue principals for non-human consumers.

### Data Schemas

Canonical representation: **JSON** for all REST endpoints. Specific resource schemas (Judge, Absence, Vacancy, Booking, Sitting, Payment, Itinerary, Reporting feed) are produced as Phase 0 paper contracts[^d1] and refined per phase.

**Versioned content-types** for shape-sensitive resources:

- `GET /payments/{id}/schedule` accepts `application/vnd.hmcts.jfeps+json` (canonical JI shape) or `application/vnd.hmcts.jfeps+xlsx` (format-shifted JFEPS Excel for Liberata workflow). The JFEPS shape evolves independently of Payment internals.
- Other resources may grow versioned content-types over time as integration partners require shape-stability.

**Forbidden fields by contract:**

- Bank details (PAY-NFR-05) — not in any Payment resource shape.
- Case-level identifiers (REP-BR-NFR-03) — not in Reports or MI Feed shapes.

### Error Codes

- **HTTP status codes** semantically — 200/201 for success, 400 for validation errors, 401/403 for auth, 404 for not-found, 409 for conflict (e.g. double-booking attempts blocked by FPB-NFR-04), 422 for semantically valid but business-rule-rejected, 5xx for server-side faults.
- **[RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) Problem Details for HTTP APIs** as the standard error envelope — `type`, `title`, `status`, `detail`, `instance`, plus problem-specific extension fields where useful. (RFC 9457 obsoleted [RFC 7807](https://datatracker.ietf.org/doc/html/rfc7807) in July 2023; the `application/problem+json` content type and field shape are unchanged.)
- Architecture-phase decision: define the specific problem `type` URIs for the cross-cutting categories (validation failure, authorisation failure, business-rule rejection, dependency failure, etc.).

### Rate Limits

**TBD — architecture-phase decision.** For internal HMCTS systems with a bounded user population, rate limits are typically low priority for human traffic; the relevant cases (per-service-principal limits for MI Feed, burst protection against runaway scripts) will be specified in the architecture phase.

### API Versioning

- **Versioning policy is a Phase 0 deliverable** as part of API-as-Product standards[^d1].
- Working assumption (architecture-phase confirmable): versioning via the URI path prefix (e.g. `/v1/judges`, `/v2/judges`) for major versions; backwards-compatible additions within a major version don't require a new path.
- **Deprecation policy** is part of the same Phase 0 artefact: deprecated endpoints emit `Deprecation` ([RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745)) and `Sunset` ([RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594)) response headers, are documented, and are retired no sooner than N months after first deprecation notice (specific N TBD).
- **Consumer contract surface** is the published OpenAPI spec (Maven-format artefact published by Gradle `maven-publish`; Swagger UI for browsing). Build/version metadata is exposed via Spring Actuator `/actuator/info` (ops-restricted).

### Client Tooling

- **API testing during build: Postman.** Postman collections are the primary client for validating APIs end-to-end as each service is built, ahead of the UI layer being wired in. Each phase produces a Postman collection that exercises the phase's endpoints against running services in the deployment platform.
- **UI layer client:** TBD in architecture phase. UI stack itself is not locked (per Step 5 Technology Stack — UI framework is an architecture-phase decision); specific UI-client tooling (e.g. generated TypeScript client from OpenAPI) follows from that decision.
- **External consumer clients** (DA&I, future programmes): direct REST calls in their native stack are sufficient; no formal SDK is required for MVP.

### API Documentation

- **OpenAPI 3.x specifications** generated from each service's code (Spring Boot has standard OpenAPI tooling).
- **Lifecycle metadata** is conveyed via the OpenAPI spec (`info.version`, `paths.{path}.{method}.deprecated`) plus per-response `Deprecation` ([RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745)) and `Sunset` ([RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594)) headers.
- **Documentation hosting:** Swagger UI per service for developer onboarding, plus a published consolidated API catalog (architecture-phase decision on hosting / branding).
- **Postman collections** per phase serve double duty as test artefacts and as practical, executable API documentation for stakeholders ahead of UI demos.

### Implementation Considerations

- **Stack:** Java 25 + Spring Boot 4 + Kubernetes on Azure. Spring Web for REST endpoints, Spring Security for AuthZ, Spring Actuator for build/version metadata and liveness/readiness probes (`/actuator/info`, `/actuator/health`, `/actuator/readiness`; ops-restricted at APIM), springdoc-openapi for OpenAPI generation, Azure API Management for rate limits, header injection, and deprecation/`Sunset` policies.
- **Per-service deployment unit:** each of the 11 services is a containerised Spring Boot app on Kubernetes. Per-region rollout[^d8] uses region-scoped namespaces or service-instance-level region targeting (architecture-phase choice).
- **Phase 0 as standards validation:** Reference Data exercises every API-as-Product standard (versioning, content-type negotiation, OpenAPI spec, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) errors, deprecation signalling) before any domain service is built.

## Project Scoping & Phased Development

Extends Product Scope with MVP philosophy, phase-by-phase journey mapping, and risk-based scoping.

### MVP Strategy

The MVP is "enough for one region — every applicable role, every operational workflow — to move off APEX and stay off it." For a greenfield rebuild of an unsupported system, the MVP cannot be smaller; less than this means no region can migrate[^d2][^d8].

**Resource requirements:** TBD (programme-management territory). Two viable structures:

- **Variant α** (single squad, sequential): Phase 0 → Judge → Absence → Vacancy → Booking → Sitting → Payment → Itinerary → MI Feed → wave 1. Lower coordination overhead; longer calendar.
- **Variant β** (multi-squad, Sitting parallel from Phase 2): same dependency order; Sitting is co-developed with Booking. Shorter calendar; needs 2+ squads.

Default is α; β is a capacity-conditional upgrade.

### Phase-by-Phase Journey Mapping

Mapping the **6 user journeys** (Step 4) to the **build phases** (from the brainstorming session migration table). A journey becomes *demoable* at the end of the phase that completes its last dependency. The wave-1 ET journey (Journey 1) and the waves-3+ Courts canonical journey (Journey 2) both demo at Phase 6 — they cover the same operational chain in different jurisdictions.[^d13]

| Journey | Demoable at end of | Dependency |
|---|---|---|
| Journey 1 — ET cover coverage (wave 1; SSCS variant at wave 2) | Phase 6 (Payment) | Full operational chain JOH → Absence → Vacancy → Booking → Sitting → Payment must be live |
| Journey 2 — RSU cover-creation through payment, Courts canonical cycle (waves 3+) | Phase 6 (Payment) | Full operational chain JOH → Absence → Vacancy → Booking → Sitting → Payment must be live |
| Journey 3 — Court daily sitting confirmation (waves 3+) | Phase 5 (Sitting) | Sitting + Authorisation; Phase 5 ends with confirmation flow live |
| Journey 4 — Judge views itinerary (waves 3+) | Phase 7 (Itinerary) | Federates over JOH + Absence + Vacancy + Booking + Sitting |
| Journey 5 — DA&I MI Feed API consumer (cohort-neutral; post-MVP) | Phase 8 (MI Feed) | MI Feed federates over all domain services including Payment |
| Journey 6 — Cross-region edge case during partial rollout, Courts (Risk #1) | Phase 9+ (rollout window only) | Only relevant once at least one Courts region has migrated; resolves once last Courts region migrates |

**Stakeholder communication:** the canonical operational demos (Journey 1 ET / Journey 2 Courts) are available at Phase 6. Phases 1–5 produce per-module demos against partial chains (e.g. Phase 1 demos JOH management; Phase 4 demos vacancy → booking but not confirmation → payment).

### Risk-Based Scoping

The 1600 brainstorming risk register applies. Scoping-level risks:

**Technical:**

- Strategy A read-model federation may miss ≤ 30 s Forward Look NFR (Risk #9). Strategy C cache fallback is designed and switched on if Phase 7 measurement shows the breach.
- Reference Data + Users/Roles migration correctness (Risk #13). Phase 0 includes named-owner sign-off as a deliverable.
- APEX ⇄ IdP identity mapping (Risk #14). Phase 0 produces a reconciliation report with explicit handling rules for unmatched records.

**Programme:**

- The strategic-platform vision (external HMCTS programme integrating via API by post-MVP) is aspirational. MVP ships with the API surface in place; external consumer onboarding is post-MVP.
- Cross-region workflow during partial rollout (Risk #1). Manual coordination per wave is a programme-management deliverable, not an application feature. Application stays simple.

**Resource:**

- Variant β is capacity-conditional. If capacity is constrained, α delivers the same MVP content on a longer calendar.
- HMCTS IdP integration timing (Risk #6). Mock-IdP for internal demos during Phase 0; contingency to wire to a different HMCTS-approved IdP if needed.

### Scope Confirmation

No requirement from the brainstorming session, the as-is docs, or D1–D9 has been de-scoped here. The MVP / Growth / Vision split is unchanged from Step 3. This step adds framing only.

## Functional Requirements

This section is the binding capability contract for CTAM Pathfinder. UX, architecture, and epic breakdown will all trace back to these requirements. A capability not listed here will not exist in the final product unless explicitly added.

### Identity & Authorisation

- **FR1**[^d11][^d9]: Authenticated users access CTAM Pathfinder via HMCTS IdP single sign-on; password, session, and account lifecycle are owned by the IdP and not duplicated in CTAM Pathfinder. At authentication time, the IdP email is resolved to CTAM Pathfinder's canonical identifier — the **personal number** (for JOH users, looked up against `jo_people`) or a CTAM-internal staff identifier (for admin-staff users)[^d9].
- **FR2**[^d8][^d11]: CTAM Pathfinder's Authorisation service maps each authenticated principal to one or more roles, a **jurisdiction**, and a Region/Area scope, and authorises every system call against that mapping.
- **FR3**: Authorised users can retrieve their effective permissions for their authenticated session.
- **FR4**[^d10][^d11]: System administrators can update role, jurisdiction, and Region/Area assignments for any user. **In MVP, the data layer is editable by DBAs via direct SQL on the auth tables** (populated by mechanisms outside the PRD's scope per the superseded D9); **the admin UI surface is post-MVP** (`ctam-admin-ui` Users & Roles module — see Growth Features). FR4's MVP success criterion is "an authorised DBA can update role / jurisdiction / scope per the operational runbook"; the system-administrator role-with-UI surface ships post-MVP.
- **FR5** *(reframed v2.5, 2026-05-07 as post-MVP)*: External machine-to-machine consumers (e.g. DA&I post-MVP MI Feed) require an authentication mechanism. **At MVP, no machine-to-machine consumers are in scope** — every CTAM Pathfinder runtime request is user-initiated, including planned DA&I integration (DA&I would authenticate as a human-equivalent identity at HMCTS IdP if onboarded post-MVP). The mechanism for genuine service-principal authentication (for non-user-initiated flows) is **a post-MVP open question** — see architecture changelog v2.5 and `architecture/gaps.md` G7. Options to be evaluated when the requirement arrives include an CTAM Pathfinder-internal service-auth issuer, Azure Workload Identity, mTLS, and (if HMCTS IdP supports it) `client_credentials` against HMCTS IdP.

### Foundational Data Management

- **FR6**[^d10][^d11]: RSU users can **view** Reference Data lists through `ctam-reference-data`'s versioned read API. Reference Data in CTAM Pathfinder has two ownership tiers, held in **separate tables** to preserve data lineage:<p/>**(a) Upstream-sourced (read-only in CTAM)** — JOH eLinks API entities and MRD entities[^d3]. Refreshed regularly from source; never hand-edited within CTAM. Corrections happen at source (Judicial Office for JOH-related entities; the MRD team for MRD entities). **No data flows upstream from CTAM to JOH or MRD.** CTAM Pathfinder does not provide a write surface for this tier.<p/>**(b) CTAM-owned** — data that CTAM Pathfinder needs that does not exist upstream, plus operational state that CTAM Pathfinder maintains over upstream entities (e.g. JOH location changes are not captured by JOH eLinks; CTAM records them as CTAM-owned operational state). Manually managed by admin staff; never overwritten by upstream sync. **In MVP**: CTAM-owned reference data is editable by DBAs via direct SQL per operational runbooks (admin UI deferred[^d10]). **Post-MVP**: RSU-facing maintenance UI in `ctam-admin-ui` for this tier (see Growth Features) — the previous "write endpoints on `ctam-reference-data` + in-UI sign-off workflow" plan applies to CTAM-owned data only.<p/>The application decides which tier to consult per use case; `ctam-reference-data`'s API exposes both as appropriate but does not blend their lineage.
- **FR7**[^d11]: Every CTAM Pathfinder service reads Reference Data via **direct SQL** on the shared schema's Reference Data tables — SELECT-granted to each service's DB role per architecture Principle 2 (no client class, no API fan-out, no cache). Reference Data spans both ownership tiers (per FR6) in **separate tables**: upstream-sourced tables (~15 JOH-eLinks entities + MRD entities) and CTAM-owned tables. **Writes follow the tier**: upstream-sourced tables are written exclusively by the upstream-ingestion mechanism (JOH eLinks sync + MRD weekly Excel feed[^d3]); CTAM-owned tables are written by DBAs via direct SQL in MVP (admin UI deferred[^d10]) and by the admin UI post-MVP. `ctam-reference-data` is the **single owner** of all reference-data tables in the shared schema; no domain service holds duplicate or cached copies in its own tables.
- **FR8** *(revised v2.2, 2026-05-07)*: Cross-service runtime policy values (e.g. session timeout warnings, batch schedules, feature flags) are stored in a shared `ctam_configuration_values` infrastructure table, schema-managed by `ctam-architecture`'s Liquibase baseline changelog and SELECT-granted to every CTAM Pathfinder service DB role. Updates are made via Liquibase changesets or direct admin SQL — no API service. Per-service configuration scoped to a single service uses Spring profiles + `application.yml` + Azure Key Vault.
- **FR9**: CTAM Pathfinder dispatches transactional emails (booking acknowledgements, absence acknowledgements, payment schedules) via HMCTS email infrastructure, with a delivery log retained.

### JOH Records & Working Patterns

- **FR10** *(reworded 2026-06-10[^d11])*: RSU users can search and filter **JOHs** by name, base location, location type, and JOH type.
- **FR11** *(reworded 2026-06-10[^d11])*: RSU users can **view** JOH profiles through `ctam-reference-data`'s read API — personal details, JOH type, base office, active/inactive status, payroll number, retirement date, fee entitlement, London weighting, name-for-itinerary, heading, tickets, and tribunal-member Specialisations. Upstream-sourced fields (`jo_people`, `jo_appointments`, etc., plus MRD-sourced Specialisations) are tier (a) per FR6: read-only in CTAM, with corrections at source. CTAM-owned operational state and overlays (location per FR17, working patterns per FR12, tickets/authorisations overlay per FR15) are tier (b) per FR6: **held in separate tables keyed by `joh_id` → `ctam_joh_identities`**, maintained within CTAM by DBAs via SQL in MVP, by admin UI post-MVP[^d10].
- **FR12** *(reworded 2026-06-10[^d11])*: Authorised users can define and update Working Patterns (None / Daily / Weekly) for JOHs, with target sit %, jurisdictional split, and per-day work-type pattern. Working patterns are CTAM-owned operational state per FR6 tier (b).
- **FR13** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder auto-populates JOH itineraries up to the next 31st March from the working pattern, preserving any prior absences.
- **FR14**[^d11]: A JOH's salaried full-time / part-time status is sourced from JOH eLinks (`jo_contract_types`)[^d3] — CTAM Pathfinder displays the current status; conversions happen upstream and are reflected in CTAM at the next sync. The previous capability "RSU users can convert salaried judges between full-time and part-time in CTAM" is retracted; mandatory-sitting-days adjustments follow the upstream change automatically.
- **FR15** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder exposes ticket information per JOH role through `ctam-reference-data`'s read API, combining two data layers:<p/>(a) **Upstream-sourced tickets** from JOH eLinks `jo_tickets` (tier (a) per FR6 — read-only in CTAM; corrections happen at source).<p/>(b) **CTAM-overlay tickets and other authorisations** layered on top of the upstream set, held in CTAM-owned tables keyed by `joh_id` → `ctam_joh_identities` (tier (b) per FR6). Admin staff can add/edit/remove overlay rows — DBAs via SQL in MVP; admin UI post-MVP[^d10].<p/>The application combines (a) and (b) per use case.
- **FR16**: CTAM Pathfinder validates that jurisdictional split percentages total 100% before saving.
- **FR17** *(reworded 2026-06-10[^d11])*: RSU users can switch a JOH's base location to another office within the same Region; cross-Region changes require OPT Advice Point and are out-of-system. Location changes are CTAM-owned operational state per FR6 tier (b); they are not propagated back to JOH eLinks.
- **FR18** *(reworded 2026-06-10[^d11])*: Authorised users can link to JOHs managed by other offices (off-circuit / cross-Region) for booking purposes (e.g. composing tribunal panels with members from other regions).

### Absence Workflow

- **FR19**: Authorised users (RSU, Court, Judges where permitted) can record absence requests with start/end date, partial-day option (full / AM / PM), type from a controlled list, and an NTBF flag.
- **FR20**: CTAM Pathfinder distinguishes auto-confirmed absences (from judicial teams) from those requiring confirmation (from Courts or judges); confirmation can trigger an acknowledgement email.
- **FR21**: Sickness absences can be extended without creating a new record; non-sickness extensions require a new absence record.
- **FR22**: Authorised users can mark absences as *Not To Be Filled* (NTBF) or as *needs fee-paid cover*.

### Vacancy & Cover

- **FR23** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder auto-creates a vacancy when an approved absence requires fee-paid cover, pre-populated with JOH type, work type, ticket, and dates.
- **FR24**: Authorised users can create standalone vacancies independent of any absence.
- **FR25**: Authorised users can edit a vacancy's daily breakdown — cancel individual days with a captured reason; extend or shorten the period.
- **FR26**: CTAM Pathfinder marks a vacancy as filled when a booking is created against it; vacancy days cannot be cancelled once a booking is recorded.
- **FR27** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder surfaces fee-paid JOHs matching a vacancy's filter as a hint for advertising; advertising itself is performed out-of-system by judicial teams.
- **FR28**: Authorised users can cancel or close vacancies (e.g. when a parent absence becomes NTBF).

### Booking Management

- **FR29** *(reworded 2026-06-10[^d11])*: Authorised users can create fee-paid bookings (linked to a vacancy or standalone), capturing **JOH**, **court / tribunal**, date, session type (full / AM / PM / evening / reserved-matter), booking type, and work type.
- **FR30**: Booking creation marks the linked vacancy as filled within the same transaction when a `vacancyId` is supplied. *(Implementation per architecture: in-process direct DB update on the `ctam_vacancies` row using a per-service DB role grant; see architecture Principle 1 for the rationale and the cross-service-write rules.)*
- **FR31**: CTAM Pathfinder tracks booking status (planned, provisional, confirmed, cancelled, rejected) with reason capture for cancellation.
- **FR32** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder sends booking acknowledgement emails to fee-paid **JOHs**, batched overnight or sent immediately via *Create and Email Now*.
- **FR33** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder requires a Y/N answer at booking time when a **JOH's** fee entitlement is *Ask when booking*.
- **FR34** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder prevents double-booking of fee-paid **JOHs** for overlapping sessions.

### Sitting Management

- **FR35** *(reworded 2026-06-10[^d11])*: CTAM Pathfinder generates planned sittings for **salaried JOHs** from their working patterns, **court / tribunal**, date, and work type.
- **FR36** *(reworded 2026-06-10[^d11])*: Authorised users can filter sitting records by Region/Office, **JOH type**, **JOH**, and date range.
- **FR37**: Authorised users can confirm that a sitting actually took place, updating outcome (confirmed, cancelled, rejected) and actual work type.
- **FR38**: Authorised users can split a sitting into AM/PM with different work types within a single day.
- **FR39** *(reworded 2026-06-10[^d11])*: Authorised users can create ad-hoc sittings for **salaried JOHs**, including DJ(MC)s and Legal Advisers in County Courts (Courts-cohort-specific examples).
- **FR40** *(revised 2026-05-11)*: Verifiers can verify confirmed sittings; once verified, the data is read-only. Amendments after verification require **re-opening** the sitting via a UI re-open action gated by a distinct authorised role — the re-opener must be different from the original confirmer (SIT-NFR-02) and from a standard Verifier (at MVP, the permission is granted to RSU Admin only). The action captures a mandatory justification field and is fully audited (who, when, why, which sittings). No external Request-for-Change ticketing process — re-open is a first-class UI action with RBAC controls.

### Payment & Reconciliation

- **FR41** *(revised v2.6, 2026-05-07)*: Authorised users can list confirmed bookings and salaried sittings, filterable by Region/Office, judge, date range, and payment lifecycle status (pending, requested, paid, reconciled). The **payment-eligible** subset is the read-only union of confirmed bookings + sittings whose payment record does not yet exist; this is the input the scheduled batch consumes.
- **FR42** *(revised v2.6)*: CTAM Pathfinder's **payment-processing batch** (`ctam-payment-batch`, scheduled on a configurable cron — typically end-of-week) automatically marks eligible bookings as *payment requested* and creates the corresponding `ctam_payments` + `ctam_payment_schedules` records. **No user click is required** — the batch identifies the eligible set via SQL JOIN over confirmed bookings + sittings without an existing payment record. Authorised users can also list and review the generated schedule before / after dispatch.
- **FR43** *(revised v2.6)*: The **payment batch** generates JFEPS-compatible payment schedules and dispatches them as Excel attachments to a configured Payment Authoriser via email (using its service-principal identity to call the Notification API); the Payment Authoriser forwards to Liberata out-of-system. Schedule generation and dispatch are batch-driven, not user-initiated.
- **FR44**: CTAM Pathfinder exposes the payment schedule via API with content-type negotiation (`application/vnd.hmcts.jfeps+json` or `+xlsx`); the JFEPS shape evolves independently of Payment internals.
- **FR45**: CTAM Pathfinder prevents double submission of the same booking for payment. The batch's natural-key unique constraint on `(payment_cycle_id, booking_id)` rejects duplicate creates; re-runs of the same cycle are idempotent.
- **FR46**: Authorised users (Finance, RSU) can flag payments as reconciled, capturing notes for mismatches; once fully reconciled, a payment cannot be re-requested for the same booking.
- **FR47**: CTAM Pathfinder does not store or expose bank details for any judge — those remain in the finance system.

### Itineraries & Reporting (Read Models)

- **FR48**: Authorised users can render the Court Itinerary (monthly or annual) for a given Office, Financial Year, and Month, showing sittings, bookings, vacancies, and NTBF absences for each day.
- **FR49**: Authorised users can render the Judge Itinerary for one or more judges over a date range, scoped by Authorisation (judges see only their own; courts see their office; RSU sees their region).
- **FR50**: Authorised users can use the Forward Look view across a Region with paged or filtered access for performance.
- **FR51**: Itinerary cells are clickable and drill into the underlying record (Sitting, Absence, Vacancy, or Booking).
- **FR52**: Authorised users can copy/export Itinerary and Report contents to Excel and PDF.
- **FR53**: CTAM Pathfinder provides a fixed catalogue of standard Reports (weekly sitting projections, weekly vacancies, absence analysis, vacancy by court, confirmed sittings/bookings by judge or judge type, judge utilisation, jurisdictional split, summary by court / work type) with parameter filters per report.
- **FR54**: CTAM Pathfinder exposes aggregated MI Feed APIs for external consumers (DA&I, future programmes); MI Feed responses contain no case-level data and are aggregate-only by contract.

### Platform Operations & Migration

- **FR55**: Authenticated users land on a Home page showing role-scoped navigation, Region/Area selector, summary tiles for the selected scope (judges, absences, vacancies, pending payments, payments made, unreconciled), and contextual help.
- **FR56**[^d10]: CTAM Pathfinder's **business-user UI** (`ctam-ui`) replicates the functional surface of the as-is APEX UI on a modern UI stack and meets WCAG 2.2 Level AA accessibility standards. **In MVP**: `ctam-ui` only — the business-user-facing SPA used by RSU, Court, Judges, Judges' Clerks, Finance/Payment Authoriser, MI/Reporting roles. **Post-MVP**: `ctam-admin-ui`, the admin-facing SPA carrying Reference Data maintenance, User/Role/Scope admin, Migration Reports, and Activation Flag toggle modules (see Growth Features).
- **FR57**[^d10][^d11]: CTAM Pathfinder supports **per-jurisdiction, per-region phased activation** — a user's account is activated for CTAM Pathfinder use only when their (jurisdiction, region) tuple's feature-parity gate is passed; activation is a flag flip on `ctam_auth_user_activation_flags`, not a data migration. **In MVP**: initial flag state is FALSE for every user record at the point of bootstrap (mechanism outside PRD[^d9]); cutover flips happen per wave by a DBA running `UPDATE ctam_auth_user_activation_flags SET activated = TRUE WHERE jurisdiction = '...' AND region = '...'` per the Phase 9+ rollout runbook (no UI). **Post-MVP**: activation toggle UI in `ctam-admin-ui` for system administrators (see Growth Features).
- **FR58**: Every CTAM Pathfinder service exposes a versioned API contract, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details for errors, and a published OpenAPI specification. Deprecation signalling uses the `Deprecation` header per [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) and the `Sunset` header per [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594).
- **FR59**: Every CTAM Pathfinder service emits structured logs with correlation IDs and consistent error categorisation, retained for pilot incident triage.
- **FR60**[^d11][^d5]: Every CTAM Pathfinder domain service has a **manual user acceptance test (UAT) script** that captures the workflows and edge cases a **jurisdiction-incumbent-experienced user** is expected to verify against that incumbent system before that wave's rollout. For wave 1 (ET): `[ET-INCUMBENT-TBD]`-experienced users — role set *provisional* pending G8.5, panel blocked on G8.4. For wave 2 (SSCS): ListAssist-experienced users — RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI. For waves 3+ (Courts): APEX-experienced users — RSU, Court, Judge, Judges' Clerks, Finance, MI. The UAT is performed by in-wave applicable users and recorded with explicit per-role sign-off. There is no automated incumbent-comparison test harness; incumbent-comparison parity is a manual UAT activity, not a CI gate.

## Non-Functional Requirements

### Performance

Page-level NFRs are carried from the APEX baseline (`functional-modules.md` cross-cutting NFRs); CTAM Pathfinder must match or exceed each. Each wave's cutover verifies these thresholds against that incumbent's equivalent operations as part of the cohort readiness assessment — **for ET wave 1, blocked on G8.4**[^d13].

- **NFR1 — Static page load:** ≤ 3 s for static UI loads (e.g. Home initial render).
- **NFR2 — Dashboard refresh:** ≤ 5 s when Region/Area selection changes.
- **NFR3 — List / filter operations:** ≤ 10 s for typical operational lists (judges, absences, vacancies, bookings, sittings, payments) at Region scope.
- **NFR4 — Batch / annual operations:** ≤ 15 s (e.g. annual itinerary render, batch payment-request processing).
- **NFR5 — Reports / Forward Look:** ≤ 30 s for standard report parameters and for the Forward Look view at Region scope.
- **NFR6 — Single-resource API read:** ≤ 500 ms p95 (e.g. `GET /judges/{id}`).
- **NFR7 — Domain write API:** ≤ 1 s p95 for typical write operations (excluding orchestrated cross-service calls like Booking → Vacancy.markFilled).
- **NFR8 — Federated read (Itinerary, Forward Look):** ≤ 30 s p95 under Strategy A. Strategy C cache fallback is pre-designed and switched on if measurement shows the p95 breached (Risk #9).
- **NFR9 — Capacity (rough order-of-magnitude):** concurrent users per region ~50–100; national concurrent users ~200–500 once all regions migrated. Burst capacity for monthly verification deadlines accounted for.

### Security

- **NFR10 — Transport encryption:** Latest TLS only on every endpoint; HTTP-only endpoints rejected.
- **NFR11 — Data-at-rest encryption:** All personal data (judge records, user/role records, working patterns, payroll numbers, payment metadata) encrypted at rest.
- **NFR12 — Authentication** *(revised v2.6, 2026-05-07)*: All human users authenticated via HMCTS IdP SSO (per FR1). **Inter-service authentication for user-initiated calls is via JWT propagation** — the user's JWT (issued by HMCTS IdP) is forwarded by the upstream service's outbound HTTP client and validated by the downstream service's `JWTFilter` against the IdP's JWKS endpoint. **Inter-service authentication for batch / scheduled components** (initially: the payment batch `ctam-payment-batch`) is via OAuth 2.0 `client_credentials` against `ctam-mock-auth` in non-prod; production issuer is a deferred decision per architecture `gaps.md` G7.1 (default recommendation: Azure Workload Identity, given the AKS deployment).
- **NFR13 — Authorisation enforcement** *(amended 2026-06-10[^d8]/FR2)*: Every API call resolves the principal's roles + jurisdiction + Region/Area scope through the Authorisation service; no operation bypasses this check.
- **NFR14 — Forbidden data scope:** No bank details stored or exposed by any service (PAY-NFR-05). No case-level data in any read model or report (REP-BR-NFR-03).
- **NFR15 — Government Functional Standard 7 alignment:** CTAM Pathfinder aligns with HMCTS / MoJ Government Functional Standard 7 — Security, including protective marking, access control, and secure development practices.
- **NFR16 — Secret management:** Service credentials, signing keys, and integration secrets stored in a managed secret store (Azure Key Vault or equivalent); never in source control or environment-baked images.

### Accessibility

- **NFR17 — WCAG 2.2 Level AA:** Every UI page meets WCAG 2.2 Level AA accessibility standards; tested per UI page in each domain phase before that phase's gate is passed.
- **NFR18 — Assistive technology compatibility:** Keyboard navigation, ARIA labels for tabbed and dynamic content, and screen-reader compatibility per HMCTS accessibility standards.
- **NFR19 — Public Sector Bodies Accessibility Regulations 2018:** CTAM Pathfinder complies with the Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018, including publication of an accessibility statement.

### Integration

- **NFR20 — HMCTS IdP integration:** Hard Phase 0 dependency. CTAM Pathfinder integrates with whichever AuthN protocol the HMCTS IdP exposes (OIDC or SAML).
- **NFR21 — JFEPS / Liberata integration unchanged**[^d11]: Payment schedule format (JFEPS-compatible Excel), email-to-Authoriser delivery, and authoriser-forwards-to-Liberata workflow are preserved exactly as in APEX, and verified for SSCS (wave 2). **ET wave-1 applicability is unverified — gap G8.6**[^d13]. No format change for finance across the Courts and SSCS cohorts.
- **NFR22 — HMCTS email infrastructure:** Outbound transactional emails (booking ack, absence ack, payment schedules) dispatch via HMCTS email; delivery is reliable but not low-latency-critical (overnight batch acceptable for booking acknowledgements).
- **NFR23 — DA&I MI Feed:** Aggregate-only REST API contract; no case-level data exposed under any consumer authorisation.
- **NFR24 — JOH eLinks API + MRD integration (MVP scope)**[^d11]: JOH eLinks API is an MVP integration — the canonical source for judicial-holder reference data[^d3]. MRD data is ingested via a weekly Excel feed pending availability of MRD's public APIs. Manual data entry by RSU is no longer the operating model for these sources; corrections happen at source (Judicial Office, MRD team) and are picked up by the next sync. **Other HR systems** beyond JOH eLinks / MRD remain out of MVP scope; if such integrations arise in later waves, they are scoped at that time.[^d13]

### Observability (MVP minimum)

- **NFR25 — Structured logging:** Every service emits structured logs with consistent fields, correlation IDs threaded through service-to-service calls, and a defined error-categorisation taxonomy. Logging schema is a Phase 0 deliverable.[^d7]
- **NFR26 — Log retention:** Logs retained sufficient for pilot incident triage; specific retention period set in Phase 0 within HMCTS data-retention policy.
- **NFR27 — Log ingestion:** Logs ingested into Azure-native logging (Application Insights / Log Analytics).
- **NFR28 — Health and readiness probes:** Every service exposes Kubernetes-compatible liveness and readiness endpoints (Spring Actuator).
- **NFR29 — Roadmap commitments (post-MVP, not in MVP):** Structured user-action auditing (who-did-what-when with before/after values for write operations) is a post-MVP roadmap commitment[^d7]. Metrics and trace observability beyond logs is post-MVP.

### Data Privacy & Sovereignty

- **NFR30 — UK GDPR / Data Protection Act 2018 compliance:** Personal data scope is limited to user/judge identity, contact details, payroll numbers, and operational metadata. No case-level data anywhere in CTAM Pathfinder.
- **NFR31 — Data residency:** All CTAM Pathfinder services and data hosted in Azure UK regions only. No personal data leaves the UK.
- **NFR32 — Retention**[^d11][^d3]: Data retention per HMCTS retention schedules. **No data is migrated** — historical transactional data remains in the cohort's incumbent system (`[ET-INCUMBENT-TBD]` for ET — G8.4; ListAssist for SSCS; APEX for Courts); CTAM Pathfinder retains only data created in CTAM Pathfinder from cutover onward.
- **NFR33 — FOI scope:** Aggregate operational data exposable per FOI requests; case-level data is forbidden by contract (REP-BR-NFR-03) and therefore outside FOI scope by construction.

### Reliability & Availability

- **NFR34 — Operational availability:** CTAM Pathfinder is available during HMCTS operational hours (typically 07:00–19:00 UK weekdays). Out-of-hours availability is best-effort, not contracted.
- **NFR35 — Payment-cycle continuity:** Zero failed JFEPS payment cycles attributable to CTAM Pathfinder deployment, rollout, or runtime issues. Payment generation can fall back to manual handling within a payment cycle if CTAM Pathfinder is unavailable, but this is an operational contingency, not a normal-mode expectation.
- **NFR36 — Per-wave rollback**[^d11]: Each rollout wave (Phase 9, 10, …) has a documented rollback path returning the affected wave's users to the jurisdiction's incumbent system within one operational cycle if the wave's gate is breached post-cutover — to `[ET-INCUMBENT-TBD]` for wave 1 (ET; **rollback target undefined until G8.4 closes**), to **ListAssist** for wave 2 (SSCS), to **APEX** for waves 3+ (Courts regions).[^d13]
- **NFR37 — Strategy A degraded-mode contract:** If federated read latency breaches NFR8, CTAM Pathfinder degrades to Strategy C cached projection rather than failing; cache freshness window is published in the service's OpenAPI spec metadata and surfaced in response headers (e.g. `Cache-Control`, `Age`).
- **NFR38 — HMCTS-judicial-region rollout isolation:** A wave activation or feature change targeting one wave-scope unit (the ET jurisdiction for wave 1; the SSCS jurisdiction for wave 2; an HMCTS Courts judicial region — e.g. Northern, Western — for waves 3+) does not affect users in other wave-scope units. *("Region" here means HMCTS judicial region[^d8] — not Azure region. Architectural enforcement is at the application tier via per-user `ctam_auth_user_activation_flags` (FR57), not at the infrastructure tier. Production runs in a single Azure region — UK South — with multi-AZ HA. Disaster-recovery scope and design are an open gap — see `architecture/gaps.md` G3.6. Wording clarified 2026-05-06 — earlier "Region-isolated deployments" framing was ambiguous between the two senses of "region" and is now disambiguated.)*

### Maintainability

- **NFR39 — API-as-Product standards:** Every service exposes versioned contracts, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details error envelopes, and a published OpenAPI specification (per FR58). Versioning and deprecation policy is a Phase 0 deliverable; deprecation signalling uses [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) `Deprecation` + [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594) `Sunset` headers.
- **NFR40 — Per-service deployment unit:** Each of the 11 services is independently deployable on Kubernetes; rolling updates per service per region without coupling.
- **NFR41 — Behavioural-parity UAT suite**[^d11][^d5]: Every domain service has a **manual UAT script** (per FR60) maintained alongside the service. **Jurisdiction-incumbent-experienced users** walk through the script comparing CTAM Pathfinder vs the cohort's incumbent — `[ET-INCUMBENT-TBD]`-experienced users for wave 1 (blocked on G8.4); ListAssist-experienced users for wave 2; APEX-experienced users for waves 3+ — before each rollout wave's cutover; sign-off (per role per wave) is the wave gate. There is no automated parity test suite — automated CI tests are unit, integration (Testcontainers), and contract tests only.
- **NFR42 — Postman collections:** Each phase produces a Postman collection that exercises the phase's endpoints; collections are versioned alongside the services.

## Decisions Log (D1–D12)

These are the 9 locked decisions taken during the 2026-05-05 brainstorming follow-up. Each is referenced inline throughout the PRD; the consolidated list is here for navigability.

| ID | Decision | Implication |
|---|---|---|
| **D1** | Phase 0 Foundations scope locked: Reference Data, Authorisation (with SSO), Notification, API contracts, deployment platform, structured logging conventions, shared `ctam_configuration_values` infrastructure table (no dedicated configuration service per v2.2). Audit & metrics/trace observability post-MVP. | Sets what must be in place before any domain service is built. |
| **D2** | Cutover strategy: phased rollout. Migrated users do not use APEX; non-migrated users do not use CTAM Pathfinder. | No dual-write coexistence; risk spread across waves. |
| **D3** *(superseded 2026-06-10 — see D11 clarification)* | **No data migration of any kind from any legacy system to CTAM Pathfinder.** CTAM Pathfinder starts with no transactional, reference or user data carried from ListAssist or APEX/JI. Historical scheduling data stays in the jurisdiction's incumbent system (ListAssist for SSCS, APEX for Courts) and is accessed there as needed.<p/>**Judicial-holder reference data is sourced from upstream sources of truth and persisted in CTAM Pathfinder's own tables.** The named sources are: (a) **JOH eLinks API** (Judicial Office's HR system) — the canonical source for `jo_people`, `jo_appointments`, `jo_judiciary_role_assignments`, `jo_authorisations_with_dates`, `jo_appointment_titles`, `jo_base_locations`, `jo_contract_types`, `jo_genders`, `jo_judiciary_roles`, `jo_jurisdictions`, `jo_locations`, `jo_location_types`, `jo_tickets`, `jo_ticket_categories`, and `jo_ticket_category_types`; (b) **MRD (Master Reference Data)** — supplementary attributes not in JOH eLinks, notably JOH Specialisations. MRD's public APIs are not yet available; for MVP, MRD data is ingested into CTAM Pathfinder tables from an **Excel feed supplied by the MRD team on a weekly cadence**. Both ingestion paths are **source-of-truth integration, not legacy-system migration** — the upstream data is current and authoritative; only the ingestion mechanism differs.<p/>**`ctam-reference-data` is a facade over the CTAM-owned datastore** populated by these ingestion paths. Consumers access reference data exclusively through `ctam-reference-data`'s versioned REST API; they do not need to know which upstream source each entry originates from. `ctam_sync_status` is a CTAM-internal tracking entity with no upstream source.<p/>**User authorisation data (roles, Region/Area scope, activation flags) is strictly CTAM-internal** — owned by `ctam-authorisation`, populated by programme-management / operational mechanisms outside the scope of this PRD. There is no external authority providing this data. | **Eliminates the Phase 0 Data Migration ETL** that was a programme-level deliverable. Cascade-impacts D9, D10, FR6, FR7, FR57 (the renumbered activation-flags FR), and the Phase 0 epics 0.2 and 0.3 — each requires amendment. **`ctam-reference-data` is reshaped from a self-curated reference-data store into a facade over a datastore populated by upstream source-of-truth ingestion** per D11. **New MVP integrations**: JOH eLinks API (live API integration) and MRD Excel feed (weekly cadence, transitional until MRD APIs are available). NFR24 (currently "eLinks out of scope for MVP") is reframed accordingly in a follow-up edit. The `ctam-architecture/migration/` reference is removed; that directory is no longer a deliverable. The JOH eLinks sync mechanism (pull frequency, change-detection, conflict-resolution) and the MRD ingestion mechanism (manual upload, scheduled job) are architecture-phase decisions and are not specified in this PRD. |
| **D4** | Feature-parity gate is functional + UI-replicates-APEX (modern UI stack, no redesign). | UX/visual_design/user_journeys are in scope (override on `api_backend` classification). |
| **D5** *(revised 2026-05-06; reframed 2026-06-10 per D11)* | **The jurisdiction's incumbent system is the behavioural reference, verified by manual UAT performed by users experienced in that incumbent system.** No incumbent is a migration host. For wave 1 (ET): `[ET-INCUMBENT-TBD]`-experienced users — incumbent unidentified (G8.4), role set provisional (G8.5). For wave 2 (SSCS): ListAssist-experienced users — RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI. For waves 3+ (Courts): APEX-experienced users — RSU, Court, Judge, Clerks, Finance, MI. | Per-service manual UAT scripts are walked through by the in-jurisdiction, in-wave applicable users comparing CTAM Pathfinder vs the jurisdiction's incumbent side-by-side; sign-off per role per wave is the wave gate. No automated incumbent-comparison harness; no co-management of either incumbent (D6). |
| **D6** | APEX maintenance is out of project scope. | APEX is a stable external system in the project plan; not co-managed. |
| **D7** | Audit / Observability MVP minimum: log-based (request, error). User-action audit on the post-MVP roadmap. | Structured logging is a Phase 0 deliverable; metrics/traces deferred. |
| **D8** *(reframed 2026-06-10 per D11)* | **Rollout boundary: jurisdiction first, then per-region within jurisdiction.** Wave 1 = the **Employment Tribunals (ET)** jurisdiction (within Tribunals; single wave covering all in-jurisdiction applicable roles)[^d13]. Wave 2 = the **SSCS** jurisdiction (likewise within Tribunals). Waves 3+ = jurisdictions within the Courts jurisdiction — Civil, Crime, Family, Crown — with wave granularity, ordering and per-jurisdiction region structure determined by programme management. The jurisdiction taxonomy is **open-ended**: future jurisdictions (other tribunal types, future Courts jurisdictions) extend the same model. | Wave 1 migrates only when every ET role's functionality is complete and signed-off; each subsequent wave migrates only when every in-jurisdiction in-region role's functionality is complete and signed-off.<p/>**Jurisdiction is a first-class attribute** in the data model, structured as a **hierarchy** (e.g. Tribunals / ET, Tribunals / SSCS, Courts / Civil, Courts / Crime). `ctam-authorisation` carries the user's jurisdiction alongside the user's roles, Region/Area scope, and activation flag; `ctam-reference-data` filters API responses by the requester's jurisdiction so internal CTAM Pathfinder consumers only see data relevant to their jurisdiction. The per-user `ctam_auth_user_activation_flags` mechanism (FR57) carries the jurisdiction dimension via the user's authorisation scope.<p/>**The Jurisdiction hierarchy is sourced directly from the upstream data**, not invented or tagged by CTAM Pathfinder. JOH eLinks supplies jurisdiction natively (e.g. `jo_jurisdictions`); MRD's reference data is similarly jurisdiction-aware at source. No separate tagging or mapping step is performed by CTAM Pathfinder on ingest.<p/>This cascades into: FR2 (Authorisation maps principal to jurisdiction + roles + Region/Area scope), FR4 / FR57 (admin operations are jurisdiction-aware), FR6 / FR7 (reference data API responses are jurisdiction-filtered). |
| **D9** *(amended by D10 2026-05-15; superseded + restructured 2026-06-10 — see D11 + revised D3)* | **No migration of users from APEX (or any other legacy system).** CTAM Pathfinder Authorisation tables (`ctam_auth_users`, `ctam_auth_roles`, `ctam_auth_user_roles`, `ctam_auth_user_region_scopes`, `ctam_auth_user_activation_flags`, plus the jurisdiction dimension introduced by D8) are populated by programme-management / operational mechanisms outside the scope of this PRD.<p/>**CTAM Pathfinder serves two distinct user populations**, both authenticating via the HMCTS IdP tenant but identified through different lookup paths:<p/>**(a) Judicial Office Holders (JOHs)** — at authentication time the IdP email is looked up against `jo_people` (JOH eLinks data ingested into CTAM) to resolve the **personal number**, the canonical, stable, internal identifier for the JOH. Email is the lookup key but is not the canonical identifier (emails may change; personal number is stable).<p/>**(b) HMCTS administrative staff** — RSU, Court users, Tribunal Caseworkers, Finance / Payment Authoriser, MI / Reporting users and equivalents are **not present in JOH eLinks data**. CTAM Pathfinder maintains a **separate CTAM-internal staff identity table** for these users, populated by programme-management / operational mechanisms outside the scope of this PRD. The canonical identifier for admin-staff users is a CTAM-assigned or HMCTS-assigned staff identifier (architecture-phase decision).<p/>Both populations are subject to the same `ctam-authorisation` model (roles, jurisdiction, Region/Area scope, activation flag) — the populations differ only in their identity sources, not in their authorisation semantics. The PRD does not specify the bootstrap mechanism for either identity store or for the authorisation tables themselves. | Authorisation remains testable end-to-end against a representative dataset; per-wave activation is a flag flip on `ctam_auth_user_activation_flags`, scoped to the wave's (jurisdiction, region) tuple per D8. The Phase 0 ETL reference is removed; the directory `ctam-architecture/migration/` is no longer a deliverable.<p/>**`ctam-authorisation` carries two identity sources**: (a) JOH identity via runtime lookup against `jo_people` (introducing a runtime dependency on the ingested JOH eLinks data — integration point TBD architecture-phase); (b) admin-staff identity via a CTAM-internal staff identity table (schema and bootstrap TBD architecture-phase). The two populations share a single authorisation model and the same `auth_*` schema. |
| **D10** *(new 2026-05-15; sub-clause about SQL ETLs superseded 2026-06-10 by D11)* | **Admin UI is removed from MVP scope and pushed to post-MVP.** The `ctam-admin-ui` repo, Reference Data admin module, Users/Roles admin module, Migration Reports module, Activation Toggle, and Admin Send-Test-Email all become post-MVP roadmap items. Admin-write API endpoints on `ctam-reference-data` and `ctam-authorisation` are likewise post-MVP — both APIs ship read-only in MVP. Reference Data and Users/Roles are loaded via **direct SQL ETLs**; ongoing maintenance in MVP is by DBAs via direct SQL per operational runbooks; named-owner sign-off happens via **versioned git commits** to `migration/reports/{stream}/signoffs/`. The `gh` CLI is **not** available in the engineering environment — all GitHub repo creation, branch-protection setup, CODEOWNERS configuration, and PR workflow happen via the GitHub web UI manually.<p/>***NOTE (2026-06-10):*** *The 2026-05-15 sub-clause above stating "Reference Data and Users/Roles are loaded via direct SQL ETLs … named-owner sign-off happens via versioned git commits" is **superseded by D11**. Reference Data is now sourced from JOH eLinks + MRD per the revised D3 (no SQL ETL); Users/Roles are populated by mechanisms outside this PRD's scope per the superseded D9 (no SQL ETL); the git-based sign-off mechanism is no longer needed. The admin-UI-removed-from-MVP and no-`gh`-CLI parts of D10 are unchanged.* | Reduces MVP scope and timeline; pushes ~6 stories' worth of admin-UI work post-MVP. Adjusts FR4, FR6, FR56, FR57 wording to reflect data-layer-in-MVP vs UI-surface-post-MVP. Affects the Phase 0 epic plan: stories drop from 18 → 11 (admin UI stories removed; OAuth `client_credentials` flow moved to Phase 6 with `ctam-payment-batch`). All Phase 0+ stories with GitHub-repo-creation ACs are reworded to require manual web-UI steps. See `epics/phase-0/validation-report-2026-05-15.md` for the revised validation.<p/>***2026-06-10 amendment per D11:*** *the SQL-ETL bootstrap mechanism is retracted (cascade-impact of the eliminated Phase 0 Data Migration ETL); the git-based named-owner sign-off is no longer needed. Phase 0 epics 0.2 and 0.3 require further restructuring (per-story impact tracked in those epic files).* |
| **D11** *(new 2026-06-10; amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering — the SSCS wave is now wave 2**)* | **SSCS pilot wave.** *(Historical record as decided on 2026-06-10 — the wave numbers below are D11's originals and are superseded by D13: the SSCS wave is now **wave 2**, Courts waves are now **3+**.)* CTAM Pathfinder's MVP pilot rollout (Phase 9, wave 1) targets the **SSCS Tribunals jurisdiction**, not a single HMCTS Courts judicial region. CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool) for the SSCS jurisdiction in wave 1; **GAPS — the SSCS case-management system — is retained (not replaced), analogous to the external case-management systems that consume CTAM's APIs per D12**. APEX/JI continues to serve Courts users in waves 2+. The 11-service architecture and Phase 0–8 build sequence are unchanged. | **Reframes D3, D5, D8, D9 as jurisdiction-aware**: incumbent system, parity reference, rollout boundary, and user/reference-data source all depend on the wave. **Phase 0 Reference Data ingestion** is from JOH eLinks API + MRD per the revised D3 (no ETL, no legacy migration); the SSCS jurisdiction provides the wave-1 cutover scope; Courts jurisdictions follow in waves 2+. **Manual UAT (D5, FR60)** is walked by users experienced in the jurisdiction's incumbent system — ListAssist-experienced users for wave 1; APEX-experienced users for wave 2+. **JFEPS payment integration is preserved for wave 1** (SSCS tribunal-member payments use the same JFEPS Excel + Liberata path). **Domain-model and terminology extensions** required within the 11 services for SSCS-specific concepts (**tribunal-member sub-types** — Medical, Disability-Qualified, Disability (Other)). **Panel composition and hearing types are out of CTAM scope per D12** — case management and panel allocation live in external systems consuming CTAM's APIs. The umbrella term **JOH (Judicial Office Holder)** replaces "judge" across PRD, FRs, architecture, glossary and service naming (`ctam-judge` → `ctam-joh` or architecture-phase equivalent) — "judge" remains valid where the meaning is specifically a judge; JOH is used wherever the meaning includes non-judge panel members. A new **SSCS as-is analysis pack** is required (parallel to the existing JI/APEX pack under `docs/architecture/asis/`). Prior **Implementation Readiness Reports** (2026-05-05 / -06 / -15 / -15-rev2) assessed the Courts jurisdiction only; a parallel SSCS-jurisdiction readiness assessment is required before Phase 9. |
| **D12** *(new 2026-06-10)* | **CTAM Pathfinder's scope is JOH availability and scheduling — not case or hearing management.** CTAM is the **system of record** for JOH details, traits, working patterns, absences, vacancies, bookings and sittings. Allocation decisions (which JOH covers which vacancy) are made by admin staff via the off-system advertising/matching process (FR27) and **recorded in CTAM via the UI by those admin staff** — they are not pushed in from external systems. Case management, panel composition for specific cases, and hearing types live in **external systems** that **consume CTAM's APIs** for reporting and operational use; no external system writes into CTAM. | **Bounds the 11-service decomposition**: services record JOH commitments and traits, not cases or hearings. **No FRs added** for panel composition or hearing type — those are external-system concerns. **Amends D11 implication** to drop "tribunal panels / multi-member hearings, hearing types — oral / paper / CMA" from the SSCS extension list. **Amends Executive Summary char #6** correspondingly. |
| **D13** *(new 2026-08-07; supersedes D11 for wave ordering)* | **ET-first pilot wave.** CTAM Pathfinder's MVP pilot rollout (Phase 9, wave 1) targets the **Employment Tribunals (ET)** jurisdiction. **Wave 2 = the SSCS Tribunals jurisdiction** (replacing ListAssist; GAPS, the SSCS case-management system, is retained per D11 as amended). **Waves 3+ = Courts jurisdictions** (Civil, Crime, Family, Crown) per HMCTS judicial region, replacing APEX/JI. The 16-repo architecture and the Phase 0–8 build sequence are **unchanged** — jurisdiction is a first-class upstream-sourced attribute per D8, so retargeting the pilot is a data-and-rollout change, not an architectural one.<p/>**ET's judicial-scheduling incumbent is not yet identified** (gap G8.4). Until it is, the wave-1 behavioural reference (D5), manual-UAT parity target (FR60/NFR41), rollback target (NFR36) and historical-data location (NFR32) are recorded as the placeholder `[ET-INCUMBENT-TBD]`.<p/>**ET JOH type taxonomy is provisional** pending the ET as-is analysis pack (gap G8.5): Employment Judges (salaried and fee-paid), Regional Employment Judges, and non-legal ("lay") members drawn from employer-side and employee-side panels. **Panel composition and hearing types remain out of CTAM scope per D12.** | **No FR or NFR is added, removed or renumbered**; ~12 are reworded where their prose names a jurisdiction or incumbent (FR6, FR7, FR44, FR57, FR60, NFR21, NFR24, NFR32, NFR36, NFR38, NFR41). **No epic is added, removed, re-scoped or resequenced** — Phase 0 stays at 6 epics / 19 stories; four acceptance-criteria lines change illustrative examples only. **No code impact** — implementation had not started. **New wave-1 deliverable:** the **ET as-is analysis pack** (parallel to the JI pack under `docs/architecture/asis/`); the SSCS as-is pack and SSCS-cohort readiness assessment defer to wave 2. **New gaps** G8.4 (ET incumbent), G8.5 (ET taxonomy / as-is pack), G8.6 (JFEPS applicability to ET); G8.1 promoted to a wave-1 blocker (eLinks must carry ET); G8.3 retargeted. **The business case is retargeted to ET as a settled decision**; two supporting-evidence items (the wave-1 replacement driver and ET's quantified risk profile, both originally assessed for SSCS) are flagged inline as outstanding and land with the ET as-is analysis pack. See [`./sprint-change-proposal-2026-08-07.md`](./sprint-change-proposal-2026-08-07.md). |
| **D14** *(new 2026-08-13)* | **Programme renamed RAM → CTAM — *Court and Tribunals Availability Management*.** The former expansion (*Resource Availability/Allocation Management*) is retired. The rename is applied uniformly across every naming surface: product codename **RAM Pathfinder → CTAM Pathfinder**; the 17 repository names `ram-*` → `ctam-*` (including this control-plane repo, `ram-analysis` → `ctam-analysis`, already renamed on GitHub); the owned-table prefix `ram_` → `ctam_` (and index names `uq_ram_*` → `uq_ctam_*`); the Java root package `uk.gov.hmcts.ram` → `uk.gov.hmcts.ctam`; the API-spec artefact coordinates `api-ram-{service}` → `api-ctam-{service}`; the shared database schema `ram` → `ctam`; and the DNS hostnames `ram.hmcts.gov.uk` / `api.ram.{env}.hmcts.gov.uk` / `admin.ram.hmcts.gov.uk` → their `ctam` equivalents. Adjectival prose (`RAM-owned`, `RAM-assigned`, `RAM-internal`, `RAM-overlay`) follows. Upstream prefixes `jo_` / `mrd_` and the dev-only `mock_` prefix are **untouched** — they name source systems, not this programme. | **Naming only — nothing else changes.** No FR or NFR is added, removed, renumbered or reworded in substance; the 16-repo decomposition, the 55-table data model, the Phase 0–8 build sequence, all 6 Phase 0 epics / 19 stories, `dispatch-graph.yaml`, `delivery/ledger/`, and decisions D1–D13 all stand exactly as they were. **No code impact** — implementation has not started, so no migration, no deprecation window and no dual-naming period is required; this is the cheapest possible moment for the change. Dated reports, SCPs and prior changelog entries were rewritten in place (rather than preserved verbatim) so the artifact set is uniformly searchable under one name — the git history is the point-in-time record. **`docs/` regenerated.** See [`./sprint-change-proposal-2026-08-13.md`](./sprint-change-proposal-2026-08-13.md). |

## Glossary

| Term | Meaning |
|---|---|
| **APEX** | Oracle Application Express; the legacy platform JI runs on today |
| **CTAM** | **Court and Tribunals Availability Management** — the programme name adopted 2026-08-13[^d14], replacing the former **RAM** (Resource Availability/Allocation Management). Used as the product codename (**CTAM Pathfinder**), the repository prefix (`ctam-*`), the owned-table prefix (`ctam_`), and the Java root package (`uk.gov.hmcts.ctam`). |
| **DA&I** | Data, Analysis & Insight; HMCTS analytics / MI team consuming JI data |
| **DJ** | District Judge |
| **DJ(MC)** | District Judge (Magistrates' Courts) |
| **FOI** | Freedom of Information Act 2000 |
| **FPB** | Fee-paid and other Bookings (APEX module name) |
| **GAPS** | The **SSCS case-management system** (legacy), **retained** — CTAM Pathfinder does **not** replace GAPS. In **wave 2**[^d13] CTAM replaces the SSCS judicial-scheduling tool (**ListAssist**), not GAPS. GAPS is the SSCS analogue of the external case-management systems that consume CTAM's APIs (per D12): it stays in place and consumes CTAM's APIs[^d11][^d12]. |
| **GDS** | Government Digital Service (UK Cabinet Office) |
| **HMCTS** | His Majesty's Courts and Tribunals Service |
| **IdP** | Identity Provider (HMCTS's SSO / authentication system) |
| **JFEPS** | Judicial Fee Payment System (HMCTS finance system) |
| **JFL** | Judges Forward Look (sub-module of Judge Itinerary) |
| **JI** | Judicial Itineraries — the legacy Oracle APEX system serving the **Courts** jurisdiction. Replaced by CTAM Pathfinder in waves 3+[^d13]. |
| **JOH** | Judicial Office Holder — umbrella term covering salaried and fee-paid judges and tribunal members (Medical, Disability-Qualified, Disability (Other)). Adopted[^d11] (2026-06-10) as the project-wide term replacing "judge" where the meaning includes non-judge panel members. |
| **Jurisdiction** | CTAM Pathfinder's primary classification dimension for users, JOHs, and reference data. Modelled as a **hierarchy** where parent jurisdictions (Tribunals, Courts) contain child jurisdictions (e.g. ET and SSCS within Tribunals; Civil, Crime, Family, Crown within Courts). Sourced from JOH eLinks (`jo_jurisdictions`); the hierarchical parent-child shape is preserved natively if present upstream, or established on ingest. Used to scope authorisation, filter reference-data API responses, and define rollout waves[^d8][^d11]. |
| **ListAssist** | The SSCS judicial-scheduling tool used in the SSCS Tribunals jurisdiction today; the SSCS scheduling incumbent and the **wave-2** UAT parity reference. Replaced by CTAM Pathfinder for SSCS in wave 2[^d13]. (GAPS, the SSCS case-management system, is retained.) |
| **Employment Tribunals (ET)** | The HMCTS Tribunals jurisdiction handling employment disputes (unfair dismissal, discrimination, wages and related claims). **The wave-1 pilot jurisdiction for CTAM Pathfinder**[^d13]. Its judicial-scheduling incumbent, case-management system, role taxonomy and panel structure are **not yet established in this programme's analysis** — see gaps G8.4 and G8.5. |
| **Employment Judge** | A JOH who sits in the Employment Tribunals, salaried or fee-paid. *Provisional term pending the ET as-is analysis pack (G8.5).* |
| **Regional Employment Judge** | A salaried Employment Judge with regional leadership responsibility (the ET analogue of the SSCS RTJ). *Provisional pending G8.5.* |
| **Non-legal member (lay member)** | A non-judge JOH who sits as part of an Employment Tribunal panel, drawn from either the employer-side or the employee-side panel. The ET analogue of the SSCS Tribunal Member. *Provisional pending G8.5.* |
| **`[ET-INCUMBENT-TBD]`** | Placeholder token for **ET's judicial-scheduling incumbent, which has not been identified** (gap G8.4). It appears wherever the wave-1 behavioural reference, UAT parity target, rollback target or historical-data location is named. Resolving G8.4 is a single mechanical sweep of this token. **Nothing in this PRD asserts what ET's incumbent is.** |
| **Liberata** | HMCTS's payment processing partner |
| **MI** | Management Information |
| **MoJ** | Ministry of Justice |
| **MRD** | Master Reference Data — an external HMCTS system holding supplementary judicial reference data not present in JOH eLinks (notably JOH Specialisations). Public APIs are not yet available; CTAM Pathfinder ingests MRD data via a weekly Excel feed for MVP, transitioning to API-based integration when MRD APIs ship. |
| **CTAM Pathfinder** | The API-driven greenfield platform for HMCTS judicial scheduling this PRD describes. Pilots on the **Employment Tribunals** jurisdiction in wave 1[^d13], replaces ListAssist for SSCS in wave 2, and JI/APEX for Courts in waves 3+. |
| **NTBF** | Not To Be Filled (an absence flag — cover not required) |
| **OIDC** | OpenID Connect (an authentication protocol) |
| **OPT** | One Performance Truth; the broader Oracle/APEX platform JI sits on |
| **[RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457)** | IETF specification for Problem Details for HTTP APIs (current; obsoletes RFC 7807) |
| **[RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745)** | IETF specification for the HTTP `Deprecation` response header (March 2025) |
| **[RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594)** | IETF specification for the HTTP `Sunset` response header |
| **RSU** | Regional Support Unit (HMCTS regional admin teams) |
| **RTJ** | Regional Tribunal Judge — salaried JOH leading a tribunal region (SSCS context; wave 2). |
| **S&L** | Scheduling & Listing reforms (HMCTS programme) |
| **SAML** | Security Assertion Markup Language (an authentication protocol) |
| **SSCS** | Social Security and Child Support — the HMCTS Tribunals jurisdiction handling appeals on PIP, ESA, Universal Credit, DLA and related benefits decisions. The **wave-2** jurisdiction for CTAM Pathfinder[^d13] (was wave 1 under D11). |
| **SSO** | Single Sign-On |
| **TBD** | To Be Determined (programme-management or architecture-phase decision) |
| **Tribunal Member** | A non-judge JOH who sits as part of a tribunal panel — typically Medical (medically qualified), Disability-Qualified, or Disability (Other). SSCS-jurisdiction concept (wave 2). The ET analogue is the non-legal ("lay") member. |
| **Tribunal Panel** | A composed group of JOHs sitting together for a single tribunal hearing — typically one Tribunal Judge plus one or more Tribunal Members (in ET: an Employment Judge plus non-legal members). SSCS panel composition is hearing-type-dependent (e.g. PIP appeals typically require Judge + Medical + Disability-Qualified); **ET panel composition rules are unconfirmed — G8.5**. Panel composition itself is out of CTAM scope per D12. |
| **UK GDPR** | UK General Data Protection Regulation (post-Brexit equivalent of EU GDPR) |
| **WCAG** | Web Content Accessibility Guidelines |

## References

Source documents consulted during PRD generation (also recorded in this PRD's `inputDocuments` frontmatter):

- `_bmad-output/brainstorming/brainstorming-session-2026-05-05-1600.md` — the 9 locked decisions, 11-service decomposition, migration table, and risk register
- `docs/architecture/asis/functional-modules.md` — catalogue of the 12 functional modules in the existing Oracle APEX JI system
- `docs/architecture/asis/data-dependencies.md` — JI's external data dependencies (eLinks, HR, JFEPS, Liberata, DA&I, HMCTS Email)
- `docs/architecture/asis/integration-dependencies.md` — JI's integration flows and mechanisms

The 1600 brainstorming session itself supersedes lines 139–149 of the 2026-05-01 brainstorming session (migration sequencing) and the entirety of the 2026-05-05-1500 brainstorming draft (which was based on a strangler-fig assumption that has been retracted).

[^d1]: D1 — Phase 0 Foundations scope: Reference Data, Authorisation (SSO), Notification, API contracts, deployment platform, structured logging.
[^d2]: D2 — phased cutover: migrated users leave the incumbent entirely; no dual-running.
[^d3]: Revised D3 (2026-06-10) — no data migration from any legacy system; judicial-holder reference data is ingested from the JOH eLinks API and MRD.
[^d4]: D4 — feature parity is functional + UI replication of the incumbent on a modern stack.
[^d5]: D5 — the jurisdiction's incumbent system is the behavioural reference, verified by manual UAT.
[^d6]: D6 — incumbent systems are not co-managed.
[^d7]: D7 — MVP observability is log-based; user-action audit is post-MVP.
[^d8]: D8 — rollout is jurisdiction-first, then per-region; jurisdiction is a first-class hierarchical attribute.
[^d9]: Restructured D9 (2026-06-10; refined 2026-07-09 per SCP) — two user populations. JOHs resolve IdP email → `jo_people` → `personnel_number` → a **CTAM-assigned JOH UUID** (`ctam_joh_identities`); HMCTS admin staff via a CTAM-internal identity table. Both key on a CTAM-assigned UUID; `personnel_number` is the upstream link only. No legacy user migration.
[^d10]: D10 (2026-05-15) — admin UI is post-MVP; MVP admin operations are DBA-via-SQL per operational runbooks.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
[^d12]: D12 (2026-06-10) — CTAM is the system of record for JOH availability and scheduling only; case and hearing management live in external systems.
[^d14]: D14 (2026-08-13) — programme renamed **RAM → CTAM** (*Court and Tribunals Availability Management*). Naming-only; no scope, requirement, architecture or sequencing change.
