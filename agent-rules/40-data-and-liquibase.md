---
id: agent-rules/data
title: Persistence, entities and Liquibase (P1–P16)
status: draft
last_updated: 2026-08-19
---

# Persistence, entities and Liquibase

> Table names, prefixes, PK/FK conventions, audit columns and the authoritative ownership mapping live in `_arch/architecture/conventions.md` → *Naming Patterns* and `_arch/architecture/data-tables.md`. **Read those before writing a changelog.** This file governs how you change the schema safely.
>
> The single shared PostgreSQL schema is the highest-consequence surface in the programme: a migration is the one thing you cannot fix forward without a second migration, and every other service is in the same database (`gaps.md` G6 series).

## Migrations

### P1 — Liquibase, DDL only

Schema changes go in `src/main/resources/db/changelog/NNN-name.sql`, registered in `db.changelog-master.yaml`. **Flyway is prohibited** (`project-context.md`). Liquibase carries DDL, index and grant statements, plus seed rows for **CTAM-owned static vocabularies**. It never loads upstream data — `jo_*` / `mrd_*` content arrives only through `ctam-reference-data` ingestion.

### P2 — Applied changesets are immutable

Never edit, renumber, or delete a changeset that has run anywhere. Liquibase checksums it; changing it breaks every environment that already applied it. **Always fix forward** with a new changeset.

### P3 — One logical change per changeset, with a rollback

Each changeset does one thing and declares its rollback (`--rollback` in a formatted SQL changelog). A changeset you cannot roll back needs a stated reason in a comment.

### P4 — You may only change tables you own

Ownership is the table prefix plus `data-tables.md`. Creating, altering, or dropping a table outside your service's ownership is prohibited — that includes "just adding a column" to a table another service owns. Cross-service `GRANT`s live in the **owning** service's changelog (`gaps.md` G6.4). Consuming a column another service owns makes you a consumer of their deprecation cadence (G6.1) — a stop (**R5**) if the story does not name it.

### P5 — `jo_*` and `mrd_*` are read-only

No `INSERT`, `UPDATE`, `DELETE`, or DDL against upstream-sourced tables from any service other than `ctam-reference-data`'s ingestion path. No JPA entity mapped to them is writable — map them read-only.

### P6 — Every migration is proved against real PostgreSQL

An `*IT.java` runs the changelog from an empty database via Testcontainers and asserts the resulting shape and the behaviour that needed it (**T8**). H2 or any in-memory substitute is prohibited: it accepts SQL that PostgreSQL rejects, so a green suite would tell you nothing.

### P7 — Entity and changelog must agree

Integration tests run with schema validation on (`spring.jpa.hibernate.ddl-auto=validate`). `ddl-auto` values that create or mutate schema (`create`, `create-drop`, `update`) are prohibited in every profile — the changelog is the only thing that changes the database.

## Entities

### P8 — Entities model state, not behaviour and not the API

`@Entity` types live in `domain/`, stay free of business orchestration, and never cross the controller boundary (**M12**). No `@Data` on an entity — Lombok's generated `equals`/`hashCode` over all fields (including lazy associations) is a documented source of subtle bugs. Use `@Getter`, explicit setters where genuinely needed, and `equals`/`hashCode` on the `id` alone.

### P9 — Associations are lazy, narrow, and never cascade-delete

`FetchType.LAZY` on every association (`@ManyToOne` defaults to EAGER — override it). Add a bidirectional relationship only when both directions are actually navigated. `CascadeType.REMOVE` and `orphanRemoval` are prohibited on anything reachable from judicial or payment data — deletion is a business decision, not an ORM side effect. If a story appears to require deleting JOH, booking, sitting, or payment records, that is a **stop** (**R5**).

### P10 — No N+1, and prove it

Any collection rendered in a response is fetched with an explicit `join fetch`, `@EntityGraph`, or a projection. List endpoints are always paged (`conventions.md` → *Pagination*) — an unbounded `findAll()` reaching a controller is prohibited.

### P11 — Repositories return what the caller needs

Derived query methods or `@Query` with named parameters. **String-concatenated SQL or JPQL is prohibited** — parameters only. Native SQL is allowed where a JPA query cannot express it, and then it carries an `*IT` test.

## Transactions and concurrency

### P12 — `@Transactional` on service methods only

Never on a controller, never on a repository interface (**M15**). Queries use `@Transactional(readOnly = true)`.

### P13 — Never hold a transaction across a network call

No call through `client/` inside an open transaction. A downstream service being slow must not hold database locks in a shared database that eleven other services depend on.

### P14 — Concurrency uses native constructs only

Per `conventions.md` and `project-context.md`: a natural-key unique constraint (`uq_{table}_{columns}`) makes a duplicate create fail and maps to **409**; `@Version` optimistic locking protects lost updates; pessimistic row locks cover cross-row workflows. **No idempotency-key tables, no `IdempotencyFilter`, no application-level locking, no advisory locks.** See the open question on the optimistic-lock status code in [`30-api-contracts.md`](./30-api-contracts.md) (**G6.7**).

### P15 — Time is UTC, typed, and injected

`timestamptz` for instants, `date` for date-only, always stored UTC (`conventions.md` → *Format Patterns*). Read the current time from an injected `Clock` (**M20**) — never `now()` in a query default or in Java. The UI converts to UK local for display; the database and the API never do.

### P16 — Audit columns are always populated

`created_at` and `updated_at` (`timestamptz NOT NULL`) on every table, set by the application from the injected `Clock` — not by a database trigger, and not left to a default. `created_by` / `updated_by` are post-MVP (D7); do not add them speculatively (**R6**).
