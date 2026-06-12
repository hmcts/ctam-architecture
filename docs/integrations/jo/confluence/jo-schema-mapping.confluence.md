# JO (eLinks) Integration — RAM Schema & Source Mapping

This document specifies the **RAM tables** that replicate the **eLinks (Judicial Office)** dataset, and the **column-level mapping** from the source API to RAM.

- Source: eLinks (a.k.a. JHR — Judicial HR) REST API, Data Dictionary v2.0 (2025-07-02).
- Source PDFs: `integrations/jo/eLinks Data Model_*.pdf`, `integrations/jo/eLinks Data Dictionary_*.pdf`.
- ER diagram: see the companion Confluence page **JO (eLinks) Integration — RAM ER Diagram**.

---

## 1. Design decisions

### 1.1 Naming
- Every replicated table uses the `jo_` prefix.
- Table names follow the source's endpoint/entity names, with **one disambiguation**:
  - The source has both a transactional `judiciary_roles[]` array (nested in `/people`) and a reference endpoint `/reference_data/judiciary_roles`. RAM splits these as:
    - `jo_judiciary_role_assignments` — the transactional assignment of a judiciary role to a person.
    - `jo_judiciary_roles` — the reference list of role names.
- Column names follow the source's `snake_case` attribute names verbatim, except where a source attribute is documented as a deprecated alias (see §1.3).

### 1.2 JOH lifecycle (`/people`, `/leavers`, `/deleted`)
The source exposes three endpoints that all describe the **same underlying person** (`judicial_office_holders` in JHR), filtered by lifecycle state. RAM models this as a **single `jo_people` table** keyed by `personal_code` (the only stable, never-reused identifier) with a `status` discriminator:

| Endpoint that fed the row | `jo_people.status` | Rule on receipt (per source "Actions to be taken") |
|---|---|---|
| `/people` (Current Office Holder) | `active` | Upsert by `personal_code`; full attributes populated. |
| `/leavers` (Leaver) | `leaver` | Upsert by `personal_code`; set `left_on`; **null out all PII** (title, names, email, work_phone, gender, disability, etc.) — keep only `personal_code`, `status`, `left_on`. |
| `/deleted` (Deleted) | `deleted` | Upsert by `personal_code`; set `deleted_on`; null out **everything** except `personal_code`, `status`, `deleted_on`. The source instruction is to delete the account; we soft-delete so that downstream RAM consumers can detect tombstones. |

Once a row is `deleted` it never becomes anything else (`personal_code` is not reused).

### 1.3 Deprecated source attributes — excluded
The following are present in the source dictionary but flagged DEPRECATED, so they are **not** replicated into RAM:

| Excluded | Use instead |
|---|---|
| `per_id` (integer alias of `personal_code`) | `personal_code` |
| `sex` | `gender` + `gender_id` |
| The old flat `authorisations[]` entity | `jo_authorisations_with_dates` |

### 1.4 Sync / refresh metadata — separate side table
Refresh status is **not** stored on functional tables. A single `jo_sync_status` table keyed by source endpoint tracks the cursor for incremental refresh. Source-provided `created_at`/`updated_at` timestamps **are** kept on tables that expose them, because they describe the source row (and are needed for the `updated_since` cursor on `/people`).

### 1.5 Foreign-key strategy
- Reference table PKs use the source integer `id` (= JHR `integration_id`), which the source guarantees stable across JHR releases and across Staging/Production.
- Transactional table PKs use the source-assigned id (`appointment_id`, `judiciary_role_id`, `authorisation_id`) — also guaranteed unique by JHR.
- `jo_people.personal_code` is a `VARCHAR` (it can contain alphanumerics like `"A3447"`).
- Denormalised name columns (e.g. `jo_appointments.role_name`, `jo_appointments.contract_type`) are **preserved as the source provides them** so RAM consumers can read without joining. The integer FK column is the authoritative link.

### 1.6 Special case — `authorisations_with_dates.jurisdiction_id`
The source documents an edge case: when an authorisation's `jurisdiction == "Courts"`, the source returns the **ticket-category id** in the `jurisdiction_id` attribute (not a real jurisdiction id). RAM faithfully replicates this — `jo_authorisations_with_dates.jurisdiction_id` is FK to `jo_jurisdictions` **unless** `jurisdiction = 'Courts'`, in which case it is FK to `jo_ticket_categories`. The same quirk applies to the string `jurisdiction` column (it carries the ticket category name when source jurisdiction is `Courts`). This is the source's behaviour, not a RAM transformation.

### 1.7 Location data — constraints and warnings
Location data in `jo_appointments` has several important constraints documented by the source:

- **Belongs to the Appointment, not the JOH** — a JOH with multiple Appointments may indirectly have multiple locations. Location describes the contractual context of the Appointment, not where the JOH is physically working.
- **Set at appointment creation, not updated** — location is captured when the Appointment is created and is not subsequently maintained. It may not reflect the JOH's current work location.
- **Cross-type location IDs are unrelated** — location IDs for identically-named geographic areas across different entity types are entirely separate records with different IDs. For example, the "South East" region for Coroners (`CORONERS_REGION`) has a different `id` from "South East" for LJAs (`MAGS_REGION`). Do not compare or join location data across entity types using IDs.
- **Tribunals chamber is not directly surfaced** — for Tribunal appointments, TRIBS_CHAMBER (level 2 of the hierarchy) has no dedicated attribute. To retrieve it: follow `jo_appointments.base_location_id` → `jo_base_locations.parent_id` → `jo_locations.id`. That `jo_locations` row is the chamber.

---

## 2. Table list

| # | RAM table | Category | Source endpoint / path |
|---|---|---|---|
| 1 | `jo_people` | Transactional | `/people`, `/leavers`, `/deleted` (merged) |
| 2 | `jo_appointments` | Transactional | `/people` → `appointments[]` |
| 3 | `jo_judiciary_role_assignments` | Transactional | `/people` → `judiciary_roles[]` |
| 4 | `jo_authorisations_with_dates` | Transactional | `/people` → `authorisations_with_dates[]` |
| 5 | `jo_appointment_titles` | Reference | `/reference_data/appointment_titles` |
| 6 | `jo_base_locations` | Reference | `/reference_data/base_locations` |
| 7 | `jo_contract_types` | Reference | `/reference_data/contract_types` |
| 8 | `jo_genders` | Reference | `/reference_data/genders` |
| 9 | `jo_judiciary_roles` | Reference | `/reference_data/judiciary_roles` |
| 10 | `jo_jurisdictions` | Reference | `/reference_data/jurisdictions` |
| 11 | `jo_locations` | Reference | `/reference_data/locations` |
| 12 | `jo_location_types` | Reference | `/reference_data/location_types` |
| 13 | `jo_tickets` | Reference | `/reference_data/tickets` |
| 14 | `jo_ticket_categories` | Reference | `/reference_data/ticket_categories` |
| 15 | `jo_ticket_category_types` | Reference | `/reference_data/ticket_category_types` |
| 16 | `jo_sync_status` | RAM-internal | (none — populated by sync job) |

---

## 3. Column mappings

For every mapping table below:
- **RAM column** — column name in the RAM database.
- **Type** — proposed RAM column type (Postgres-flavoured; adjust to RAM's chosen DBMS).
- **PK / FK** — primary key / foreign key designation.
- **Source attribute** — the attribute name in the source API response (or the JHR table.column where the dictionary makes it explicit).
- **Notes / example** — transformation, nullability, deprecation, example value.

### 3.1 `jo_people`

> Replicated from `/people`, `/leavers`, `/deleted`. One row per physical JOH, keyed by `personal_code`. Lifecycle is encoded in `status`.

| RAM column | Type | Key | Source attribute (per state) | Notes / example |
|---|---|---|---|---|
| `personal_code` | VARCHAR(32) | PK | `personal_code` (all 3 endpoints) | The only guaranteed-unique, never-reused identifier. `"49728416"`, `"A3447"`. |
| `status` | VARCHAR(16) | — | *derived* | `'active'` when sourced from `/people`, `'leaver'` from `/leavers`, `'deleted'` from `/deleted`. |
| `ad_object_id` | VARCHAR(64) | — | `id` (Master:eJ Active Directory Object Id) | eJ AD object id. Active/Leaver only. **Not** a unique key — eJ may reassign it. Null for `deleted`. |
| `title` | VARCHAR(64) | — | `title` (JHR:judicial_office_holders.judicial_title \| .civil_title_id) | Active only. `"His Honour Judge"`, `"Mrs"`. |
| `known_as` | VARCHAR(128) | — | `known_as` (JHR:judicial_office_holders.known_as) | Active only. Nickname/short/middle name; otherwise first name. |
| `surname` | VARCHAR(128) | — | `surname` (JHR:judicial_office_holders.last_name) | Active only. |
| `fullname` | VARCHAR(256) | — | `fullname` (JHR:calculated) | Active only. Includes postnominals. |
| `initials` | VARCHAR(16) | — | `initials` (JHR:calculated) | Active only. |
| `post_nominals` | VARCHAR(64) | — | `post_nominals` (JHR:judicial_office_holders.post_nominals) | Active only. e.g. `"JP OBE"`. |
| `email` | VARCHAR(256) | — | `email` (Master:eJ \| JHR:ejudiciary_email_address) | Active only. **Not** unique — eJ may change/reuse. |
| `email_personal` | VARCHAR(256) | — | `email_personal` (JHR:personal_email_address) | Active only. May be null (partial coverage as of source doc). |
| `gender` | VARCHAR(32) | — | `gender` (JHR:equal_opportunities_records.gender_id) | Active only. Denormalised name. |
| `gender_id` | INT | FK → `jo_genders.id` | `gender_id` (JHR:equal_opportunities_records.gender_id) | Active only. |
| `work_phone` | VARCHAR(32) | — | `work_phone` (JHR:contact_methods.value) | Active only. Picked from work phone/mobile in order. |
| `disability` | BOOLEAN | — | `disability` (JHR:diversity_records.disability_answer_id) | Active only. |
| `retirement_date` | DATE | — | `retirement_date` (JHR:judicial_office_holders.compulsory_retirement_date) | Active only. Compulsory retirement date. |
| `leaving_on` | DATE | — | `leaving_on` (JHR:judicial_office_holders.leaving_on_date) | Active only. Auto-set to latest `appointment.end_date`. |
| `left_on` | DATE | — | `left_on` (`/leavers` only) | Leaver only. Date the JOH left. |
| `deleted_on` | DATE | — | `deleted_on` (`/deleted` only) | Deleted only. |

**Excluded (deprecated in source):** `per_id`, `sex`, `authorisations[]`.

**Note** the nested arrays (`appointments[]`, `judiciary_roles[]`, `authorisations_with_dates[]`) are **not** columns on `jo_people` — they each land in their own table, linked back via `personal_code`. `authorisations_current[]` is not synced — RAM derives current authorisations internally from `jo_authorisations_with_dates`.

### 3.2 `jo_appointments`

> Replicated from `/people` → `appointments[]`. Each appointment describes an instance of the person being appointed to a role at a location, under a contract type.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `appointment_id` | INT | PK | `appointment_id` (JHR:appointment.id) | Source-assigned, unique. `145094`. |
| `personal_code` | VARCHAR(32) | FK → `jo_people.personal_code` | (parent in `/people` array) | Link to parent JOH. |
| `role_name` | VARCHAR(128) | — | `role_name` (JHR:appointment_histories.appointment_title_id) | Denormalised role display name. `"Circuit Judge"`. |
| `role_name_id` | INT | FK → `jo_appointment_titles.id` | `role_name_id` (JHR:appointment_histories.appointment_title_id) | Stable FK. |
| `type` | VARCHAR(32) | — | `type` (JHR:appointment_histories.location_id) | Static text from source. One of: `"Tribunals"`, `"Advisory Committee"`, `"LJA"`, `"Courts"`, `"Mags Area Committee"`, `"Mags Area Sub Committee"`, `"Mags Court"`, `"Coroners"`. |
| `court_name` | VARCHAR(128) | — | `court_name` (JHR:appointment_histories.location_id) | Lowest named entity in the location hierarchy (varies by `type`). e.g. `"Morpeth County Court"` for Courts, `"Surrey LJA"` for LJA, `"North East"` for Tribunals. |
| `court_type` | VARCHAR(128) | — | `court_type` (JHR:appointment_histories.location_id) | Mid-level entity (varies by `type`). e.g. parent AC for Mags types, Tier for Tribunals (`"First Tier Tribunal"`). NULL for Courts. |
| `circuit` | VARCHAR(128) | — | `circuit` (JHR:appointment_histories.location_id) | **Courts only** (= COURTS_REGION, e.g. `"North East"`). NULL for all other types. |
| `bench` | VARCHAR(128) | — | `bench` (JHR:appointment_histories.location_id) | **LJA** (= MAGS_AC_LJA) and **Mags Court** (= MAGS_AC_COURT_NAME) only. NULL for all other types. |
| `advisory_committee_area` | VARCHAR(128) | — | `advisory_committee_area` (JHR:appointment_histories.location_id) | **LJA** (= MAGS_AC) and **Mags Court** (= MAGS_AC) only. NULL for all other types. |
| `location` | VARCHAR(128) | — | `location` (JHR:appointment_histories.location_id) | Geographic area. For all non-Tribunal types this is the top-level region (e.g. `"North East"`). **For Tribunals**, this is TRIBS_LOCATION (the specific venue name, not a broad region). |
| `base_location` | VARCHAR(256) | — | `base_location` (JHR:appointment_histories.location_id) | Denormalised name of the leaf location. `"Reading Magistrates Court"`. **For Tribunals**, the source concatenates Chamber and Location: `"Social Entitlement Chamber - North East"`. |
| `base_location_id` | INT | FK → `jo_base_locations.id` | `base_location_id` (JHR:appointment_histories.location_id) | Lowest level of the location hierarchy. |
| `is_principal` | BOOLEAN | — | `is_principal` (JHR:appointmnet.primary) | Exactly one principal Appointment per Current Office Holder. |
| `start_date` | DATE | — | `start_date` (JHR:appointment_histories.start_date) | |
| `end_date` | DATE | — | `end_date` (JHR:appointment_histories.end_date) | May be future-dated unless `include_previous_appointments=true` requested. |
| `contract_type` | VARCHAR(64) | — | `contract_type` (JHR:appointment_histories.contract_type_id) | Denormalised. `"Fee-paid"`, `"Salaried"`. |
| `contract_type_id` | INT | FK → `jo_contract_types.id` | `contract_type_id` (JHR:appointment_histories.contract_type_id) | |

### 3.3 `jo_judiciary_role_assignments`

> Replicated from `/people` → `judiciary_roles[]`. Records a JOH having been designated with a named judiciary role (applied to the person, not to an appointment).

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `judiciary_role_id` | INT | PK | `judiciary_role_id` (JHR) | Unique id of the assignment. `145094`. |
| `personal_code` | VARCHAR(32) | FK → `jo_people.personal_code` | (parent in `/people` array) | |
| `name` | VARCHAR(128) | — | `name` (JHR) | Denormalised role name. `"Bench Chair"`. |
| `judiciary_role_name_id` | INT | FK → `jo_judiciary_roles.id` | `judiciary_role_name_id` (JHR) | FK to the reference role list. |
| `start_date` | DATE | — | `start_date` (JHR) | |
| `end_date` | DATE | — | `end_date` (JHR) | |

### 3.4 `jo_authorisations_with_dates`

> Replicated from `/people` → `authorisations_with_dates[]`. The detailed view of every ticket the person has been authorised on (current and historic).

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `authorisation_id` | INT | PK | `authorisation_id` (JHR) | Unique. `135337`. |
| `personal_code` | VARCHAR(32) | FK → `jo_people.personal_code` | (parent in `/people` array) | |
| `appointment_id` | INT | FK → `jo_appointments.appointment_id` | `appointment_id` (JHR) | Nullable. Source guarantees population after August 2025; older rows may be null. |
| `jurisdiction` | VARCHAR(64) | — | `jurisdiction` (JHR) | When source jurisdiction is `Courts`, carries the **ticket-category name** instead (`"Civil"`, `"Family"`, `"Tribunals"`). |
| `jurisdiction_id` | INT | FK (conditional) | `jurisdiction_id` (JHR) | Normally FK → `jo_jurisdictions.id`. **When `jurisdiction = 'Courts'`** → FK → `jo_ticket_categories.id` (this is the source's documented behaviour, not a RAM transformation). |
| `ticket` | VARCHAR(256) | — | `ticket` (JHR) | Denormalised ticket name. `"03 - Disability Living Allowance"`. |
| `ticket_id` | INT | FK → `jo_tickets.id` | `ticket_id` (JHR) | |
| `start_date` | DATE | — | `start_date` (JHR) | |
| `end_date` | DATE | — | `end_date` (JHR) | |

### 3.5 `jo_appointment_titles`

> Reference list of appointment role names. Referenced by `jo_appointments.role_name_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | Stable across JHR releases and Staging↔Production. |
| `name` | VARCHAR(128) | — | `name` | `"Magistrate"`, `"Deputy District Judge - Fee-paid"`. |
| `start_date` | DATE | — | `start_date` | Selectable-from date; null = unconstrained. |
| `end_date` | DATE | — | `end_date` | Selectable-to date; null = unconstrained. |
| `created_at` | TIMESTAMP | — | `created_at` | Source row creation. |
| `updated_at` | TIMESTAMP | — | `updated_at` | Source row update. |

### 3.6 `jo_base_locations`

> Reference list of locations to which an appointment can be attached. Referenced by `jo_appointments.base_location_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(256) | — | `name` | `"Manchester Civil Justice Centre"`. Denormalised in `jo_appointments.base_location` EXCEPT for Tribunals. |
| `type_id` | INT | FK → `jo_location_types.id` | `type_id` | |
| `parent_id` | INT | FK → `jo_locations.id` | `parent_id` | Parent in the location hierarchy. |
| `jurisdiction_id` | INT | FK → `jo_jurisdictions.id` (hard-coded) | `jurisdiction_id` | Hard-coded enum: 1 Courts, 2 Tribunals, 3 Magistrates, 4 Coroners. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

**Tribunals chamber traversal** — For Tribunal appointments, `jo_appointments.base_location_id` points to a TRIBS_LOCATION (leaf node). TRIBS_CHAMBER (one level up) is not surfaced as a standalone appointment attribute; retrieve it by following `jo_base_locations.parent_id` → `jo_locations.id`. That `jo_locations` row is the chamber (see §1.7).

### 3.7 `jo_contract_types`

> Reference list of appointment contract types. Referenced by `jo_appointments.contract_type_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(64) | — | `name` | `"Salaried"`, `"Fee-paid"`, `"Voluntary"`, `"SPTW-50%"`. |
| `salaried` | BOOLEAN | — | `salaried` | Whether this contract type is salaried. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.8 `jo_genders`

> Reference list of gender values. Referenced by `jo_people.gender_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(32) | — | `name` | `"Male"`, `"Female"`, `"Other"`, `"Prefer not to say"`. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.9 `jo_judiciary_roles` (reference list)

> Reference list of judiciary role names. Referenced by `jo_judiciary_role_assignments.judiciary_role_name_id`. **Note** — not to be confused with the transactional `jo_judiciary_role_assignments`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(128) | — | `name` | `"International Committee Member"`, `"Sentencing Council"`, `"Appraisal Judge"`. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.10 `jo_jurisdictions`

> Reference list of jurisdictions. Referenced by ticket-related and location-related tables.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(64) | — | `name` | `"Courts"`, `"Tribunals"`, `"Magistrates"`, `"Coroners"`, `"Skills"`. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.11 `jo_locations`

> Reference list of **all** locations (the whole hierarchy). `jo_base_locations` is a subset of this (locations an appointment can attach to).

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(256) | — | `name` | `"Manchester Civil Justice Centre"`, `"Wiltshire LJA"`, `"Other Tribunal"`, `"National"`. |
| `type_id` | INT | FK → `jo_location_types.id` | `type_id` | |
| `parent_id` | INT | FK → `jo_locations.id` (self) | `parent_id` | Self-referencing hierarchy. |
| `jurisdiction_id` | INT | FK → `jo_jurisdictions.id` (hard-coded) | `jurisdiction_id` | Hard-coded enum: 1 Courts, 2 Tribunals, 3 Magistrates, 4 Coroners. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.12 `jo_location_types`

> Reference list of location-hierarchy types. Referenced by `jo_locations.type_id` and `jo_base_locations.type_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(64) | — | `name` | `"Court"`, `"Area or Parent AC"`, `"Chamber"`. |
| `jurisdiction_id` | INT | FK → `jo_jurisdictions.id` (hard-coded) | `jurisdiction_id` | |
| `integration_code` | VARCHAR(64) | — | `integration_code` | `"MAGS_AREA_OR_PARENT_AC"`, `"COURTS_COURT_NAME"`. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.13 `jo_tickets`

> Reference list of ticket (authorisation competency) names. Referenced by `jo_authorisations_with_dates.ticket_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(256) | — | `name` | `"Welsh Language"`, `"Chancery"`, `"Attempted Murder"`. |
| `ticket_category_id` | INT | FK → `jo_ticket_categories.id` | `ticket_category_id` | |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.14 `jo_ticket_categories`

> Reference list of ticket categories (hierarchy). Referenced by `jo_tickets.ticket_category_id` and by `jo_authorisations_with_dates.jurisdiction_id` when `jurisdiction = 'Courts'`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(256) | — | `name` | `"Environment"`, `"Direct and Indirect Taxation"`, `"Appeals in Crown Court"`. |
| `type_id` | INT | FK → `jo_ticket_category_types.id` | `type_id` | Courts / Tribs / Skills etc. |
| `jurisdiction_id` | INT | FK → `jo_jurisdictions.id` (hard-coded) | `jurisdiction_id` | |
| `parent_category_id` | INT | FK → `jo_ticket_categories.id` (self) | `parent_category_id` | Self-referencing hierarchy. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.15 `jo_ticket_category_types`

> Reference list of ticket-category types. Referenced by `jo_ticket_categories.type_id`.

| RAM column | Type | Key | Source attribute | Notes / example |
|---|---|---|---|---|
| `id` | INT | PK | `id` (JHR:integration_id) | |
| `name` | VARCHAR(64) | — | `name` | `"Court Type"`, `"Skills Category"`, `"Tribunal Name"`. |
| `jurisdiction_id` | INT | FK → `jo_jurisdictions.id` (hard-coded) | `jurisdiction_id` | |
| `integration_code` | VARCHAR(64) | — | `integration_code` | `"COURTS_COURT_TYPE"`, `"SKILLS_CATEGORY"`, `"TRIBS_NAME"`. |
| `start_date` | DATE | — | `start_date` | |
| `end_date` | DATE | — | `end_date` | |
| `created_at` | TIMESTAMP | — | `created_at` | |
| `updated_at` | TIMESTAMP | — | `updated_at` | |

### 3.16 `jo_sync_status` (RAM-internal, no source mapping)

> One row per source endpoint, maintained by the RAM ingestion job. Holds the cursor used for incremental refresh and the outcome of the last run.

| RAM column | Type | Key | Notes |
|---|---|---|---|
| `source_endpoint` | VARCHAR(128) | PK | e.g. `/people`, `/leavers`, `/deleted`, `/reference_data/tickets`. |
| `last_synced_at` | TIMESTAMP | — | When the last sync run started. |
| `last_successful_sync_at` | TIMESTAMP | — | When the last successful sync completed. |
| `last_status` | VARCHAR(16) | — | `success` \| `failed` \| `in_progress`. |
| `last_error_message` | TEXT | — | Null when last run succeeded. |
| `records_processed` | INT | — | Count from the last run. |
| `last_since_param` | DATE | — | Cursor value sent on next call as `updated_since` / `left_since` / `deleted_since`. |

---

## 4. Refresh strategy (informational)

- **Transactional** endpoints (`/people`, `/leavers`, `/deleted`) accept `updated_since` / `left_since` / `deleted_since` and are **paginated** (`per_page` < 200, `page`). Use `jo_sync_status.last_since_param` to drive incremental pulls.
- **Reference** endpoints are not paginated and have no `since` parameter — pull the whole list each refresh; replace-by-id is simplest.
- On receipt of a `/leavers` record: set `jo_people.status='leaver'`, populate `left_on`, null out PII columns per source rule.
- On receipt of a `/deleted` record: set `jo_people.status='deleted'`, populate `deleted_on`, null out everything else (soft tombstone for downstream RAM consumers).
- **`personal_code` is the only safe matching key** — never match on `id` (AD object id) or `email`, both of which the source warns can change or be reused.

---

## 5. Data warnings

The following warnings describe known limitations of the eLinks source data and API that affect freshness, completeness, and reliability of data in RAM. These are characteristics of the source — not defects in the sync implementation — and must be understood by anyone building on or consuming RAM data.

| # | Warning | Affected fields | RAM's behaviour |
|---|---|---|---|
| W1 | **Location fields are frozen at appointment creation and never updated by eLinks** | `jo_appointments`: `type`, `court_name`, `court_type`, `circuit`, `bench`, `advisory_committee_area`, `location`, `base_location`, `base_location_id` | Replicate faithfully but treat as appointment-creation snapshot only. RAM must not use these fields to infer where a JOH is currently working. Expose sync timestamp so consumers know the as-at date. |
| W2 | **Long-dormant leavers may be silently absent from the `/leavers` feed** | `jo_people.status` | Treat `status = 'active'` as "active according to last eLinks sync", not a definitive guarantee. As a compensating control, RAM should flag appointments whose `end_date` has passed but whose owner is still `active`, surfacing them for manual review. |
| W3 | **`email` changes over time and can be reused** | `jo_people.email` | Treat as a display/contact field only — never as a lookup or join key. Direct all consumers to use `personal_code` as the only stable identity. Staleness within a sync window is expected and accepted. |
| W4 | **`ad_object_id` changes over time and can be reused** | `jo_people.ad_object_id` | Same as W3. Treat as informational only. Never use as a join key or identity anchor. `personal_code` is the only safe key. |
| W5 | **`is_principal` can flip between sync cycles** as appointments are created or expire | `jo_appointments.is_principal` | Treat `is_principal = true` as accurate as-at the last sync timestamp only. Consumers must not cache or independently persist this flag outside of RAM's own data. |
| W6 | **Reference data has no incremental sync mechanism** — no `updated_since` parameter exists on any `/reference_data/*` endpoint | All denormalised name columns (e.g. `role_name`, `contract_type`, `base_location`) | Sync all reference endpoints in full on every sync cycle. Always run the reference data sync **before** processing transactional data in that cycle so FKs and denormalised names are never out of step. |
| W7 | **`appointment_id` is null on authorisation records created before August 2025** | `jo_authorisations_with_dates.appointment_id` | Accept and store nulls. All queries joining `jo_authorisations_with_dates` to `jo_appointments` via this field must use a LEFT JOIN. This is a permanent historical gap — no remediation is possible. |
| W8 | **`email_personal` is sparsely populated** — 3,724+ active JOHs had no value as of the source document date (Oct 2024) | `jo_people.email_personal` | Accept and store nulls. Treat as optional/best-effort data. Downstream consumers must not assume population. No remediation is possible; coverage depends on JOHs supplying the data to JHR. |
| W9 | **The eLinks API spec is a living document** and may change without formal notification | Whole integration | Establish a periodic review cadence against the eLinks Swagger documentation. Changes to the spec may require updates to sync logic, RAM schema, and this mapping document. |
