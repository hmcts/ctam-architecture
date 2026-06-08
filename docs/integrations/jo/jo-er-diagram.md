# JO (eLinks) Integration — RAM ER Diagram

Source system: **Judicial Office eLinks** (backed by JHR — Judicial HR). All RAM tables that hold a replicated copy of eLinks data use the `jo_` prefix. The full column-level source→RAM mapping is in [jo-schema-mapping.md](./jo-schema-mapping.md).

## Conventions

- **Transactional** tables (white in source diagram): person and the things owned by a person (appointments, judiciary role assignments, authorisations).
- **Reference** tables (blue in source diagram): lookup data refreshed from the `/reference_data/*` endpoints.
- All reference and many transactional rows carry the source's own integer `id` — RAM preserves that as the primary key so foreign keys keep working across refreshes (the source guarantees these `id`s are stable across releases and environments).
- `jo_people` is keyed by `personal_code` — the only attribute the source guarantees is unique and never reused (do **not** key on `id`, `email` or `per_id`).
- Deprecated source attributes (`per_id`, `sex`, the old flat `authorisations` array) are excluded.

## Naming clash — note

The source has a transactional `judiciary_roles[]` array on `/people` **and** a reference endpoint `/reference_data/judiciary_roles`. To avoid a table-name clash in RAM:

| Source | RAM table |
|---|---|
| `people.judiciary_roles[]` (transactional assignment) | `jo_judiciary_role_assignments` |
| `/reference_data/judiciary_roles` (lookup) | `jo_judiciary_roles` |

This is the only deviation from a strict 1:1 source→RAM name mapping.

## Sync metadata

Per the agreed approach, refresh-status columns (`last_synced_at`, page cursor, last error, etc.) live in a **single side table** `jo_sync_status` keyed by source endpoint — they are not duplicated on every functional table. Source-provided `created_at` / `updated_at` are kept on the tables that the source exposes them on, because they describe the source row (not RAM's sync).

---

## Diagrams

The diagrams are kept as standalone `.mmd` files so they render reliably in VS Code Mermaid extensions (and in any other Mermaid-aware tool):

| Diagram | File | Description |
|---|---|---|
| Full ER diagram | [`jo-er-diagram-full.mmd`](./jo-er-diagram-full.mmd) | All 17 tables — transactional, reference and sync. |
| Transactional core | [`jo-er-diagram-core.mmd`](./jo-er-diagram-core.mmd) | `jo_people` and its direct children only — the most useful slice for day-to-day JOH queries. |

### How to view in VS Code

Install one of:

- **Markdown Preview Mermaid Support** (`bierner.markdown-mermaid`) — then open a `.mmd` file and run *"Mermaid: Preview"* from the command palette, or
- **Mermaid Editor** (`tomoyukim.vscode-mermaid-editor`) — opens `.mmd` files in a live preview pane with export-to-SVG/PNG.

Either extension will render the `.mmd` files directly. The diagrams are also valid input to the Mermaid CLI (`mmdc -i jo-er-diagram-full.mmd -o jo-er-diagram-full.svg`) if you want to commit rendered images.
