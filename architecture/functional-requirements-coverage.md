---
type: 'Architecture Shard'
description: 'The 60 Functional Requirements are organised into 9 capability areas.'
resource: 'architecture/tobe/functional-requirements-coverage.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-06-11'
parent: ../architecture.md
title: Functional Requirements Coverage (FR1–FR60)
last_updated: 2026-06-11
amended_in: architecture.md v3.0 — Sprint Change Proposal 2026-06-10 cascade (FR renumbering FR58–FR61 → FR57–FR60; ETL FR retracted; JOH terminology; two-tier reference data)
---

# Functional Requirements Coverage (FR1–FR60)

> Sibling of [`../architecture.md`](../architecture.md). The parent links here from its *Architecture Validation Results / Requirements Coverage Validation* section.

The 60 Functional Requirements are organised into 9 capability areas. Each subsection below lists the FRs in that area (summarised from the PRD as amended 2026-06-10) and the architectural support that satisfies them.

**All 60 FRs have explicit architectural support.** None unaddressed. *(The Phase 0 Data Migration ETL FR was retracted 2026-06-10[^d3]; FR58–FR61 were renumbered FR57–FR60.)*

## Identity & Authorisation (FR1–FR5)

- **FR1** *(amended 2026-06-10)* — Authenticated users access CTAM Pathfinder via HMCTS IdP single sign-on; password, session, and account lifecycle are owned by the IdP. At authentication time, the IdP email is resolved to CTAM Pathfinder's canonical identifier — the **CTAM JOH UUID** (JOH users, via `jo_people` → `personnel_number` → `ctam_joh_identities`) or the CTAM-internal staff identifier (admin-staff users, via `ctam_auth_staff_identities`)[^d9].
- **FR2** *(amended 2026-06-10)* — CTAM Pathfinder's Authorisation service maps each authenticated principal to one or more roles, a **jurisdiction**, and a Region/Area scope, and authorises every system call against that mapping.
- **FR3** — Authorised users can retrieve their effective permissions for their authenticated session.
- **FR4**[^d10] — System administrators can update role, jurisdiction, and Region/Area assignments for any user. In MVP the data layer is editable by DBAs via direct SQL per runbook; the admin UI surface (`ctam-admin-ui` Users & Roles module) is post-MVP.
- **FR5** *(reframed v2.5 as post-MVP)* — External machine-to-machine consumers require an authentication mechanism. At MVP, no machine-to-machine consumers are in scope. The mechanism for genuine service-principal authentication is a post-MVP open question (see [`./gaps.md` G7](./gaps.md)).

**Architectural support:** Authorisation service (incl. `ctam_auth_staff_identities` + the two-population identity lookup) + per-service custom `JWTFilter` (HMCTS template pattern) + OIDC for human users (mock auth Phase 0–8; HMCTS IdP from pre-Phase-9) + JWT propagation interceptor (Pattern 1) + OAuth `client_credentials` for the payment-batch service principal (Pattern 2). **FR4** UI surface is post-MVP `ctam-admin-ui`[^d10]. FR5 (full programmatic service-account directory) remains post-MVP.

## Foundational Data Management (FR6–FR9)

- **FR6**[^d10] — RSU users can **view** Reference Data through `ctam-reference-data`'s versioned read API. Two ownership tiers in **separate tables** (lineage preserved): **(a) upstream-sourced** (`jo_*` JOH eLinks entities + `mrd_*` MRD entities) — read-only in CTAM, refreshed from source, corrections at source, no CTAM write surface; **(b) CTAM-owned** — data not existing upstream plus operational state over upstream entities; DBAs via SQL in MVP, RSU-facing maintenance UI post-MVP.
- **FR7** *(reframed 2026-06-10)* — Every CTAM Pathfinder service reads Reference Data via **direct SQL** on the shared schema's Reference Data tables (SELECT-granted per service role) — no client class, no API fan-out, no cache (Principle 2). **Writes follow the tier**: tier-(a) tables written exclusively by the ingestion mechanisms (JOH eLinks sync + MRD weekly feed); tier-(b) tables by DBAs via SQL in MVP. `ctam-reference-data` is the **single owner** of all reference-data tables; no service holds duplicate or cached copies.
- **FR8** *(revised v2.2)* — Cross-service runtime policy values are stored in a shared `ctam_configuration_values` infrastructure table, schema-managed by `ctam-architecture`'s Liquibase baseline changelog and SELECT-granted to every CTAM Pathfinder service DB role. Updates via Liquibase changesets or admin SQL — no API service. Per-service config that's scoped to one service uses Spring profiles + `application.yml` + Azure Key Vault.
- **FR9** — CTAM Pathfinder dispatches transactional emails (booking acks, absence acks, payment schedules) via HMCTS email infrastructure, with a delivery log retained.

**Architectural support:** Reference Data + Notification services; in-process JOH eLinks scheduled sync + MRD blob pick-up (see [`../architecture.md`](../architecture.md) → *Upstream reference-data ingestion*); direct SQL access to the Reference Data tables (no caching at MVP per Principle 2); shared `ctam_configuration_values` table. **FR6** tier-(b) maintenance UI is post-MVP `ctam-admin-ui`[^d10]; tier (a) has no CTAM write surface in any phase.

## JOH Records & Working Patterns (FR10–FR18)

- **FR10** — RSU users can search and filter **JOHs** by name, base location, location type, and JOH type.
- **FR11** — RSU users can **view** JOH profiles through `ctam-reference-data`'s read API. Upstream-sourced fields (`jo_people`, `jo_appointments`, …, MRD Specialisations) are tier (a) — read-only, corrections at source. CTAM-owned operational state and overlays (location per FR17, working patterns per FR12, ticket overlays per FR15) are tier (b) — separate tables **keyed by `joh_id` → `ctam_joh_identities`**.
- **FR12** — Authorised users can define and update Working Patterns (None / Daily / Weekly) for JOHs, with target sit %, jurisdictional split, and per-day work-type pattern. CTAM-owned operational state (tier (b)).
- **FR13** — CTAM Pathfinder auto-populates JOH itineraries up to the next 31st March from the working pattern, preserving any prior absences.
- **FR14** *(reframed 2026-06-10)* — Salaried full-time / part-time status is sourced from JOH eLinks (`jo_contract_types`); CTAM displays the current status; conversions happen upstream and are reflected at the next sync. The previous in-CTAM conversion capability is retracted.
- **FR15** — Ticket information per JOH role is exposed through `ctam-reference-data`'s read API, combining (a) upstream `jo_tickets` (read-only) and (b) CTAM-overlay tickets/authorisations in `ctam_joh_ticket`, keyed by `joh_id` → `ctam_joh_identities`; overlay rows editable by admin staff (DBAs via SQL in MVP).
- **FR16** — CTAM Pathfinder validates that jurisdictional split percentages total 100% before saving.
- **FR17** — RSU users can switch a JOH's base location to another office within the same Region; cross-Region changes require OPT Advice Point and are out-of-system. Location changes are CTAM-owned operational state (`ctam_joh_location`) — not propagated back to JOH eLinks.
- **FR18** — Authorised users can link to JOHs managed by other offices (off-circuit / cross-Region) for booking purposes (e.g. composing tribunal panels with members from other regions).

**Architectural support:** `ctam-joh` repo (Phase 1) — owns the CTAM-owned operational overlays keyed by `joh_id` → `ctam_joh_identities`; the upstream JOH person record is `jo_people` (owned by Reference Data, refreshed by the eLinks sync), and CTAM's canonical JOH identifier is the UUID in `ctam_joh_identities`. Profile views compose tier (a) + tier (b) via `ctam-reference-data`'s read API. Working-pattern engine owned by JOH.

## Absence Workflow (FR19–FR22)

- **FR19** — Authorised users can record absence requests with start/end date, partial-day option (full / AM / PM), type from a controlled list, and an NTBF flag.
- **FR20** — CTAM Pathfinder distinguishes auto-confirmed absences (from judicial teams) from those requiring confirmation (from Courts or judges); confirmation can trigger an acknowledgement email.
- **FR21** — Sickness absences can be extended without creating a new record; non-sickness extensions require a new absence record.
- **FR22** — Authorised users can mark absences as *Not To Be Filled* (NTBF) or as *needs fee-paid cover*.

**Architectural support:** `ctam-absence` repo (Phase 2); approval workflow with auto-vacancy creation per R4.

## Vacancy & Cover (FR23–FR28)

- **FR23** — CTAM Pathfinder auto-creates a vacancy when an approved absence requires fee-paid cover, pre-populated with JOH type, work type, ticket, and dates.
- **FR24** — Authorised users can create standalone vacancies independent of any absence.
- **FR25** — Authorised users can edit a vacancy's daily breakdown — cancel individual days with a captured reason; extend or shorten the period.
- **FR26** — CTAM Pathfinder marks a vacancy as filled when a booking is created against it; vacancy days cannot be cancelled once a booking is recorded.
- **FR27** — CTAM Pathfinder surfaces fee-paid JOHs matching a vacancy's filter as a hint for advertising; advertising itself is performed out-of-system by judicial teams. *(Allocation decisions are recorded in CTAM via the UI by admin staff — not pushed in from external systems,[^d12].)*
- **FR28** — Authorised users can cancel or close vacancies (e.g. when a parent absence becomes NTBF).

**Architectural support:** `ctam-vacancy` repo (Phase 3); Booking marks the linked vacancy as filled in the same transaction per Principle 1 (no `markFilled` API endpoint at MVP — Booking has the necessary DB-role grant; per-column detail in [`../architecture.md`](../architecture.md) → *Data Architecture*).

## Booking Management (FR29–FR34)

- **FR29** — Authorised users can create fee-paid bookings (linked to a vacancy or standalone), capturing **JOH**, **court / tribunal**, date, session type (full / AM / PM / evening / reserved-matter), booking type, and work type.
- **FR30** — Booking creation marks the linked vacancy as filled within the same transaction when a `vacancyId` is supplied. *(In-process direct DB UPDATE on the `ctam_vacancies` row using a per-service DB role grant; see Principle 1.)*
- **FR31** — CTAM Pathfinder tracks booking status (planned, provisional, confirmed, cancelled, rejected) with reason capture for cancellation.
- **FR32** — CTAM Pathfinder sends booking acknowledgement emails to fee-paid **JOHs**, batched overnight or sent immediately via *Create and Email Now*.
- **FR33** — CTAM Pathfinder requires a Y/N answer at booking time when a **JOH's** fee entitlement is *Ask when booking*.
- **FR34** — CTAM Pathfinder prevents double-booking of fee-paid **JOHs** for overlapping sessions.

**Architectural support:** `ctam-booking` repo (Phase 4); bookings reference the JOH by `joh_id` → `ctam_joh_identities`; retry safety via native DB primitives — natural-key uniqueness, optimistic locking, and pessimistic row locking on the target vacancy. No custom idempotency table. Detail in [`../architecture.md`](../architecture.md) → *Data Architecture* and [`./data-tables.md`](./data-tables.md).

## Sitting Management (FR35–FR40)

- **FR35** — CTAM Pathfinder generates planned sittings for **salaried JOHs** from their working patterns, **court / tribunal**, date, and work type.
- **FR36** — Authorised users can filter sitting records by Region/Office, **JOH type**, **JOH**, and date range.
- **FR37** — Authorised users can confirm that a sitting actually took place, updating outcome (confirmed, cancelled, rejected) and actual work type.
- **FR38** — Authorised users can split a sitting into AM/PM with different work types within a single day.
- **FR39** — Authorised users can create ad-hoc sittings for **salaried JOHs**, including DJ(MC)s and Legal Advisers in County Courts (Courts-cohort-specific examples).
- **FR40** *(revised 2026-05-11)* — Verifiers can verify confirmed sittings; once verified, the data is read-only. Post-verification amendments require **re-opening** via a UI re-open action gated by a distinct authorised role (RSU Admin only at MVP — different from the original confirmer and from a standard Verifier). Mandatory justification captured; fully audited. No external Request-for-Change ticketing.

**Architectural support:** `ctam-sitting` repo (Phase 5); generated from JOH working patterns; verification gates downstream edits.

## Payment & Reconciliation (FR41–FR47)

- **FR41** *(revised v2.6)* — Authorised users can list confirmed bookings and salaried sittings, filterable by Region/Office, judge, date range, and payment lifecycle status (pending, requested, paid, reconciled). The **payment-eligible** subset is the read-only union of confirmed bookings + sittings whose payment record does not yet exist; this is the input the scheduled batch consumes.
- **FR42** *(revised v2.6)* — CTAM Pathfinder's **payment-processing batch** (`ctam-payment-batch`, scheduled on a configurable cron) automatically marks eligible bookings as *payment requested* and creates the corresponding `ctam_payments` + `ctam_payment_schedules` records. **No user click is required.** Authorised users can also list and review the generated schedule before/after dispatch.
- **FR43** *(revised v2.6)* — The **payment batch** generates JFEPS-compatible payment schedules and dispatches them as Excel attachments to a configured Payment Authoriser via email (using its service-principal identity to call the Notification API); the Payment Authoriser forwards to Liberata out-of-system. Schedule generation and dispatch are batch-driven, not user-initiated.
- **FR44** — CTAM Pathfinder exposes the payment schedule via API with content-type negotiation (`application/vnd.hmcts.jfeps+json` or `+xlsx`); the JFEPS shape evolves independently of Payment internals. Preserved for SSCS (wave 2)[^d11]; **ET wave-1 applicability is unverified — gap G8.6**[^d13].
- **FR45** — CTAM Pathfinder prevents double submission of the same booking for payment. The batch's natural-key uniqueness rejects duplicate creates; re-runs of the same cycle are idempotent. (Column-level detail in *Data Architecture* and [`./data-tables.md`](./data-tables.md).)
- **FR46** — Authorised users (Finance, RSU) can flag payments as reconciled, capturing notes for mismatches; once fully reconciled, a payment cannot be re-requested for the same booking.
- **FR47** — CTAM Pathfinder does not store or expose bank details for any JOH — those remain in the finance system.

**Architectural support:** `ctam-payment` repo (Phase 6) — scheduled batch (`ctam-payment-batch`) authenticates as a service principal, picks up confirmed-but-unpaid bookings/sittings, generates the JFEPS-shaped Excel, dispatches via Notification → HMCTS Email; reconciliation marked manually by RSU at MVP. See [`./sequence-diagrams/payment-batch-flow.md`](./sequence-diagrams/payment-batch-flow.md).

## Itineraries & Reporting (FR48–FR54)

- **FR48** — Authorised users can render the Court Itinerary (monthly or annual) for a given Office, Financial Year, and Month, showing sittings, bookings, vacancies, and NTBF absences for each day.
- **FR49** — Authorised users can render the Judge Itinerary for one or more judges over a date range, scoped by Authorisation (judges see only their own; courts see their office; RSU sees their region).
- **FR50** — Authorised users can use the Forward Look view across a Region with paged or filtered access for performance.
- **FR51** — Itinerary cells are clickable and drill into the underlying record (Sitting, Absence, Vacancy, or Booking).
- **FR52** — Authorised users can copy/export Itinerary and Report contents to Excel and PDF.
- **FR53** — CTAM Pathfinder provides a fixed catalogue of standard Reports (weekly sitting projections, weekly vacancies, absence analysis, vacancy by court, confirmed sittings/bookings by judge or judge type, judge utilisation, jurisdictional split, summary by court / work type) with parameter filters per report.
- **FR54** — CTAM Pathfinder exposes aggregated MI Feed APIs for external consumers (DA&I, future programmes); MI Feed responses contain no case-level data and are aggregate-only by contract.

**Architectural support:** `ctam-itinerary` and `ctam-mi-feed` repos (Phases 7–8); SQL-based read models via JOINs over the shared schema (incl. `jo_people` + `ctam-joh` overlays) in the global database — no parallel API fan-out, no Strategy A latency stacking. External case-management systems consume these APIs from Phase 9[^d12]; they never write into CTAM.

## Platform Operations (FR55–FR60)

*(There is no data-migration FR — the Phase 0 ETL was retracted[^d3]; FR58–FR61 became FR57–FR60.)*

- **FR55** — Authenticated users land on a Home page showing role-scoped navigation, Region/Area selector, summary tiles for the selected scope, and contextual help.
- **FR56**[^d10] — CTAM Pathfinder's **business-user UI** (`ctam-ui`) replicates the functional surface of the as-is APEX UI on a modern UI stack and meets WCAG 2.2 Level AA. MVP: `ctam-ui` only; `ctam-admin-ui` post-MVP.
- **FR57** *(was FR58; reframed 2026-06-10)* — CTAM Pathfinder supports **per-jurisdiction, per-region phased activation** — activation is a flag flip on `ctam_auth_user_activation_flags` keyed by the (jurisdiction, region) tuple, not a data migration. Initial flag state FALSE at bootstrap; cutover flips per wave by a DBA per the rollout runbook (no UI in MVP).
- **FR58** *(was FR59)* — Every CTAM Pathfinder service exposes a versioned API contract, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details for errors, and a published OpenAPI specification. Deprecation signalling uses the `Deprecation` header per [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) and the `Sunset` header per [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594).
- **FR59** *(was FR60)* — Every CTAM Pathfinder service emits structured logs with correlation IDs and consistent error categorisation, retained for pilot incident triage.
- **FR60** *(was FR61; reframed 2026-06-10[^d11][^d5]; wave sequence retargeted 2026-08-07[^d13])* — Every CTAM Pathfinder domain service has a **manual UAT script** verified by **jurisdiction-incumbent-experienced users** against that incumbent before the wave's rollout: `[ET-INCUMBENT-TBD]`-experienced users (ET role set *provisional* — G8.5) for **wave 1 (ET)**; ListAssist-experienced users (RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI) for **wave 2 (SSCS)**; APEX-experienced users (RSU, Court, Judge, Judges' Clerks, Finance, MI) for **waves 3+ (Courts)**. Explicit per-role sign-off; no automated incumbent-comparison harness. *(Wave-1 panel blocked on G8.4.)*

**Architectural support:** Per-service implementations bootstrapped from the HMCTS Crime SpringBoot template scaffolding; per-(jurisdiction, region) activation flags in `ctam-authorisation`; per-service `docs/uat/` for manual UAT scripts. *(The Phase 0 ETL at `ctam-architecture/migration/` is retracted — reference data arrives via the upstream ingestion mechanisms; user records are bootstrapped outside the PRD's scope.)*

[^d3]: Revised D3 (2026-06-10) — no data migration from any legacy system; judicial-holder reference data is ingested from the JOH eLinks API and MRD.
[^d5]: D5 — the jurisdiction's incumbent system is the behavioural reference, verified by manual UAT.
[^d9]: Restructured D9 (2026-06-10; refined 2026-07-09 per SCP) — two user populations. JOHs resolve IdP email → `jo_people` → `personnel_number` → a **CTAM-assigned JOH UUID** (`ctam_joh_identities`); HMCTS admin staff via a CTAM-internal identity table. Both key on a CTAM-assigned UUID; `personnel_number` is the upstream link only. No legacy user migration.
[^d10]: D10 (2026-05-15) — admin UI is post-MVP; MVP admin operations are DBA-via-SQL per operational runbooks.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
[^d12]: D12 (2026-06-10) — CTAM is the system of record for JOH availability and scheduling only; case and hearing management live in external systems.
