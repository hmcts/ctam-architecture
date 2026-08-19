---
id: agent-rules/security
title: Security, secrets and logging (S1–S16)
status: draft
last_updated: 2026-08-19
---

# Security, secrets and logging

> Expands **R11**. This is judicial personal data in a government system. A leak here is not a defect to fix next sprint — it is a reportable incident. Every rule below is absolute; none of them has a "just for local debugging" exception, because that is precisely how the line gets committed.

## Never log

### S1 — The forbidden list

Never, at any level — including `DEBUG`, and including inside an exception message:

- **Personal data**: names, addresses, contact details, dates of birth, diversity data.
- **Identifiers**: personnel numbers, payroll numbers, national insurance numbers.
- **Bank and payment details** of any kind.
- **Case-level identifiers** of any kind (NFR23 — the MI read models hold none either).
- **Credentials**: JWTs, the `Authorization` header, client secrets, connection strings, API keys.
- **Raw request or response bodies**, and whole DTO or entity objects — `log.info("payload {}", request)` will print whatever the record happens to contain today, and whatever it contains after someone adds a field next sprint.

Log the **`joh_id`** (the CTAM-assigned UUID) and the **correlation id**. Those are enough to trace a request end-to-end without carrying identity into the log estate.

### S2 — Log the event, not the object

Placeholders, never concatenation; a named business event, never a data dump.

```java
// Good
log.info("Booking created bookingId={} johId={}", booking.getId(), booking.getJohId());

// Prohibited
log.info("Booking created: " + booking);            // whole object, concatenated
log.debug("Request={}", request);                    // raw body
log.info("Booking for {} {}", firstName, lastName);  // PII
```

### S3 — Levels mean what `conventions.md` says

`ERROR` = a request failed unexpectedly and someone must investigate. `WARN` = recoverable but unusual. `INFO` = a significant business event. `DEBUG` = diagnostics, off in production. Do not log at `ERROR` for an expected 4xx — a validation failure is not an incident, and an alerting estate that cries wolf gets muted.

### S4 — Correlation id on every line

Populated into MDC by the request-entry filter and propagated outbound by every client (`conventions.md` → *Communication Patterns*). Never construct log output that omits it; never invent a second tracing mechanism.

### S5 — No `System.out`, no `printStackTrace()`

SLF4J only (or Lombok `@Slf4j`). Both are build failures.

## Secrets

### S6 — Azure Key Vault, and nowhere else

Secrets resolve through Spring Cloud Azure Key Vault. Never in source, `application*.yml`, a Helm values file, a test fixture, a comment, a commit message, or a log line. If a story seems to need a secret in a file, that is a **stop** (**R5**).

### S7 — Test credentials are obviously fake

Test JWTs and passwords are self-evidently synthetic and generated in the test. Never a real token, never a value copied from an environment, never a plausible-looking secret.

### S8 — Never weaken transport security

TLS 1.3 minimum (1.2 fallback). Disabling certificate or hostname verification is prohibited in **every** profile, including local and test. There is no acceptable reason for `trustAll` in this codebase.

## Authentication and authorisation

### S9 — The `JWTFilter` path is the only path

Every request is authenticated by the per-service `JWTFilter` (signature against the IdP JWKS, then `POST /authz/check`) which populates the request-scoped `AuthDetails` (`conventions.md` → *Enforcement Guidelines*). Never bypass it, never add a second security mechanism, never introduce a permit-all path, and never widen an actuator endpoint beyond the template's posture.

### S10 — Never trust a claim for an authorisation decision

Roles, jurisdiction, Region/Area scope and the activation flag come from the Authorisation service's response, held in `AuthDetails` — not from JWT claims directly. This is the deliberate CTAM variance from the template's claims-only approach (FR2/FR57). Reading a role out of a token to make a decision defeats it.

### S11 — Authorise every endpoint, explicitly

Every new endpoint states which permission it requires, traceable to an AC or FR (**R4**). An endpoint whose authorisation requirement nobody wrote down is an unauthorised endpoint. If the story does not say, ask (**R5**).

### S12 — Mock auth never reaches production

`ctam-mock-auth` and the `mock_*` tables are dev/CI only. No production profile, Helm value, or default configuration may reference them, and no code path may fall back to them when the real issuer is unreachable.

## Input, output, dependencies

### S13 — Encode on output, parameterise on input

OWASP Java Encoder where untrusted input is rendered. Parameterised queries only (**P11**). No reflective or dynamic class loading driven by request data. No deserialisation of untrusted input into arbitrary types.

### S14 — Dependencies are a supply-chain decision

No new dependency without a cited source or explicit human approval (**R6**), and never a `SNAPSHOT`, release candidate, or unpinned version. Versions come from the Spring Boot BOM where the BOM manages them — verify, never recall (**R7**). The CycloneDX SBOM must build; a dependency that breaks it does not ship.

## Data protection

### S15 — Never store bank details

NFR14. Not in a table, not in a log, not in a cache, not in a test fixture, not "temporarily". Payment output references what the downstream payment system needs and no more.

### S16 — Never put real judicial data in a repository

Test fixtures, UAT scripts, seed data, screenshots and issue descriptions all use synthetic data. Real data belongs only in the environments cleared to hold it.
