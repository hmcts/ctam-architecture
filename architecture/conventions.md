---
type: 'Architecture Shard'
description: 'This document is the consistency contract for the 11 services and the UI. Patterns are enforced by code review, CI lint, contract tests, and ArchUnit fitness functions — not by a shared library.'
resource: 'architecture/tobe/conventions.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-05-06'
parent: ../architecture.md
title: Implementation Patterns & Consistency Rules (Step 5)
last_updated: 2026-05-06
extracted_in: architecture.md v1.8 — Strategy B refactor
---

# Implementation Patterns & Consistency Rules

> Sibling of [`../architecture.md`](../architecture.md). The parent file links here in place of the original Step 5.

## Pattern Categories

This document is the consistency contract for the 11 services and the UI. Patterns are enforced by code review, CI lint, contract tests, and ArchUnit fitness functions — not by a shared library.

## Naming Patterns

**Database (PostgreSQL):**

- **Schema:** single shared schema (e.g. `ctam` or default `public`). All CTAM Pathfinder tables live in this schema. Per-service DB roles enforce write boundaries; the team that writes the Liquibase changelog owns the table.
- **Tables:** `snake_case`. **Ownership is in the prefix** *(revised 2026-06-11)*:
  - **`ctam_` — every CTAM-owned table**, entity-plural: `ctam_bookings`, `ctam_absences`, `ctam_regions`, `ctam_auth_users`, `ctam_payment_reconciliations`, `ctam_configuration_values`. JOH operational state over upstream entities is named directly — `ctam_joh_ticket`, `ctam_joh_location` — **no `_overlays` suffix pattern**.
  - **`jo_` / `mrd_` — upstream-sourced tier-(a) tables** (source-system prefix): `jo_people`, `jo_jurisdictions`, `mrd_specialisms`. Read-only in CTAM; written only by the ingestion mechanisms.
  - **`mock_` — dev-only mock-auth tables** (`mock_oauth_clients`, `mock_user_roster`): never deployed to production, exempt from the `ctam_` rule — the `mock_` prefix already marks them as not-production.
  - Full inventory in [`./data-tables.md`](./data-tables.md).
- **Authoritative ownership mapping** is documented in [`./data-tables.md`](./data-tables.md) (table-ownership table maps every CTAM Pathfinder table → owning service-role). The team that authors the Liquibase changelog is the owning team.
- **Fitness function in CI** verifies: (a) no two services' Liquibase changesets create overlapping table names; (b) DB role grants align with the documented ownership; (c) tables not in the ownership mapping are flagged.
- **Columns:** `snake_case` — `id`, `created_at`, `updated_at`, `payroll_number`, `is_active`.
- **Primary keys:** `id`, type `uuid`. UUIDs avoid integer-range coupling and "guess the next ID" patterns. Cost over bigint is negligible at this scale. PK generation detail in [`../architecture.md`](../architecture.md) → *Data Architecture*.
- **Foreign keys:** `{referenced_entity_singular}_id` — `booking_id`, `vacancy_id`, `absence_id`, `joh_id`. **JOH references use `joh_id` (uuid) → `ctam_joh_identities`** — the CTAM-assigned canonical JOH identifier. `personnel_number` is the upstream link to `jo_people`, stored **only** on `ctam_joh_identities`, and is **never** a domain FK. FKs reference tables in the shared schema; no cross-schema FK overhead.
- **Indexes:** `idx_{table}_{columns}` — `idx_ctam_bookings_joh_id_date`, `idx_ctam_absences_joh_id`.
- **Unique constraints:** named `uq_{table}_{columns}`. Per-table examples in [`./data-tables.md`](./data-tables.md).
- **Audit columns:** every table has `created_at timestamptz NOT NULL`, `updated_at timestamptz NOT NULL`. `created_by` and `updated_by` (UUID, FK to user identity) added when D7 user-action audit is implemented post-MVP.

**API endpoints:**

- **Resources:** plural nouns — `/v1/johs`, `/v1/bookings`, `/v1/payments`.
- **Resource IDs in path:** `/v1/bookings/{bookingId}`; JOH resources key on the CTAM JOH UUID — `/v1/johs/{johId}` (filter by the upstream key via `?personnelNumber=`).
- **Sub-resources:** `/v1/johs/{johId}/working-patterns`, `/v1/johs/{johId}/tickets`.
- **Actions on resources:** `POST /v1/absences/{absenceId}/approve`, `POST /v1/sittings/{sittingId}/verify`. Actions are URL-segments, not RPC-style endpoint names.
- **Path variables:** `{camelCase}` — `{johId}`, `{bookingId}`.
- **Query parameters:** `camelCase` — `?regionId=...&fromDate=...&johType=...`.
- **HTTP headers:** `Title-Kebab-Case`, no `X-` prefix per [RFC 6648](https://datatracker.ietf.org/doc/html/rfc6648) — `Idempotency-Key`, `Correlation-Id`, `Sunset` (per [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594)), `Deprecation` (per [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745)).
- **Versioning prefix:** `/v1/` for major version 1, `/v2/` for v2, etc. (per Step 4 in [`../architecture.md`](../architecture.md)).

**Java code:**

- **Package:** `uk.gov.hmcts.ctam.{service}.{layer}` — e.g. `uk.gov.hmcts.ctam.judge.controller`, `uk.gov.hmcts.ctam.booking.service`.
- **Classes:** `PascalCase` — `Judge`, `JudgeController`, `JudgeService`, `JudgeRepository`, `JudgeNotFoundException`.
- **Methods / fields:** `camelCase` — `getJudgeById`, `firstName`, `isActive`.
- **Constants:** `SCREAMING_SNAKE_CASE` — `MAX_BOOKING_DAYS_PER_VACANCY`, `DEFAULT_PESSIMISTIC_LOCK_TIMEOUT_MS`.
- **Test classes:** unit tests `{ClassUnderTest}Test.java`; integration tests `{ClassUnderTest}IT.java`. *(There are no `*ApexParityTest.java` classes — behavioural-parity verification is manual UAT, see `docs/uat/` per service.)*

**TypeScript code (UI):**

- **Files:** `PascalCase.tsx` for components — `JudgeList.tsx`, `BookingForm.tsx`. `camelCase.ts` for non-component modules — `apiClient.ts`, `formatters.ts`.
- **Components:** `PascalCase` — `<JudgeList />`, `<BookingForm />`.
- **Hooks:** `useCamelCase` — `useJudgeList`, `useBookings`, `useAuth`.
- **Types / interfaces:** `PascalCase` — `Judge`, `BookingRequest`, `PaymentSchedule`.
- **Functions / variables:** `camelCase`.
- **Constants:** `SCREAMING_SNAKE_CASE`.
- **Generated API client types:** `camelCase` per JSON field convention below; one client per backend service, regenerated from OpenAPI spec.

## Structure Patterns

**Per-service Java structure (Spring Boot conventional, no shared parent):**

```
ctam-{service}/
├── src/main/java/uk/gov/hmcts/ctam/{service}/
│   ├── {Service}Application.java       (Spring Boot @SpringBootApplication)
│   ├── controller/                     (REST controllers, @RestController)
│   ├── service/                        (business logic, @Service)
│   ├── repository/                     (Spring Data JPA, @Repository)
│   ├── domain/                         (entities + value objects, @Entity)
│   ├── dto/                            (request/response DTOs)
│   ├── client/                         (clients to other CTAM Pathfinder services)
│   ├── config/                         (Spring config: JWTFilter, AuthDetails, OpenAPI Swagger Core)
│   ├── error/                          (RFC 9457 ControllerAdvice, problem-detail factories)
│   └── exception/                      (domain exceptions extending base classes)
├── src/main/resources/
│   ├── application.yml                 (defaults)
│   ├── application-{profile}.yml       (dev/staging/production overrides)
│   └── db/changelog/                   (Liquibase: db.changelog-master.yaml, 001-init.sql, 002-add-x.sql, ...)
├── src/test/java/uk/gov/hmcts/ctam/{service}/
│   └── {layer}/                        (mirrors src/main package layout — unit + integration tests)
├── docs/
│   └── uat/                            (manual UAT scripts: incumbent-vs-CTAM Pathfinder behavioural-parity walkthroughs per FR60 / NFR41 revised)
├── helm/                                (Kubernetes Helm chart)
├── postman/                             (Postman collections per phase)
├── build.gradle                     (Gradle Groovy DSL (per HMCTS template))
├── settings.gradle
└── README.md                            (service-specific docs)
```

> Full per-service / UI / `ctam-architecture` directory trees with the inventory of every file: see [`./repo-structure.md`](./repo-structure.md).

**UI repo structure (single repo, modules per domain):**

```
ctam-ui/
├── src/
│   ├── main.tsx                         (entry point)
│   ├── App.tsx                          (router root + auth wrapper)
│   ├── routes.tsx                       (route definitions)
│   ├── modules/                         (per-domain UI modules)
│   │   ├── judge/                       (Manage Judges UI)
│   │   │   ├── pages/                   (JudgeListPage.tsx, JudgeDetailPage.tsx)
│   │   │   ├── components/              (JudgeCard.tsx, WorkingPatternEditor.tsx)
│   │   │   ├── hooks/                   (useJudgeList.ts, useJudge.ts)
│   │   │   ├── api/                     (generated client from Judge OpenAPI spec)
│   │   │   └── index.ts                 (module exports)
│   │   ├── absence/
│   │   ├── vacancy/
│   │   ├── booking/
│   │   ├── sitting/
│   │   ├── payment/
│   │   ├── itinerary/
│   │   └── reports/
│   ├── shared/                          (cross-module UI utilities)
│   │   ├── components/                  (Layout, Header, ErrorBoundary)
│   │   ├── hooks/                       (useAuth, useCorrelationId)
│   │   ├── auth/                        (HMCTS IdP integration)
│   │   └── api/                         (shared HTTP client config, error handling)
│   └── styles/                          (GOV.UK Design System overrides)
├── tests/
│   ├── unit/                            (Vitest)
│   └── e2e/                             (Playwright per phase)
├── public/
└── package.json
```

**Why module-per-domain (not by-type):** the 11-service backend decomposition implies ~10 UI domain modules (the cross-cutting Notification and Authorisation services are not UI-fronted; the cross-cutting Reference Data is admin-screen-fronted only); each module is self-contained (pages + components + hooks + generated client) so a domain phase's UI work is one folder. Easier to onboard, easier to delete or rewrite per region's customisation if ever needed.

## Format Patterns

**JSON field naming: `camelCase`** for all field names — `firstName`, `payrollNumber`, `feePaymentStatus`, `createdAt`. Aligns with TypeScript convention; Spring Jackson maps Java `camelCase` → JSON `camelCase` by default. Snake_case at the database layer maps to camelCase at the API layer via JPA column-to-field mapping.

**Date/time formats:** **ISO 8601 always.**

- Date-only: `2026-05-06` (no timezone).
- Instants (timestamps): `2026-05-06T14:30:00Z` (always UTC). Server stores UTC; UI converts to UK local for display only.

**Booleans:** `true` / `false` in JSON; `boolean` type in PostgreSQL. No `0/1`, no `Y/N`.

**Null vs missing:**

- Optional fields: omit when null (Jackson `Include.NON_NULL`).
- Required fields: validation rejects missing values at API boundary.

**Pagination:**

- **Cursor-based** for large or chronologically-ordered lists (Forward Look, MI Feed reports): `?cursor={opaque}&limit=50`. Response: `{ "items": [...], "nextCursor": "..." }`.
- **Offset-based** for small filtered lists (Bookings list filtered by region+date): `?page=0&size=20`. Response: `{ "items": [...], "totalElements": N, "page": 0, "size": 20 }`.
- Cursor format is service-internal opaque (typically a base64-encoded `(timestamp, id)` tuple). Consumers do not parse cursors.

**API response envelope:**

- **Success:** direct resource representation, no wrapper. `GET /v1/johs/{johId}` returns the JOH JSON directly.
- **Error:** [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) `application/problem+json` envelope (obsoletes RFC 7807; same content type and field shape) per Step 4 in [`../architecture.md`](../architecture.md).

**HTTP status codes (consistent usage):**

| Status | Used for |
|---|---|
| 200 OK | Successful read; successful idempotent update |
| 201 Created | Successful resource creation; `Location` header points to new resource |
| 204 No Content | Successful delete; successful action with no body |
| 400 Bad Request | Malformed request (parsing failure) |
| 401 Unauthorized | AuthN failure (missing or invalid token) |
| 403 Forbidden | AuthZ failure (token valid but principal lacks permission) |
| 404 Not Found | Resource does not exist |
| 409 Conflict | State conflict (e.g. double-booking attempt) |
| 422 Unprocessable Entity | Validation failure (request well-formed, business rule rejected) |
| 429 Too Many Requests | Rate limit exceeded; `Retry-After` header included |
| 5xx | Server-side faults |

## Communication Patterns

**Service-to-service call pattern:**

- Each service has a `client/` package with one Spring `@Component` per called service (e.g. `BookingService`'s repo contains `VacancyClient` for calling Vacancy).
- Clients are typed Java interfaces wrapping Spring Boot 4's `RestClient` configured with the JWT-propagation interceptor (below) and correlation-ID propagator.
- Method names mirror the operation: `notificationClient.sendBookingAcknowledgement(bookingId)`, not `notificationClient.post(...)`. **Domain language, not HTTP language.**
- Clients handle: JWT propagation, correlation-ID propagation, retry on 5xx (idempotent operations only), circuit-breaker (open if dependency is down).

**Inter-service authentication at MVP — two patterns:**

1. **JWT propagation (token forwarding)** — for **user-initiated** flows (the majority at MVP). The user's JWT (issued by HMCTS IdP at SSO) is the relevant security context end-to-end. Inter-service calls forward that JWT as-is.
2. **Service-principal authentication (OAuth `client_credentials`)** — for **batch / scheduled** components without an upstream user. The MVP-relevant case is `ctam-payment-batch`.

**JWT propagation (token forwarding) — for user-initiated flows:**

- **Mechanism:** every outbound `RestClient` registers a `ClientHttpRequestInterceptor` that:
  1. Reads the inbound request's `Authorization: Bearer <user-jwt>` header from the request-scoped `AuthDetails` bean (populated by `JWTFilter`).
  2. Attaches the same `Authorization` header to the outbound request.
  3. Allows the call to proceed.
- **Downstream service** validates the forwarded JWT via its own `JWTFilter` (signature check against IdP's JWKS, then `POST /authz/check`) — same path as for direct user requests.
- **Implementation footprint per service:** ~10–15 lines (one `Configuration` class wiring the interceptor onto the shared `RestClient` builder).
- **Limit:** propagation requires a request-scoped user JWT to exist. Background, scheduled, or async flows have no user context — those use the service-principal pattern below.

**Service-principal authentication (for batch / scheduled components):**

The MVP-relevant case is the **payment-processing batch** (`ctam-payment-batch`), which runs on a schedule and has no upstream user context. It uses OAuth `client_credentials`:

- **Client registration**: a service-principal entry exists in the OIDC issuer's client store. In non-prod that's `mock_oauth_clients` on `ctam-mock-auth`; in production it's whichever issuer is chosen per [`./gaps.md` G7.1](./gaps.md) (default recommendation: Azure Workload Identity, which substitutes managed-identity tokens for client-secret-based ones).
- **Token acquisition**: at run start (or on token expiry), the batch component does `POST /oauth2/token` with `grant_type=client_credentials`. Spring Boot 4's `OAuth2AuthorizedClientManager` handles caching + refresh.
- **Outbound calls**: the resulting service JWT is attached as `Authorization: Bearer …` to outbound HTTP calls (e.g. to the Notification API). The receiving service's `JWTFilter` validates it via the same JWKS path used for human user JWTs — same code path; only the principal's "kind" claim differs.
- **Authorisation**: service principals have records in `ctam_auth_users` with a kind flag (e.g. `principal_kind = service`) distinguishing them from humans. `ctam-authorisation` resolves their permissions the same way as human users.
- **Scheduling**: implementation choice between Spring `@Scheduled` (in-process; runs inside the same JVM as the synchronous service API) and a Kubernetes CronJob (separate pod; scales independently). Either is acceptable at MVP — the batch's external observable behaviour is the same.

**Correlation ID propagation:**

- **Inbound:** read `Correlation-Id` header (or generate UUID if missing); set in MDC via `MDC.put("correlationId", id)`.
- **Outbound:** every service-to-service client attaches the current MDC correlation ID to outbound `Correlation-Id` header.
- **Logs:** every log entry includes `correlationId` via Logback MDC integration.

**Error categorisation taxonomy** (used in logs and as RFC 9457 `type` URI suffixes):

| Category | Use case |
|---|---|
| `validation` | Request failed JSR-380 validation |
| `authorisation` | AuthZ check rejected the principal |
| `business-rule` | Request well-formed but violates a domain rule (e.g. double-booking) |
| `dependency` | Downstream service call failed |
| `data` | Data integrity issue (unexpected null, FK violation, etc.) |
| `concurrency` | Optimistic-lock failure on a write |
| `unexpected` | Uncaught exception — promotes to a bug ticket; ideally rare |

**Retry safety and concurrency control:** native PostgreSQL + JPA constructs (natural-key uniqueness for duplicate-create dedup → `409`; optimistic locking for lost-update → `412`; pessimistic row locking for cross-row workflows). No custom idempotency-key tables. Detail (mechanisms, naming, per-entity convention, `Idempotency-Key` policy) lives in [`../architecture.md`](../architecture.md) → *Data Architecture* and per-table in [`./data-tables.md`](./data-tables.md).

## Process Patterns

**Error handling at the controller layer:**

- All controllers return `ResponseEntity<T>` (or void with `@ResponseStatus` for 204 No Content).
- Per-service `@ControllerAdvice` catches:
  - `MethodArgumentNotValidException` → 422 + RFC 9457 `validation`
  - `AuthorisationException` (custom) → 403 + RFC 9457 `authorisation`
  - `BusinessRuleViolation` (custom base class for domain exceptions) → 409 or 422 + RFC 9457 `business-rule`
  - `DependencyException` (custom) → 502 + RFC 9457 `dependency`
  - `OptimisticLockingFailureException` → 409 + RFC 9457 `concurrency`
  - `Exception` (catch-all) → 500 + RFC 9457 `unexpected` (logged with full stack trace at ERROR level)

**Loading states (UI):**

- TanStack Query handles loading state via `isLoading`, `isFetching`, `isError`.
- Standard pattern:
  ```tsx
  if (isLoading) return <Spinner />;
  if (isError) return <ErrorMessage error={error} />;
  return <ActualContent data={data} />;
  ```
- Use GOV.UK Design System's loading patterns; no ad-hoc spinners.

**Form validation (UI):**

- React Hook Form for state management.
- Zod schemas matching the OpenAPI request shape (or `zod-to-openapi` derivation).
- Server is the source of truth — UI validation is for UX feedback only and never enforces a constraint the server doesn't.

**Test conventions:**

- Unit tests: `*Test.java`, mock all dependencies, run on every commit.
- Integration tests: `*IT.java`, Testcontainers for PostgreSQL, run on every commit.
- Contract tests (Pact or equivalent): per-consumer / per-provider, run on every commit.
- E2E tests (UI): Playwright, one suite per phase, run as a phase gate.
- **Manual UAT — incumbent-vs-CTAM Pathfinder behavioural parity (FR60 / NFR41, reframed 2026-06-10[^d11][^d5]; wave sequence retargeted 2026-08-07[^d13]):** scripted walkthroughs maintained under `docs/uat/` per service. Performed by jurisdiction-incumbent-experienced users — `[ET-INCUMBENT-TBD]`-experienced (ET roles *provisional* pending the ET as-is pack, G8.5) for **ET wave 1**; ListAssist-experienced (RTJ, Tribunal Judges, Tribunal Members, Caseworkers, Finance, MI) for **SSCS wave 2**; APEX-experienced (RSU, Court, Judge, Judges' Clerks, Finance/Payment Authoriser, MI) for **Courts waves 3+** — opening the incumbent side-by-side with CTAM Pathfinder, comparing behaviour for the workflows + edge cases the script enumerates, and signing off per role per wave. Sign-off is the wave-cutover gate; there is no automated incumbent-comparison harness in CI. *(The wave-1 UAT panel cannot be constituted until G8.4 names ET's scheduling incumbent.)*
- **Coverage target:** behaviour coverage, not line coverage — PRs include behaviour-test rationale, not coverage stats. **Amended 2026-08-19 (SCP 2026-08-19):** behaviour coverage remains the goal, and it is now backed by deterministic floors on `service` + `domain` packages — **JaCoCo ≥ 85% line / ≥ 75% branch** and a **PIT mutation score ≥ 70%** (`config`, `dto`, `*Application`, generated sources and changelogs excluded). The mutation score is the load-bearing number: line coverage can be manufactured by executing code without asserting on it, whereas a surviving mutant names a statement the tests do not actually check. Both are floors, not targets — a threshold met by a test that asserts nothing is a rule breach, not a pass.
- **Delivery discipline (new 2026-08-19):** implementation follows the **agent delivery rules** published on the context bus at `ctam-architecture/agent-rules/` — evidence-based red-green-refactor (no production edit without a test seen failing on an assertion), hard modularity limits, a cite-or-ask uncertainty protocol, and a single pre-handoff quality gate. Binding on AI agents and human developers alike; see SCP 2026-08-19.

**Logging conventions (per HMCTS Crime template):**

- Logger per class via SLF4J: `private static final Logger LOG = LoggerFactory.getLogger(MyService.class);` (Lombok `@Slf4j` is also acceptable per HMCTS template's Lombok use).
- **Logstash JSON encoder** for structured output; **OpenTelemetry** for trace context propagation alongside logs.
- Levels:
  - `ERROR` — request failed in unexpected way; investigate.
  - `WARN` — recoverable but unusual.
  - `INFO` — significant business events ("Booking created", "Payment dispatched").
  - `DEBUG` — diagnostic detail; off in production by default.
- **Forbidden in logs:** PII (judge personal data, payroll numbers), bank details, case-level identifiers, raw request bodies that may contain personal data.

**Git conventions:**

- Branch naming: `feature/{ticket-id}-{short-description}`, `bugfix/{ticket-id}-{short-description}`, `chore/{short-description}`.
- Commit messages: imperative present tense, ≤ 72 chars subject. Conventional Commits prefix (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`) per HMCTS conventions.
- PR target: `main`. Trunk-based development; release branches per region/wave only if needed.

## Enforcement Guidelines

**All CTAM Pathfinder services MUST:**

- Use the HMCTS Crime SpringBoot template as scaffold (per [`./starter-template.md`](./starter-template.md)) and customise per service.
- Follow the package layout `uk.gov.hmcts.ctam.{service}.{layer}`.
- Use Gradle Groovy DSL (per HMCTS Crime SpringBoot template) with Gradle Wrapper.
- Implement RFC 9457 errors via per-service `@ControllerAdvice` (no shared library).
- Implement Authorisation enforcement via per-service custom `JWTFilter` + `AuthDetails` request-scoped bean (HMCTS template pattern); the filter calls CTAM Pathfinder Authorisation per request to resolve roles + jurisdiction + Region/Area scope and the activation flag (CTAM Pathfinder variance from template's claims-only approach — required by FR2/FR57).
- Generate OpenAPI 3.x specs via Swagger Core; publish per-service spec by Gradle (via the `maven-publish` plugin) as a Maven-format artefact (`uk.gov.hmcts.ctam:api-ctam-{service}:{version}`) to the internal artefact repository.
- Emit structured JSON logs (Logstash encoder) with correlation IDs; export traces via OpenTelemetry.
- Use Liquibase changelogs in `src/main/resources/db/changelog/` (added by the CTAM scaffolding overlay — CTAM convention; the HMCTS demo repo uses Flyway, CTAM standardises on Liquibase; **not** in the template baseline, see G1.4a).
- Use **Lombok** (base template) and **MapStruct** (scaffolding overlay — not in the baseline) for boilerplate reduction and DTO/entity mapping.
- Use OWASP Java Encoder for XSS-safe output encoding where rendering untrusted input.
- Emit JaCoCo coverage reports and CycloneDX SBOM as part of CI artefacts.
- Provide a Helm chart for AKS deployment.
- Provide a Postman collection per phase that exercises the service's endpoints.
- Install the **agent-rules enforcement pack** from the context bus (`ctam-architecture/agent-rules/enforcement/`) at scaffold time: ArchUnit fitness functions, the CTAM Checkstyle config, the Gradle quality gate (Spotless + Checkstyle + JaCoCo floor + PIT), the Spectral ruleset, `scripts/verify.sh`, and the target-repo `CLAUDE.md` + hooks. See `agent-rules/enforcement/README.md` for the rule → enforcer map.
- Include unit tests, integration tests (Testcontainers PostgreSQL), and contract tests. *(Domain services additionally maintain a manual UAT script under `docs/uat/` per FR60 / NFR41 revised; this is documentation owned by the service, not a CI gate.)*

**Pattern enforcement mechanisms:**

| Mechanism | What it enforces |
|---|---|
| **Code review (PR template)** | "Patterns checklist" — naming, structure, format, error handling. Reviewer signs off. |
| **CI lint** | Spotless + Checkstyle (Java); ESLint + Prettier (TypeScript); SQL formatting via SQLFluff. Build fails on violation. |
| **ArchUnit fitness functions** | Per-service ArchUnit tests enforce package layout, dependency rules, naming conventions. Run as part of unit-test suite. |
| **Consumer-driven contract tests (Pact)** | Verify API conventions are honoured between consumers and providers. |
| **OpenAPI lint (Spectral)** | OpenAPI specs validated against an CTAM Pathfinder-specific ruleset (consistent error envelope, versioning prefix, RFC 9457 references). |
| **JaCoCo + CycloneDX** | Code coverage reports + SBOM generation per HMCTS Crime template. Build emits artefacts for security/audit review. |
| **JaCoCo coverage floor** *(2026-08-19)* | Build fails below 85% line / 75% branch on `service` + `domain` packages. |
| **PIT mutation threshold** *(2026-08-19)* | Build fails below a 70% mutation score on `service` + `domain`. The check that a test would actually catch a regression. |
| **Agent delivery rules** *(2026-08-19)* | `ctam-architecture/agent-rules/` — TDD evidence, modularity limits, uncertainty protocol, definition of done. Enforced by the pack above plus review; rule → enforcer map in `agent-rules/enforcement/README.md`. |

**When patterns evolve:**

- Pattern change starts as a PR against [`../architecture.md`](../architecture.md) (or this file).
- Once merged, the pattern is the new convention.
- **Existing services are NOT forced to retrofit** (no shared library means no version-bump cascade); new services adopt the new pattern; existing services adopt at their own pace via per-service refactors when next touched.

## Pattern Examples

**Good — naming:**

- Database: `ctam_`-prefixed entity-plural table name (CTAM-owned) or source-prefixed (`jo_`/`mrd_`, upstream); `snake_case` columns; `id uuid PRIMARY KEY`; `created_at` / `updated_at` audit columns; natural-key uniqueness via `uq_{table}_{columns}`. Full per-table detail in [`./data-tables.md`](./data-tables.md).
- API: `GET /v1/johs/{johId}`
- Java: `@RestController class JohController { ResponseEntity<JohDto> getJoh(@PathVariable UUID johId) { ... } }`
- TypeScript: `function JohProfile({ johId }: { johId: string }) { ... }`
- JSON: `{ "johId": "...", "personnelNumber": "...", "firstName": "...", "payrollNumber": "...", "isActive": true, "createdAt": "2026-05-06T10:00:00Z" }` (`johId` is the CTAM identifier; `personnelNumber` is the upstream link)

**Anti-patterns — do not:**

- ❌ Mixed casing in DB (`Id`, `FirstName`). Use `snake_case`.
- ❌ Snake_case in JSON: `{ "personnel_number": ..., "first_name": ... }` (mixes Java-style with JS clients).
- ❌ Wrap success responses: `{ "data": { "personnelNumber": ... }, "error": null }`.
- ❌ Custom error formats: `{ "errorMsg": "..." }` instead of RFC 9457.
- ❌ Ad-hoc HTTP statuses: `200 OK` with `{"success": false}` body for failures.
- ❌ "Smart" / RPC-style routes: `POST /v1/processBookingAndCreatePayment` (mixes resources). Use `POST /v1/bookings` then `POST /v1/payments/process`.
- ❌ Bigint primary keys (use UUID per the standard above).
- ❌ Local time zones in stored timestamps (always UTC).
- ❌ Logging PII or bank details at any level.

[^d5]: D5 — the jurisdiction's incumbent system is the behavioural reference, verified by manual UAT.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
