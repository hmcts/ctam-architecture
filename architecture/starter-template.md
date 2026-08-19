---
type: 'Architecture Shard'
description: 'Each new CTAM Pathfinder service is scaffolded from the HMCTS starter, then customised. The exact CLI depends on what HMCTS publishes; conceptual flow:'
resource: 'architecture/tobe/starter-template.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-05-06'
parent: ../architecture.md
title: HMCTS Crime SpringBoot starter — initialisation, build tool, dependency inventory, CTAM Pathfinder conventions
last_updated: 2026-05-06
extracted_in: architecture.md v1.8 — Strategy B refactor
---

# Starter Template — Initialisation Flow, Build Tool, Dependency Inventory, CTAM Pathfinder Conventions

> Sibling of [`../architecture.md`](../architecture.md). Selection rationale lives in the parent. This file holds the per-service initialisation flow, dependency inventory, and CTAM Pathfinder conventions overlaid by the scaffolding script.

## Initialisation Flow (per service)

Each new CTAM Pathfinder service is scaffolded from the HMCTS starter, then customised. The exact CLI depends on what HMCTS publishes; conceptual flow:

```bash
# Conceptual — actual command per HMCTS published documentation
git clone https://github.com/hmcts/service-hmcts-crime-springboot-template.git ctam-{service-name}
cd ctam-{service-name}
git remote remove origin
git remote add origin <new-repo-url>

# Rename package, artifact, application name to match the service
# (specific tooling / scripts per HMCTS starter conventions)
./scripts/rename uk.gov.hmcts.ctam.{service-name}

# Verify build
./gradlew build

# Initial commit on new repo
git add . && git commit -m "Scaffold CTAM Pathfinder {service-name} from HMCTS starter"
git push -u origin main
```

**CTAM Pathfinder scaffolding script:** a thin wrapper over the HMCTS starter clone-and-rename steps, with CTAM Pathfinder-specific defaults (Azure UK region, Application Insights workspace, naming conventions). Used at service-creation time only — not a runtime dependency.

## Build Tool: Gradle

Gradle for all 11 services and the scaffolding script.

Reasons:

- Flexible for per-service repos + occasional cross-repo conventions.
- Fast incremental builds; works well for per-service Postman collection generation and OpenAPI artefact publication.
- Matches the HMCTS starter's typical default.
- Consistent across all services.

## Architectural Decisions: Base Template vs CTAM Scaffolding Overlay

**Reconciled 2026-06-17 against `hmcts/service-hmcts-crime-springboot-template`@`main`.** The base template is **deliberately minimal** — its README states it provides "the core Spring Boot scaffold — actuator, observability, logging — without any domain-specific or infrastructure patterns built in." Feature patterns (database, security, messaging, Azure) live in the **separate `hmcts/service-hmcts-springboot-demo` repo** across branches. CTAM Pathfinder's `ctam-scaffold.sh` therefore overlays those patterns (cherry-picked from the demo repo) plus CTAM conventions on top of the minimal base. The two layers:

### A. Provided by the base template (`main`) — verified in `build.gradle`

**Language & Runtime:**

- Java 25 (current LTS).
- Spring Boot 4.1.x (template `main` pins **4.1.0** as of 2026-06-17).
- Gradle build with Gradle Wrapper (`gradlew`) committed.

**Build tooling (plugins):**

- **Gradle Groovy DSL**; `application` + `java` plugins.
- **Spring Boot Gradle plugin 4.1.0**.
- **`io.spring.dependency-management:1.1.7`** for BOM-based dependency management.
- **JaCoCo** for code coverage; **`maven-publish`** (the Gradle publishing plugin) for publishing Maven-format artefacts.
- **`org.cyclonedx.bom:3.2.4`** for SBOM (supply-chain security).
- **`com.gorylenko.gradle-git-properties:4.0.1`** to embed Git metadata in `/actuator/info`.
- **`com.github.ben-manes.versions:0.54.0`** for dependency-update reports.

**Dependencies:**

- **`net.logstash.logback:logstash-logback-encoder:9.0`** — structured JSON logs.
- **`org.projectlombok:lombok:1.18.46`** — boilerplate reduction.
- `spring-boot-starter-web`, `spring-boot-starter-actuator`, **`spring-boot-starter-opentelemetry`** (traces → OTel → App Insights).
- `spring-boot-starter-webmvc-test`, `spring-boot-starter-test` (JUnit 5; vintage/junit4 excluded).
- `org.apache.tomcat.embed:tomcat-embed-core:11.0.22` (pinned).

**Also in base:** Dockerfile (multi-stage), Spring Actuator probes (`/actuator/health|info|readiness`), Shell init/rename scripts, secure-header / TLS posture.

### B. Added by `ctam-scaffold.sh` — patterns from `hmcts/service-hmcts-springboot-demo` + CTAM conventions (NOT in the base)

> These are the scaffolding script's real scope. Each is **absent from the base `build.gradle`** and must be assembled from the demo repo (branch named) or added as a CTAM convention. Versions below are CTAM's chosen targets.

| Capability | Source / demo branch | Version target |
|---|---|---|
| **Liquibase** (`liquibase-core` + PostgreSQL driver) | CTAM convention (HMCTS demo repo uses Flyway; CTAM standardises on Liquibase) | per Spring Boot 4.1 BOM |
| **Testcontainers** (`spring-boot-testcontainers:4.1.0` + `testcontainers-postgresql:1.21.4` + `-junit-jupiter:1.21.4`) | Database demo | as listed |
| **MapStruct** (compile-time DTO↔entity mapping) | CTAM convention | 1.6.3 |
| **Custom `JWTFilter`** + `io.jsonwebtoken:jjwt` | Security demo (JWT filters / Entra ID) | jjwt 0.13.0 |
| **`org.owasp.encoder:encoder`** (XSS-safe output) | CTAM convention | 1.4.0 |
| **`com.avast.gradle.docker-compose`** plugin (local dev deps) | CTAM convention | 0.17.21 |
| **OpenAPI tooling** (springdoc / Swagger Core; spec artefact published by Gradle `maven-publish` in Maven format) | Controllers & API demo | per AR8 |
| **Helm chart** for AKS | CTAM convention (G1.4a) | — |
| **Azure Key Vault** via Spring Cloud Azure | Azure demo / `azure-vault-demo` (G1.4b) | — |
| **Spectral · ArchUnit · Spotless · Checkstyle** (CI quality gates) | CTAM convention (AR17) | — |
| **Pact** (consumer-driven contract tests) | per service (AR16) | — |

**Code organisation (base layout, CTAM package naming):**

- Standard Gradle layout: `src/main/java`, `src/main/resources`, `src/test/java`.
- Per-service top-level package `uk.gov.hmcts.ctam.{service-name}` (e.g. `uk.gov.hmcts.ctam.referencedata`, `uk.gov.hmcts.ctam.booking`).
- `@SpringBootApplication` entrypoint; layered controller / service / repository per [`./conventions.md`](./conventions.md).

> **Correlation-ID filter** and the **APPINSIGHTS export wiring** are partly base (logging/OTel) and partly CTAM overlay (the request-entry correlation filter + service-to-service propagation); `/actuator/metrics` + Prometheus remain unexposed at MVP[^d7].

## Per-service CTAM Pathfinder Conventions (encoded in scaffolding script, not in shared library)

The scaffolding script applies CTAM Pathfinder-specific defaults on top of the HMCTS starter:

- Group ID: `uk.gov.hmcts.ctam`.
- Naming: artefact `ctam-{service-name}`, package `uk.gov.hmcts.ctam.{service-name}`.
- Default Azure UK region: UK South. (DR scope and target region are an open gap — see [`./gaps.md` G3.6](./gaps.md).)
- Default Application Insights workspace: CTAM Pathfinder shared workspace (HMCTS-provided).
- Default Reference Data and Authorisation service URL placeholders.
- Boilerplate `@ControllerAdvice` for [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457) problem-details error envelopes (formerly RFC 7807; obsoleted July 2023 — content type and field shape unchanged).
- Boilerplate `JWTFilter` + `AuthDetails` bean (per HMCTS template pattern); modified to call CTAM Pathfinder Authorisation service per request (CTAM Pathfinder variance from template's claims-only approach — required by FR2/FR57).
- Boilerplate Reference Data direct-SQL access (JPA entities mapped to whitelisted Reference Data tables — both tiers, see [`./data-tables.md`](./data-tables.md): upstream-sourced `jo_*`/`mrd_*` plus CTAM-owned `ctam_regions`, `ctam_offices`, `ctam_calendar_periods` and vocabularies); no client class.
- *(removed 2026-05-06)* Boilerplate APEX-comparison test base class — retracted. Behavioural parity is verified via **manual UAT performed by APEX-experienced users** (FR61 / NFR41 revised). Per-service UAT scripts live under `docs/uat/` in the service repo, not as test code.
- Default port `8082` (per HMCTS template).

These are **scaffolded once per service**; subsequent edits live in the service's own repo. There is no upstream library that can force a redeployment.

**Note:** Project initialisation using these commands and the scaffolding script should be the first implementation story per service.

[^d7]: D7 — MVP observability is log-based; user-action audit is post-MVP.
