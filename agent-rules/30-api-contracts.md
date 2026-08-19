---
id: agent-rules/api-contracts
title: API contracts and error shapes (C1–C14)
status: draft
last_updated: 2026-08-19
---

# API contracts and error shapes

> Expands **R10**. The API *is* the boundary in this programme — there is no shared library, so a contract is the only thing another repo can rely on (`project-context.md` → *Delivery & repo discipline*). A contract you get wrong is a contract someone else has already generated a client from.
>
> Endpoint, header, JSON, pagination and status-code conventions are **not restated here** — they are in `_arch/architecture/conventions.md` → *Naming Patterns* / *Format Patterns*. Read that. This file governs the **order of work** and the **contract-safety** rules.

## Order of work

### C1 — The contract test comes before the controller

For each endpoint in the story:

1. Write down the contract in the story packet's *Notes*: path, method, request shape, success status + body, and the error cases with their status and RFC 9457 `type`. Every element traceable to an AC or a cited convention (**R4**).
2. Write the failing **`@WebMvcTest`** slice test for one behaviour of it. Run it. Paste the red.
3. Write the controller method. Run. Paste the green.
4. Repeat per behaviour — success path, each validation failure, each authorisation failure, each business-rule failure.
5. Only then wire the service beneath it (its own red-green cycles, per [`10-tdd.md`](./10-tdd.md)).

The OpenAPI spec stays **generated** from the code by Swagger Core, as `conventions.md` and AR8 require. Writing the test first is what makes the generated spec a designed artefact rather than an accident of implementation.

### C2 — Every endpoint has both sides of a Pact

Provider verification for what this service publishes; a consumer test for every endpoint this service calls. An inter-service call without a consumer contract test is prohibited (**R6**) — it is an undeclared dependency that will break silently on the other team's next release.

### C3 — Spectral must pass on the generated spec

`./scripts/verify.sh` regenerates the spec and lints it against [`enforcement/openapi/.spectral.yaml`](./enforcement/openapi/.spectral.yaml). A Spectral failure is a convention breach in your code, not a linter to be configured around.

## Contract safety

### C4 — `/v1` is append-only

Within a published major version you may **add** an optional request field, **add** a response field, or **add** an endpoint. You may never, in `/v1`:

- remove or rename a field, endpoint, or enum value;
- make an optional request field required, or narrow its accepted values;
- change a field's type, or a success status code;
- change the meaning of an existing value.

Any of those is a new major version (`/v2`), announced with `Deprecation` and `Sunset` headers on the old one (`conventions.md`). If a story appears to require a breaking change to a published `/v1`, that is a **stop** (**R5**) — the blast radius is other repos.

### C5 — Consumers pin, producers publish

The producing repo owns its spec and publishes it as `uk.gov.hmcts.ctam:api-ctam-{service}:{version}` via Gradle `maven-publish`. As a consumer, depend on a **pinned version** and generate your client from it. Never hand-write a client from documentation, never read another service's spec out of the `ctam-architecture` mirror (that mirror is read-only, for discovery only), and never hand-edit generated client code.

### C6 — No undeclared surface

Every path, query parameter, header, and status code your controller can produce is in the spec, and nothing in the spec is unimplemented. A debug parameter, an "internal only" endpoint, or an undocumented header is public API the moment it ships.

## Errors

### C7 — RFC 9457, always, via the `@ControllerAdvice`

Errors are `application/problem+json`. Controllers never build an error body themselves and never catch to translate — they let the exception reach the per-service `@ControllerAdvice` in `error/`. The exception → status mapping is fixed by `conventions.md`:

| Exception | Status | `type` category |
|---|---|---|
| `MethodArgumentNotValidException` | 422 | `validation` |
| `AuthorisationException` | 403 | `authorisation` |
| `BusinessRuleViolation` (and subtypes) | 409 or 422 | `business-rule` |
| `DependencyException` | 502 | `dependency` |
| `OptimisticLockingFailureException` | see the open question below | `concurrency` |
| anything uncaught | 500 | `unexpected` |

> **Open question — optimistic-lock status code.** The canonical docs disagree: `conventions.md` → *Process Patterns* maps `OptimisticLockingFailureException` to **409**, while `conventions.md` → *Communication Patterns* ("Retry safety and concurrency control") says optimistic locking for lost-update returns **412**. Tracked as **G6.7**. Until it is resolved, an optimistic-lock path is a **stop (R5)** — do not pick one and move on; ask.

### C8 — New problem types need a source

The `type` URI category comes from the fixed taxonomy in `conventions.md` → *Error categorisation taxonomy*. Inventing a new category, or a new exception-to-status mapping, requires a cited convention or a human decision (**R6**).

### C9 — 400 versus 422 is not a judgement call

**400** is for a request the parser could not read (malformed JSON, wrong type in a path variable). **422** is for a request that parsed cleanly and then failed validation or a business rule. Getting this wrong changes how every consumer's retry logic behaves.

### C10 — Error bodies leak nothing

No stack traces, no SQL, no upstream error text, no personnel numbers, no internal hostnames or table names in `detail`. The full diagnostic goes to the log with the correlation id (**R11**, [`50-security-and-logging.md`](./50-security-and-logging.md)); the client gets the correlation id and a safe message.

## DTOs and validation

### C11 — DTOs are immutable records, separate per direction

`record BookingRequest(...)` and `record BookingResponse(...)` — not one shared class, not an entity (**M12**), not a `Map<String, Object>`. Requests carry their JSR-380 constraints; the response record carries only what the API documents.

### C12 — Validate at the boundary, once

`@Valid` on the controller parameter; format, presence, range, and size constraints as annotations on the request record. Business rules (does this JOH exist, does this slot clash, is this absence within the sitting year) belong in the service and raise `BusinessRuleViolation` — never as a validation annotation.

## Clients

### C13 — Clients speak domain language

One typed `@Component` per called service in `client/`, wrapping `RestClient` with the JWT-propagation and correlation-id interceptors (`conventions.md` → *Communication Patterns*). Methods are named for the operation — `sendBookingAcknowledgement(bookingId)`, never `post(path, body)`. A client that exposes HTTP concepts to its caller has leaked the boundary it exists to hide.

### C14 — Retry only what is safe

Retry on 5xx for **idempotent** operations only. A non-idempotent `POST` is never retried automatically — surface the failure. No idempotency-key tables and no `IdempotencyFilter` (`project-context.md`); duplicate-create protection is a natural-key unique constraint returning 409, per [`40-data-and-liquibase.md`](./40-data-and-liquibase.md).
