---
type: 'Architecture Shard'
description: 'CTAM Pathfinder inherits 17 application access types across four groups, plus 1 configuration entry (Payment Authoriser) that is not an application access type.'
resource: 'architecture/tobe/user-types.html'
tags: [ctam-pathfinder, architecture, employment-tribunals]
timestamp: '2026-05-12'
parent: ../architecture.md
title: User Types
last_updated: 2026-05-12
sources:
  - ../../../docs/architecture/asis/JI user types - 2.xlsx (authoritative as-is catalogue, Feb 2026 snapshot)
  - ../prd.md (FR1–FR5, FR40, FR57, FR60, User Journeys)
---

# User Types

> Sibling of [`../architecture.md`](../architecture.md). The as-is JI catalogue (`docs/architecture/asis/JI user types - 2.xlsx`, Feb 2026 snapshot) is authoritative for the role taxonomy. CTAM Pathfinder carries these access types over 1:1; this document is the binding taxonomy reference for `ctam-authorisation`, the user bootstrap (restructured D9 — two populations, no legacy user migration), and the per-phase manual UAT scripts (FR60). *(The taxonomy below is the Courts/JI as-is catalogue. Two extensions are outstanding[^d13]: the **ET as-is analysis pack** — gap G8.5, a **wave-1 blocker** — must extend it with ET access types before wave 1; the working set is **provisional** pending that pack: Regional Employment Judges, Employment Judges (salaried and fee-paid), non-legal ("lay") members from the employer-side and employee-side panels, and ET scheduling/listing admin staff. The **SSCS as-is analysis pack** extends it with SSCS access types — RTJ, Tribunal Judges, Tribunal Members, Caseworkers — before **wave 2**.)* Authentication is owned by HMCTS IdP (FR1); role + Region/Area mapping and effective-permission lookup live in `ctam-authorisation` (FR2, FR3). See [`./sequence-diagrams/user-authentication-and-authorisation.md`](./sequence-diagrams/user-authentication-and-authorisation.md) for the call path.
>
> **Baseline capability for every access type:** access to standard reports. The capability lists below add to this baseline rather than repeat it.

## At a glance

CTAM Pathfinder inherits **17 application access types** across four groups, plus **1 configuration entry** (Payment Authoriser) that is not an application access type. The as-is catalogue records **2,818 active users** as of Feb 2026.

| Group | Access types | Active users (Feb 2026) |
|---|---|---|
| [Court](#court-access-types) | 5 | 2,196 |
| [Regional](#regional-access-types) | 5 | 195 |
| [Judicial](#judicial-access-types) | 6 | 386 |
| [Finance](#finance-access-types) | 1 | 39 |
| **Application access types — total** | **17** | **2,816** |
| Configuration: [Payment Authoriser distribution list](#payment-authoriser-configuration-not-an-access-type) | — | 2 |
| **Catalogue total** | — | **2,818** |

## Sitting & booking lifecycle (Confirm → Verify → Re-open)

Several access types are defined by their position in the sittings/bookings release lifecycle. Recording this once here so the per-role capability lists can refer to it.

1. **Confirm** — A Court user (Full Access, Enhanced CJ, Limited) records that yesterday's sitting / booking took place, with actual work type and any AM/PM split. Performed daily.
2. **Verify** — A Verifier (Court or Regional) signs off batches of confirmed sittings / bookings, typically monthly. Verification locks the records and releases them to be reported on.
3. **Re-open** — Privileged correction action against a verified record. Granted to **Regional (Admin)** only at MVP (FR40). The re-opener must be different from the original confirmer (SIT-NFR-02); a mandatory justification is captured and the action is fully audited.

A Verifier **cannot** confirm sittings or bookings — confirmation and verification are separated by design (segregation of duties).

## Court access types

5 access types, 2,196 active users. Scope is the **office(s)** the user is assigned to.

### Court (Full Access) — 1,442 active users

Standard access level for users in the courts.

**Capabilities:**

1. Full access (view, create, maintain) to **District Judge** judge profiles only.
2. Confirm sittings for **all judge types** at assigned location(s).
3. Confirm bookings for **all judge types** at assigned location(s).
4. Request absences for judges at assigned location(s) — Regional team approval required.
5. Request vacancies for judges at assigned location(s) — Regional team approval required.

> Q2 resolution (2026-05-12): the xlsx description is not contradictory. Profile-maintenance access (full edit) is limited to DJ; sittings/bookings *confirmation* is location-scoped and works against all judge types. These are two distinct capabilities.

### Court (Enhanced CJ) — 224 active users

Enhanced access for court users in certain regions where Circuit Judge cover is required.

**Capabilities:**

1. All capabilities of Court (Full Access).
2. Additionally: full access (view, create, maintain) to **Circuit Judge** profiles.

### Court (Limited) — 132 active users

Limited access for court users. Same daily operational footprint as Full Access but without the judge-profile maintenance privilege.

**Capabilities:**

1. Confirm sittings for all judge types at assigned location(s).
2. Confirm bookings for all judge types at assigned location(s).
3. Request absences for judges at assigned location(s) — Regional team approval required.
4. Request vacancies for judges at assigned location(s) — Regional team approval required.

> Q3 resolution (2026-05-12) — *inferred from the xlsx description "as per Full Access but doesn't include full access to any judge types"*: the **only material difference** between Court (Limited) and Court (Full Access) is that Limited cannot maintain District Judge profiles. Confirmation of sittings/bookings, absence and vacancy requests are unchanged. Flagged in [`./gaps.md`](./gaps.md) for confirmation against incumbent-experienced UAT.

### Court (Read-only) — 27 active users

Read-only access for court users.

**Capabilities:**

1. View the same data set Court (Full Access) can view, with no write actions (no profile maintenance, no confirm, no requests).

### Court (Verifier) — 371 active users

Verifier access for court users. Performs step 2 of the sittings/bookings release lifecycle.

**Capabilities:**

1. **Cannot** confirm sittings or bookings.
2. Verify sittings that have been confirmed by another user (typically monthly).
3. Verify bookings that have been confirmed by another user.
4. View the same data set Court (Full Access) can view.

> Verification releases verified records for reporting. See [Sitting & booking lifecycle](#sitting--booking-lifecycle-confirm--verify--re-open).

## Regional access types

5 access types, 195 active users. Scope is the **Region** the user is assigned to, optionally narrowed by Area.

### Regional (Admin) — 75 active users

Regional user with elevated administrative powers.

**Capabilities:**

1. All capabilities of Regional (Full Access).
2. Send user-creation requests to the Advice Point (operational process to create new CTAM Pathfinder users for the region).
3. Re-open verified sittings / bookings (FR40, MVP-only privileged action). Mandatory justification, must differ from original confirmer (SIT-NFR-02), fully audited.

> Q11 from the xlsx (whether Regional Admin should create users directly without an external operational process) is parked as an CTAM Pathfinder design question. See [`./gaps.md`](./gaps.md).

### Regional (Full Access) — 68 active users

Standard access level for regional users.

**Capabilities:**

1. Full access (view, create, maintain) to records for **all judge types** in the region.
2. Create bookings for fee-paid judges.
3. Amend bookings for fee-paid judges.
4. Create absences for judges in the region.
5. Approve absences requested by Court users.
6. Create vacancies in the region.
7. Approve vacancies (e.g. auto-created from approved absences per FR23).
8. **Cannot** confirm sittings or bookings — confirmation is a Court-level function only.

### Regional (No Fees) — 14 active users

Restricted access for Regional users who must not transact on fee-paid bookings.

**Capabilities:**

1. All capabilities of Regional (Full Access) **except**:
2. Cannot create bookings for fee-paid judges.
3. Cannot amend bookings for fee-paid judges.

### Regional (Read-only) — 23 active users

Read-only access for Regional users.

**Capabilities:**

1. View the same data set Regional (Full Access) can view, with no write actions.

### Regional (Verifier) — 15 active users

Verifier access at Regional scope.

**Capabilities:**

1. All capabilities of Regional (Full Access).
2. Verify confirmed sittings for all courts in the region.
3. Verify confirmed bookings for all courts in the region.

> Q12 from the xlsx (national-level access): no national-level access type exists in the as-is catalogue except Finance. All other roles are scoped by Region/Area or by judge linkage. Recorded for CTAM Pathfinder parity.

## Judicial access types

6 access types, 386 active users. Scope varies — see each entry.

### Judge — 273 active users

Standard access level for a judge.

**Scope:** the judge's own record only (R2 — no case-level data, no access to other judges' data).

**Capabilities:**

1. View own record (profile, working pattern, tickets).
2. View own itinerary and forward look.
3. Request absences against own record where permitted (FR19) — Regional team confirmation may be required (FR20).

### Judge's Clerk — 2 active users

Clerk to a salaried judge, acting on the judge's behalf.

**Scope:** the linked judge(s) the clerk supports.

**Capabilities:**

1. Same capability surface as Judge, but exercised on behalf of the linked judge(s).

> Q7 from the xlsx (whether Judge's Clerk differs from Judge): the as-is catalogue records them as functionally identical from an access-control standpoint — the only distinction is *which* judge's record(s) the principal is linked to. CTAM Pathfinder maintains the separation for audit clarity (the Clerk acts on someone else's behalf).

### Presiding Judge — 2 active users

Leadership judge with oversight of a group of judges (typically a Circuit's salaried judges).

**Scope:** all judges who fall under the Presiding Judge's leadership.

**Capabilities:**

1. Same capability surface as Judge, exercised across all judges under their leadership.

> Q9 from the xlsx (why so few users): low headcount is structurally expected — there are very few presiding judges nationally. No CTAM Pathfinder design implication.

### Presiding Judge's Clerk — 0 active users

Clerk to a Presiding Judge.

**Scope:** the linked Presiding Judge's leadership group.

**Capabilities:**

1. Same capability surface as Presiding Judge, exercised on behalf of the linked Presiding Judge.

> **No active users in the as-is catalogue (Feb 2026).** Retained in the CTAM Pathfinder taxonomy for as-is parity (Q6 confirmed). The access type is provisioned but currently unused. Whether to retire it is an operational decision deferred to post-MVP review.

### Judge Itin View Only — 107 active users

CTSC (Courts and Tribunals Service Centre) operational users who need to know whether and where a judge is working.

**Scope:** national, but with significant data restrictions (see below).

**Capabilities:**

1. View judges' itineraries only — no profile, working pattern, absence, vacancy, booking, or sitting detail.
2. Massively cut-down information surface. Used operationally to identify (a) whether a judge is working on a given date and (b) where they are sitting.

> Q8 from the xlsx (exact contents of "very limited information"): the precise field set is not specified in the as-is catalogue. Captured as an open gap for the Itinerary service's API design — see [`./gaps.md`](./gaps.md) and the [Itinerary federated read sequence](./sequence-diagrams/itinerary-federated-read.md).

### Judicial College — 2 active users

Users within the Judicial College (training body for judges).

**Scope:** national, read-only.

**Capabilities:**

1. View a cut-down version of Court itineraries.
2. View Absences associated with those itineraries.
3. View Vacancies associated with those itineraries.
4. View Bookings associated with those itineraries.
5. **All views are read-only** — no write actions of any kind.

> Q5 from the xlsx (exact contents of the cut-down Court itinerary view): not specified in the as-is catalogue. Captured as an open gap for the Itinerary service — see [`./gaps.md`](./gaps.md).

## Finance access types

1 access type, 39 active users.

### Finance — 39 active users

Users within HMCTS finance who generate JFEPS payment schedules.

**Scope:** **National** — no Region/Area scoping. A Finance user can produce payment schedules covering all Regions/Areas.

**Capabilities:**

1. Produce payment schedules — JFEPS-compatible Excel — across all courts and circuits nationally.
2. Each generated schedule is automatically emailed to a configured Payment Authoriser (see [Payment Authoriser configuration](#payment-authoriser-configuration-not-an-access-type)).

> Q4 from the xlsx (scope of payment schedules): confirmed national — a Finance user can produce schedules across all areas (2026-05-12).

## Payment Authoriser (configuration, not an access type)

The Payment Authoriser is **not an CTAM Pathfinder application access type**. It is a **configuration entry** — the addressable identity (name + email) to whom Finance-generated JFEPS payment schedules are emailed for forwarding to Liberata.

**Modelling in CTAM Pathfinder:**

1. Stored as configuration, not as an authenticated principal.
2. The list of valid Payment Authoriser recipients is administrable (Phase 0 design decision: most likely the shared `ctam_configuration_values` infrastructure table or an admin-maintained reference list — to be finalised in the Payment service's design).
3. Finance users select a Payment Authoriser from this list when generating a payment schedule (FR43).
4. The recipient does **not** log into CTAM Pathfinder. They receive the JFEPS Excel by email and forward it to Liberata out-of-system (D6, unchanged from APEX).
5. The 2 individuals recorded against this entry in the as-is catalogue (Feb 2026) are tracked operationally but are not migrated as CTAM Pathfinder users in Phase 0[^d9].

## Administrative / cross-cutting roles

These are not user-facing access types in the as-is catalogue; they are CTAM Pathfinder-specific permissions overlaid on the taxonomy above.

| Role | Capabilities | Mapped to as-is access type | Key FRs |
|---|---|---|---|
| **System Administrator** | (1) Create users. (2) Update role and Region/Area assignments for migrated and new users. (3) Manage per-user activation flags for per-(jurisdiction, region) rollout (FR57). | New in CTAM Pathfinder — partially overlaps with Regional (Admin)'s Advice-Point request capability. | FR4, FR57 |
| **Re-opener** *(permission, not a separate role at MVP)* | (1) Re-open a verified sitting via the UI re-open action. (2) Must be different from the original confirmer (SIT-NFR-02). (3) Captures mandatory justification. (4) Fully audited. | Granted to **Regional (Admin)** only at MVP. | FR40 |
| **Reference Data Owner** *(business role overlaid on Regional)* | (1) Named-owner sign-off on Reference Data list changes (FR6). (2) Named-owner sign-off applies to tier-(b) CTAM-owned lists only — tier-(a) upstream-sourced data is corrected at source[^d3]. | Overlaid on Regional (Admin) / Regional (Full Access). | FR6, revised D3 |

## Authorisation model (summary)

- **Authentication:** HMCTS IdP via OIDC `authorization_code` (FR1). CTAM Pathfinder does not own password, session, or account lifecycle.
- **Authorisation state:** `ctam-authorisation` owns `ctam_auth_users`, `ctam_auth_roles`, `ctam_auth_user_roles`, `ctam_auth_user_region_scopes`, `ctam_auth_user_activation_flags`. Authoritative table ownership is recorded in [`./data-tables.md`](./data-tables.md).
- **Enforcement:** every API call resolves principal → role(s) + Region/Area scope through Authorisation; implemented as per-service middleware (FR2). Effective-permission lookup is `POST /authz/check` (FR3).
- **Phase 0 migration:** active APEX users + role/Region-Area scope assignments are loaded into CTAM Pathfinder via the Authorisation API and mapped to IdP principals (D9, Risk #14). Unmatched records get an explicit decision — drop / hold / manual map. Zero ambiguous migrations.
- **Per-user activation flag:** rollout gating uses `ctam_auth_user_activation_flags` keyed by (jurisdiction, region) (FR57) — migrated users do not use the incumbent; non-migrated users do not use CTAM Pathfinder[^d8][^d11].
- **Verifier separation of duties:** confirmation and verification of sittings/bookings must be performed by different principals — enforced at the application tier on the sitting/booking row's `confirmed_by` field. Re-open enforces a similar constraint (FR40).

## Manual UAT mapping (FR60)

Each domain service has a manual UAT script walked by jurisdiction-incumbent-experienced users from the in-wave applicable access types before that wave's rollout (`[ET-INCUMBENT-TBD]`-experienced users for **ET wave 1** — panel blocked on G8.4; ListAssist-experienced users for **SSCS wave 2**; APEX-experienced users for **Courts waves 3+**)[^d13].

| Service / phase | UAT access types |
|---|---|
| Reference Data, Authorisation, Notification (Phase 0) | Regional (Admin), System Administrator |
| Judge, Absence (Phases 1–2) | Regional (Full Access, Admin), Judge, Judge's Clerk |
| Vacancy (Phase 3) | Regional (Full Access, Admin, No Fees), Court (Full Access) |
| Booking (Phase 4) | Regional (Full Access, Admin, No Fees), Court (Full Access, Enhanced CJ) |
| Sitting (Phase 5) | Court (Full Access, Enhanced CJ, Limited, Verifier), Regional (Verifier) |
| Payment (Phase 6) | Finance, (Payment Authoriser as email recipient — out-of-band UAT) |
| Itinerary (Phase 7) | Judge, Judge's Clerk, Presiding Judge, Presiding Judge's Clerk *(if any user exists at time of UAT)*, Judge Itin View Only, Judicial College |
| MI Feed (Phase 8) | All access types verifying reports; primary owners: Regional and Finance |

## Related documents

- `docs/architecture/asis/JI user types - 2.xlsx` — authoritative as-is catalogue (Feb 2026)
- [`../prd.md`](../prd.md) — *Target users*, *User Journeys*, FR1–FR5, FR40, FR57, FR60
- [`./sequence-diagrams/user-authentication-and-authorisation.md`](./sequence-diagrams/user-authentication-and-authorisation.md) — authn / authz call path
- [`./data-tables.md`](./data-tables.md) — `ctam-authorisation` table inventory
- [`./gaps.md`](./gaps.md) — open questions inherited from the as-is catalogue
- [`./functional-requirements-coverage.md`](./functional-requirements-coverage.md) — per-FR architectural coverage

[^d3]: Revised D3 (2026-06-10) — no data migration from any legacy system; judicial-holder reference data is ingested from the JOH eLinks API and MRD.
[^d8]: D8 — rollout is jurisdiction-first, then per-region; jurisdiction is a first-class hierarchical attribute.
[^d9]: Restructured D9 (2026-06-10; refined 2026-07-09 per SCP) — two user populations. JOHs resolve IdP email → `jo_people` → `personnel_number` → a **CTAM-assigned JOH UUID** (`ctam_joh_identities`); HMCTS admin staff via a CTAM-internal identity table. Both key on a CTAM-assigned UUID; `personnel_number` is the upstream link only. No legacy user migration.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
