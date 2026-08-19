---
type: 'Architecture Shard'
description: 'The 42 Non-Functional Requirements are organised into 8 categories. Each subsection below lists the NFRs in that category (verbatim from PRD) and the architectural support that satisfies them.'
resource: 'architecture/tobe/non-functional-requirements-coverage.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-05-07'
parent: ../architecture.md
title: Non-Functional Requirements Coverage (NFR1–NFR42)
last_updated: 2026-05-07
---

# Non-Functional Requirements Coverage (NFR1–NFR42)

> Sibling of [`../architecture.md`](../architecture.md). The parent links here from its *Architecture Validation Results / Requirements Coverage Validation* section.

The 42 Non-Functional Requirements are organised into 8 categories. Each subsection below lists the NFRs in that category (verbatim from PRD) and the architectural support that satisfies them.

**All 42 NFRs have explicit architectural support.** None unaddressed.

## Performance (NFR1–NFR9)

- **NFR1 — Static page load:** ≤ 3 s for static UI loads (e.g. Home initial render).
- **NFR2 — Dashboard refresh:** ≤ 5 s when Region/Area selection changes.
- **NFR3 — List / filter operations:** ≤ 10 s for typical operational lists at Region scope.
- **NFR4 — Batch / annual operations:** ≤ 15 s (e.g. annual itinerary render, batch payment-request processing).
- **NFR5 — Reports / Forward Look:** ≤ 30 s for standard report parameters and the Forward Look view at Region scope.
- **NFR6 — Single-resource API read:** ≤ 500 ms p95 (e.g. `GET /judges/{id}`).
- **NFR7 — Domain write API:** ≤ 1 s p95 for typical write operations.
- **NFR8 — Federated read (Itinerary, Forward Look):** ≤ 30 s p95. Strategy C cache fallback pre-designed if measurement shows the p95 breached.
- **NFR9 — Capacity:** concurrent users ~50–100 per region; ~200–500 national once all regions migrated.

**Architectural support:** APEX-baseline page-level NFRs achievable on Java/Spring Boot stack; Forward Look NFR8 trivially achievable via indexed SQL JOINs over the shared DB; AKS HPA per service for capacity NFR9.

## Security (NFR10–NFR16)

- **NFR10 — Transport encryption:** Latest TLS only on every endpoint; HTTP-only endpoints rejected.
- **NFR11 — Data-at-rest encryption:** All personal data (judge records, user/role records, working patterns, payroll numbers, payment metadata) encrypted at rest.
- **NFR12 — Authentication** *(revised v2.6)*: All human users authenticated via HMCTS IdP SSO (per FR1). **Inter-service authentication for user-initiated calls is via JWT propagation** — the user's JWT is forwarded by the upstream service's outbound HTTP client and validated by the downstream service's `JWTFilter` against the IdP's JWKS endpoint. **Inter-service authentication for batch / scheduled components** (initially `ctam-payment-batch`) is via OAuth 2.0 `client_credentials` against `ctam-mock-auth` in non-prod; production issuer per `gaps.md` G7.1 (default recommendation: Azure Workload Identity).
- **NFR13 — Authorisation enforcement:** Every API call resolves the principal's roles + Region/Area scope through the Authorisation service; no operation bypasses this check.
- **NFR14 — Forbidden data scope:** No bank details stored or exposed by any service. No case-level data in any read model or report.
- **NFR15 — Government Functional Standard 7 alignment:** CTAM Pathfinder aligns with HMCTS / MoJ GFS 7 — Security, including protective marking, access control, and secure development practices.
- **NFR16 — Secret management:** Service credentials, signing keys, and integration secrets stored in a managed secret store (Azure Key Vault); never in source control or environment-baked images.

**Architectural support:** TLS 1.3 ingress; PostgreSQL encryption-at-rest; per-service custom `JWTFilter` (HMCTS template pattern); per-service DB roles; Azure Key Vault via Spring Cloud Azure Key Vault; GFS-7 alignment via HMCTS starter security defaults; NFR12 covers both inter-service patterns (JWT propagation + service-principal `client_credentials` for batch).

## Accessibility (NFR17–NFR19)

- **NFR17 — WCAG 2.2 Level AA:** Every UI page meets WCAG 2.2 Level AA accessibility standards; tested per UI page in each domain phase before that phase's gate is passed.
- **NFR18 — Assistive technology compatibility:** Keyboard navigation, ARIA labels for tabbed and dynamic content, and screen-reader compatibility per HMCTS accessibility standards.
- **NFR19 — Public Sector Bodies Accessibility Regulations 2018:** CTAM Pathfinder complies with the Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018, including publication of an accessibility statement.

**Architectural support:** GOV.UK Design System component library; axe-core in CI (Vitest + Playwright runs); React Hook Form for accessible form validation.

## Integration (NFR20–NFR24)

- **NFR20 — HMCTS IdP integration:** Hard pre-Phase-9 dependency. CTAM Pathfinder integrates with whichever AuthN protocol the HMCTS IdP exposes (OIDC or SAML).
- **NFR21 — JFEPS / Liberata integration unchanged:** Payment schedule format (JFEPS-compatible Excel), email-to-Authoriser delivery, and authoriser-forwards-to-Liberata workflow are preserved exactly as in APEX.
- **NFR22 — HMCTS email infrastructure:** Outbound transactional emails (booking ack, absence ack, payment schedules) dispatch via HMCTS email; delivery is reliable but not low-latency-critical.
- **NFR23 — DA&I MI Feed:** Aggregate-only REST API contract; no case-level data exposed under any consumer authorisation.
- **NFR24 — JOH eLinks API + MRD integration (MVP scope)**[^d11]: JOH eLinks API is an MVP integration — the canonical source for judicial-holder reference data[^d3]. MRD data is ingested via a weekly Excel feed pending availability of MRD's public APIs. Manual data entry by RSU is no longer the operating model for these sources; corrections happen at source. Other HR systems beyond JOH eLinks / MRD remain out of MVP scope.

**Architectural support:** OIDC integration via mock auth (Phase 0–8) + HMCTS IdP (pre-Phase-9 onward); JFEPS-Excel email via Notification unchanged (verified for SSCS[^d11] — now wave 2; **ET wave-1 applicability unverified, G8.6**[^d13]); HMCTS email via Notification; MI Feed REST contract; **JOH eLinks in-process scheduled sync + MRD blob-drop pick-up inside `ctam-reference-data`** (see [`../architecture.md`](../architecture.md) → *Upstream reference-data ingestion*).

## Observability (NFR25–NFR29)

- **NFR25 — Structured logging:** Every service emits structured logs with consistent fields, correlation IDs threaded through service-to-service calls, and a defined error-categorisation taxonomy. Logging schema is a Phase 0 deliverable.
- **NFR26 — Log retention:** Logs retained sufficient for pilot incident triage; specific retention period set in Phase 0 within HMCTS data-retention policy.
- **NFR27 — Log ingestion:** Logs ingested into Azure-native logging (Application Insights / Log Analytics).
- **NFR28 — Health and readiness probes:** Every service exposes Kubernetes-compatible liveness and readiness endpoints (Spring Actuator).
- **NFR29 — Roadmap commitments (post-MVP, not in MVP):** Structured user-action auditing and full metrics/trace observability beyond logs are post-MVP[^d7].

**Architectural support:** Logback + Logstash JSON encoder → OpenTelemetry → Application Insights (per HMCTS Crime template); correlation-ID MDC; Spring Actuator probes (`/actuator/health`, `/actuator/info`, `/actuator/readiness`); 30-day hot + 90-day cold retention. User-action audit + metrics deferred[^d7].

## Data Privacy & Sovereignty (NFR30–NFR33)

- **NFR30 — UK GDPR / Data Protection Act 2018 compliance:** Personal data scope is limited to user/judge identity, contact details, payroll numbers, and operational metadata. No case-level data anywhere in CTAM Pathfinder.
- **NFR31 — Data residency:** All CTAM Pathfinder services and data hosted in Azure UK regions only. No personal data leaves the UK.
- **NFR32 — Retention:** Data retention per HMCTS retention schedules. Migrated transactional history remains in APEX[^d3]; CTAM Pathfinder retains only data created in CTAM Pathfinder from migration onward.
- **NFR33 — FOI scope:** Aggregate operational data exposable per FOI requests; case-level data is forbidden by contract and therefore outside FOI scope by construction.

**Architectural support:** Azure UK regions only; PostgreSQL Flexible Server in UK South; case-level data forbidden by schema (no fields exist); FOI scope by contract.

## Reliability & Availability (NFR34–NFR38)

- **NFR34 — Operational availability:** CTAM Pathfinder is available during HMCTS operational hours (typically 07:00–19:00 UK weekdays). Out-of-hours availability is best-effort.
- **NFR35 — Payment-cycle continuity:** Zero failed JFEPS payment cycles attributable to CTAM Pathfinder deployment, rollout, or runtime issues. Payment generation can fall back to manual handling within a payment cycle if CTAM Pathfinder is unavailable.
- **NFR36 — Per-wave rollback:** Each rollout wave has a documented rollback path returning the affected region to APEX within one operational cycle if the wave's gate is breached post-cutover.
- **NFR37 — Strategy A degraded-mode contract:** If federated read latency breaches NFR8, CTAM Pathfinder degrades to Strategy C cached projection rather than failing; cache freshness window is published in the service's OpenAPI spec metadata and surfaced in response headers (e.g. `Cache-Control`, `Age`).
- **NFR38 — rollout-wave isolation** *(jurisdiction-first[^d8])*: A wave activation or feature change targeting one (jurisdiction, region) does not affect users in other waves. *(Architectural enforcement is at the application tier via per-user `ctam_auth_user_activation_flags` carrying the (jurisdiction, region) tuple (FR57), not at the infrastructure tier.)*

**Architectural support:** Operational hours availability; per-wave rollback via (jurisdiction, region) activation flags (FR57); **single AKS cluster in UK South with multi-AZ node pools** (zone-redundant HA at app tier); **PostgreSQL Flexible Server zone-redundant HA** in UK South; wave isolation (NFR38) enforced at app tier via FR57 activation flags. Disaster recovery is an open gap — see [`./gaps.md` G3.6](./gaps.md).

## Maintainability (NFR39–NFR42)

- **NFR39 — API-as-Product standards:** Every service exposes versioned contracts, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details error envelopes, and a published OpenAPI specification (per FR58). Versioning and deprecation policy is a Phase 0 deliverable. Deprecation signalling uses [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) `Deprecation` + [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594) `Sunset` headers.
- **NFR40 — Per-service deployment unit:** Each of the 11 services is independently deployable on Kubernetes; rolling updates per service per region without coupling.
- **NFR41 — Behavioural-parity UAT suite**[^d11][^d5][^d13]: Every domain service has a **manual UAT script** (per FR60) maintained alongside the service. Jurisdiction-incumbent-experienced users walk through the script comparing CTAM Pathfinder vs the incumbent before each wave's cutover (`[ET-INCUMBENT-TBD]` users for **ET wave 1** — blocked on G8.4; ListAssist users for **SSCS wave 2**; APEX users for **Courts waves 3+**); sign-off (per role per wave) is the wave gate. There is no automated parity test suite — automated CI tests are unit, integration (Testcontainers), and contract tests only.
- **NFR42 — Postman collections:** Each phase produces a Postman collection that exercises the phase's endpoints; collections are versioned alongside the services.

**Architectural support:** API-as-Product standards (versioned, OpenAPI spec, [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details, [RFC 9745](https://datatracker.ietf.org/doc/html/rfc9745) `Deprecation` + [RFC 8594](https://datatracker.ietf.org/doc/html/rfc8594) `Sunset` for deprecation signalling); per-service deployment unit (one Spring Boot app, one container, one Helm chart); manual UAT scripts under `docs/uat/` per service; per-phase Postman collections.

[^d3]: Revised D3 (2026-06-10) — no data migration from any legacy system; judicial-holder reference data is ingested from the JOH eLinks API and MRD.
[^d5]: D5 — the jurisdiction's incumbent system is the behavioural reference, verified by manual UAT.
[^d7]: D7 — MVP observability is log-based; user-action audit is post-MVP.
[^d8]: D8 — rollout is jurisdiction-first, then per-region; jurisdiction is a first-class hierarchical attribute.
[^d11]: D11 (2026-06-10, amended 2026-06-18; **superseded by D13 2026-08-07 for wave ordering**) — SSCS pilot wave: CTAM Pathfinder replaces **ListAssist** (the SSCS judicial-scheduling tool); **GAPS (SSCS case management) is retained, not replaced**. Per D13 the SSCS wave is **wave 2**.

[^d13]: D13 (2026-08-07, supersedes D11) — ET-first pilot: wave 1 = the **Employment Tribunals (ET)** jurisdiction (scheduling incumbent `[ET-INCUMBENT-TBD]` — unidentified, gap G8.4); wave 2 = **SSCS** (replaces **ListAssist**; **GAPS**, SSCS case management, is retained); waves 3+ = Courts jurisdictions per HMCTS judicial region (replacing JI/APEX).
