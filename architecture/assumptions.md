---
type: 'Architecture Shard'
description: 'Each assumption is either:'
resource: 'architecture/tobe/assumptions.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-05-06'
parent: ../architecture.md
title: Assumptions (A1–A37)
last_updated: 2026-05-06
extracted_in: architecture.md v1.8 — Strategy B refactor
---

# Assumptions (A1–A37)

> Sibling of [`../architecture.md`](../architecture.md). Linked from *Architecture Validation Results*.

Each assumption is either:

- An external precondition (verifiable with the named owner before Phase 0 or pre-Phase-9), or
- A simplifying choice that can be revisited if wrong.

Assumptions that affect implementation correctness (not just convenience) are flagged **load-bearing**.

| ID | Assumption | Type | Verification |
|---|---|---|---|
| **A1** | HMCTS IdP supports OIDC for human-user authentication | Load-bearing **for Phase 9+ only** | Pre-Phase-9 prerequisite (G1.1) |
| **A2** *(reopened v2.6, 2026-05-07)* | HMCTS IdP supports OAuth 2.0 `client_credentials` grant for service principals — needed in production for the **payment-processing batch** (introduced in v2.6). At MVP this is satisfied by `ctam-mock-auth` (non-prod only); production issuer is a deferred decision (G7.1, with Azure Workload Identity as the default recommendation). | Pre-Phase-9 decision per G7.1; mock covers Phase 0–8 |
| **A3** | HMCTS IdP supports principal export / query API for pre-Phase-9 reconciliation | Load-bearing **for Phase 9+ only** | Pre-Phase-9 prerequisite (G1.3); manual fallback documented |
| **A4** *(reconciled 2026-06-17)* | HMCTS Crime SpringBoot template (`hmcts/service-hmcts-crime-springboot-template`@`main`) is the scaffold for CTAM Pathfinder. **Base is minimal** — provides Java 25, Spring Boot **4.1.0**, Gradle Groovy DSL, OpenTelemetry, Logstash JSON logging, Lombok, JaCoCo, CycloneDX, gradle-git-properties, ben-manes-versions, Actuator, `webmvc-test`, Dockerfile. **NOT in the baseline** (added by `ctam-scaffold.sh` from the separate `hmcts/service-hmcts-springboot-demo` repo or as CTAM conventions): Liquibase, Testcontainers, MapStruct, custom JWTFilter/`jjwt`, OWASP encoder, docker-compose plugin, OpenAPI tooling, Helm chart, Spring Cloud Azure Key Vault. | Load-bearing | Reconciled against `main` 2026-06-17 (G1.4); the prior "all present" note overstated the baseline; scaffolding scope tracked in G1.4a |
| **A5** | HMCTS Email infrastructure is reachable from AKS-hosted Notification service via documented transport | Load-bearing | Phase 0 prerequisite (G1.5) |
| **A6** | HMCTS / MoJ approves Microsoft Azure as cloud platform with UK regions for personal data | Load-bearing | Programme assumption (G3.1) |
| **A7** | HMCTS / MoJ approves PostgreSQL on Azure Database for PostgreSQL Flexible Server | Reversible | G3.2 |
| **A8** | HMCTS / MoJ approves Azure API Management for ingress and rate limiting | Reversible | G3.3 |
| **A9** | HMCTS / MoJ approves React + TypeScript with GOV.UK Design System | Reversible | G3.4 |
| **A10** | Azure-managed encryption keys are sufficient for HMCTS data residency | Load-bearing | HMCTS security review |
| **A11** | The 12 user roles documented in `functional-modules.md` line 497 are the authoritative role set for CTAM Pathfinder Authorisation | Load-bearing | Verified against PRD |
| **A12** *(revised 2026-05-06)* | APEX is accessible to the APEX-experienced UAT panel for the duration of build and per-wave UAT cycles, via existing logins. (Earlier assumption that APEX must be reachable from build-time CI for an automated parity harness was retracted with FR61 / NFR41.) | Load-bearing for UAT scheduling, not for CI | D5 + D6; verify APEX user-account availability per wave |
| **A13** *(revised 2026-05-06)* | APEX behaviour is stable for the duration of the build, as observed by UAT users. If APEX changes, UAT scripts and CTAM Pathfinder behaviour are updated in lockstep. | Reversible | Risk |
| **A14** | APEX continues to be operable during the phased rollout window (12 months read-only post-cutover per region) | Load-bearing | Per Step 4; programme to confirm |
| **A15** | HMCTS retention policy is satisfied by 30-day hot + 90-day cold log retention | Reversible | Pre-GA review |
| **A16** | Order-of-magnitude capacity (~50–100 per region, ~200–500 national) is broadly correct | Reversible | Programme to confirm |
| **A17** | DA&I and future programmes adopt API-based integration post-MVP | Aspirational | Programme dependency |
| **A18** | UK GDPR + DPA 2018 are the binding privacy regimes; no EU GDPR cross-border concerns | Load-bearing | UK-only deployment |
| **A19** | No bank details, no case-level data invariants from APEX continue to apply to CTAM Pathfinder | Load-bearing | Per PRD |
| **A20** | Azure subscription is provisioned per HMCTS / MoJ standard with appropriate RBAC; all resources within it are Terraform-provisioned per the 2026-06-11 decision (shared estate in the dedicated `ctam-shared-infrastructure` repo per decision #13, 2026-07-06) | Reversible | Phase 0 prerequisite; Terraform conventions per G9.1 |
| **A21** | CI/CD platform is Azure DevOps Pipelines or GitHub Actions per HMCTS standard | Reversible | HMCTS standard |
| **A22** | HMCTS-approved security tooling is available and integrated at platform level | Reversible | HMCTS infrastructure |
| **A23** | The locked decisions D1–D9 from the PRD are programme-approved and binding | Load-bearing | Per PRD |
| **A24** | The 11-service decomposition (revised v2.2, 2026-05-07 — `ctam-configuration` dropped in favour of Spring profiles + Key Vault and a shared `ctam_configuration_values` infrastructure table) is programme-approved and binding | Load-bearing | Per PRD |
| **A25** | The team has Java + Spring Boot + Kubernetes + React + TypeScript skills available, or budget for upskilling | Reversible | Programme staffing |
| **A26** *(widened v2.6, 2026-05-07)* | Mock auth (Spring Authorization Server) provides full OIDC contract parity with the production issuer for (a) human `authorization_code` and (b) `client_credentials` for batch service principals (initially `ctam-payment-batch`). | Load-bearing | Phase 0 deliverable; integration tests verify human + service-principal contract parity |
| **A27** | Mock auth never runs in production; CI lint and Spring profile validation prevent this | Load-bearing — critical for production security | Phase 0 deliverable; enforced by CI rules |
| **A28** | One global PostgreSQL Flexible Server instance is sufficient for the full bounded CTAM Pathfinder workload (~hundreds of concurrent users, read-mostly patterns, indexed joins) | Load-bearing | Phase 0 sizing decision; reversible — can introduce read replicas post-MVP per Principle 2 |
| **A29** *(reconciled 2026-06-17; Flyway → Liquibase 2026-06-18)* | Schema evolution: **Liquibase** (`liquibase-core`). **Liquibase is NOT in the template baseline** — it is a CTAM convention added by `ctam-scaffold.sh` (the HMCTS demo repo's Database branch uses Flyway; CTAM standardises on Liquibase, per AR19/G1.4a). Liquibase owns CTAM Pathfinder's own DDL — table creation, column add/drop, grants. **Not** upstream data movement; the JOH eLinks sync and MRD ingestion (see [`../architecture.md`](../architecture.md) → *Upstream reference-data ingestion*; replaced the retracted Phase 0 ETL[^d3]) load tier-(a) data into tables Liquibase has already created. | Tool sourcing corrected 2026-06-17 (was wrongly attributed to the template baseline); ingestion reframing 2026-06-11; Flyway → Liquibase 2026-06-18 |
| **A30** | "No premature optimization" principle holds for MVP — no caching, no distributed cache, no service mesh, no read replicas, no async messaging unless measurement post-MVP justifies the complexity | Load-bearing principle | Self-enforced by architecture; review post-MVP per measured performance |
| **A31** | The shared-schema cross-service access model (table-name convention + per-service DB roles + explicit grants + fitness functions) is operationally maintainable with PR-coordination between services. | Reversible | If maintenance burden grows: retreat to API-only writes (reads-via-direct-SQL stays). If isolation needs grow: introduce schema-per-service — per-service DB roles already make this a grants-and-tables refactor, not a connection-layer change. |
| **A32** *(SUPERSEDED 2026-06-11)* | ~~Phase 0 Reference Data + Users/Roles migration is an ETL.~~ Superseded by the revised D3 (2026-06-10): no legacy migration of any kind; reference data is ingested from JOH eLinks + MRD (see A36); user/authorisation records are bootstrapped by mechanisms outside the PRD's scope[^d9]. | Superseded | Closed — see A36/A37 and G8.1. |
| **A33** *(SUPERSEDED 2026-06-11)* | ~~Migration tool's APEX-side input mapping revalidated against the APEX SQL dump.~~ Superseded with the ETL. The successor concern — validating the ingestion mapping against the JOH eLinks contract and the first MRD workbook — is G8.1; the table inventory remains CTAM Pathfinder's design (now 55 tables in [`./data-tables.md`](./data-tables.md)). | Superseded | Closed — see G8.1. |
| **A34** | Azure UK South provides three availability zones with zone-redundant managed services (AKS multi-zone node pools, PostgreSQL Flexible Server zone-redundant HA, Key Vault Premium, APIM Premium, ACR Premium). | Load-bearing | Phase 0 infra-provisioning verification (via the Story 0.1.1 Terraform apply); if any zone-redundant SKU is unavailable, the component degrades to single-zone HA + accepted-risk note. |
| **A35** *(softened v2.6, 2026-05-07)* | Most MVP runtime requests are user-initiated. One exception: the payment-processing batch (`ctam-payment-batch`), which runs on a schedule and authenticates as a service principal. User-initiated inter-service auth: JWT propagation. Batch inter-service auth: OAuth `client_credentials` against `ctam-mock-auth` in non-prod; production issuer per G7.1. Other non-user-initiated flows (DA&I service-consumer calls, scheduled aggregations, async messaging) are out of MVP scope and would reuse the service-principal pattern. Phase 0 production migration runs operator-initiated (G4.7); dev/CI seeding via one-off scripts. | Load-bearing | The payment batch is the only non-user-initiated runtime flow at MVP. Adding more reopens the production service-auth choice (G7.1). |
| **A36** *(new 2026-06-11)* | The JOH eLinks API exposes all 15 `jo_*` entities with stable natural keys (`personnel_number` for `jo_people`) at a cadence compatible with a nightly pull, and the jurisdiction hierarchy's parent-child shape is available natively or derivable on ingest[^d8]. | Load-bearing for the reference-data tier and the JOH identity lookup | Verify against the eLinks API contract in Phase 0 (G8.1). |
| **A37** *(new 2026-06-11)* | The MRD team can deliver the weekly Excel workbook to an agreed Azure Blob container in a stable shape, and the workbook's entities carry jurisdiction-aware reference data as stated in the revised D3. | Load-bearing for tier-(a) MRD data (JOH Specialisations) | Verify with the MRD team in Phase 0 (G8.1); transitional until MRD public APIs ship. |

[^d3]: Revised D3 (2026-06-10) — no data migration from any legacy system; judicial-holder reference data is ingested from the JOH eLinks API and MRD.
[^d8]: D8 — rollout is jurisdiction-first, then per-region; jurisdiction is a first-class hierarchical attribute.
[^d9]: Restructured D9 (2026-06-10; refined 2026-07-09 per SCP) — two user populations. JOHs resolve IdP email → `jo_people` → `personnel_number` → a **CTAM-assigned JOH UUID** (`ctam_joh_identities`); HMCTS admin staff via a CTAM-internal identity table. Both key on a CTAM-assigned UUID; `personnel_number` is the upstream link only. No legacy user migration.
