# JO (eLinks) ER Diagrams — Redo Design

**Date:** 2026-06-15
**Status:** Approved

## Problem

The JO ER diagrams under `docs/integrations/jo/diagrams/` are authored in PlantUML
(rendered via Graphviz `dot`). The full 16-table diagram is unreadable:

- **No magnet control** — PlantUML ER syntax connects *table-to-table*, so every FK
  into a hub table (e.g. `jo_jurisdictions` → 6 tables, `jo_authorisations_with_dates`
  → 4) lands on the same box edge. You cannot tell which line is which.
- **Crossings** — 20 edges over 16 tables on one auto-laid-out canvas criss-cross.
- **One giant canvas** — unrelated clusters (person, location, ticket) compete for space.

## Decision

1. **Tool:** Replace PlantUML with **D2** (`D2_LAYOUT=elk`). D2's `sql_table` shape lets
   FKs connect *field-to-field* (`jo_appointments.base_location_id -> jo_base_locations.id`)
   so each relationship gets its own connection point on its own row — the OmniGraffle
   "multiple magnet" principle. ELK routes orthogonally and minimises crossings.
2. **Structure:** Decompose into focused cluster views plus one full reference view.
3. **Styling:** Light theme via `theme-overrides` — navy header, white rows, blue field
   names, PK/FK badges, shown column types. Matches the prior `#FAFBFC`/`#4C6B8A` look.

## Diagram set

| File | Tables | Purpose |
|---|---|---|
| `jo-er-core.d2` | people, appointments, role_assignments, authorisations + person lookups (genders, appointment_titles, contract_types, judiciary_roles) | day-to-day slice |
| `jo-er-location.d2` | locations, base_locations, location_types | location cluster |
| `jo-er-ticket.d2` | tickets, ticket_categories, ticket_category_types | ticket cluster |
| `jo-er-reference-hub.d2` | jurisdictions → all consumers; sync_status | the fan-out hub on its own |
| `jo-er-full.d2` | all 16 | reference view, now with field-level magnets + ELK |

Cross-cluster FKs are shown as **external stub boxes** (dashed/grey, key field only) so
each cluster is self-contained while signposting where the foreign table lives — the way
OmniGraffle handles cross-page references.

## Conventions carried over

- `jo_people` keyed by `personal_code`; reference tables keyed by source `id`.
- Two-jurisdiction edge case: `jo_authorisations_with_dates.jurisdiction_id` → either
  `jo_jurisdictions` (non-Courts) or `jo_ticket_categories` (Courts). Both edges drawn
  from the same FK row with labels.
- `jo_sync_status` has no FKs (keyed by source endpoint) — shown standalone in the hub view.

## Render pipeline

- Each `.d2` renders to `.png` (Confluence embed) and `.svg` (crisp markdown preview).
- A shared `_jo-er-style.d2` holds `vars.d2-config.theme-overrides` + classes, imported via
  spread (`...@_jo-er-style`).
- `scripts/export.sh` updated to render all five in one command.
- Docs updated: `jo-er-diagram.md`, `confluence/README.md` (PlantUML → D2), and the
  Confluence HTML re-embeds the new PNGs.

## Out of scope

- No schema/content changes; `jo-schema-mapping.md` untouched.
- Old `.puml` sources retained pending explicit deletion approval.
