---
type: 'Architecture Shard'
description: 'There are two UI repos with the same stack and conventions: ctam-ui (business-user-facing) and ctam-admin-ui (admin-facing).'
resource: 'architecture/tobe/repo-structure.html'
tags: [ctam-pathfinder, architecture]
timestamp: '2026-05-06'
parent: ../architecture.md
title: Repository Directory Structures, File Organisation, Local Development Workflow
last_updated: 2026-05-06
extracted_in: architecture.md v1.8 — Strategy B refactor
---

# Repository Directory Structures, File Organisation, Local Development Workflow

> Sibling of [`../architecture.md`](../architecture.md). The parent's *Project Structure & Boundaries* holds the architectural decisions. This file holds the per-repo directory inventory and the developer-facing build/run/deploy commands.

## Complete Project Directory Structure — per backend service

```
ctam-{service}/
├── README.md                                    (service-specific overview, runbook, contacts)
├── settings.gradle
├── build.gradle                             (Gradle Groovy DSL (per HMCTS template))
├── gradle.properties
├── gradlew, gradlew.bat                         (Gradle Wrapper, committed)
├── gradle/wrapper/
├── .github/
│   ├── CODEOWNERS                               (CTAM Pathfinder team + service-specific reviewers)
│   ├── PULL_REQUEST_TEMPLATE.md                 (patterns checklist)
│   └── workflows/
│       ├── ci.yml                               (build + test + lint + ArchUnit + Spectral)
│       ├── deploy-dev.yml
│       ├── deploy-staging.yml
│       └── deploy-production.yml                (per-region per-wave gated)
├── src/main/java/uk/gov/hmcts/ctam/{service}/
│   ├── {Service}Application.java
│   ├── controller/
│   │   ├── {Resource}Controller.java
│   │   └── HealthController.java
│   ├── service/
│   │   └── {Resource}Service.java
│   ├── repository/
│   │   └── {Resource}Repository.java
│   ├── domain/
│   │   ├── {Resource}.java                      (@Entity)
│   │   └── {ValueObject}.java
│   ├── dto/
│   │   ├── {Resource}Dto.java                   (response shape)
│   │   └── {Resource}Request.java               (request shape)
│   ├── client/
│   │   ├── AuthorisationClient.java             (per-service; called by JWTFilter for per-request authz)
│   │   └── {OtherService}Client.java            (other service-to-service API clients, e.g. for workflows; no ReferenceDataClient — Reference Data is read directly via JPA from the shared schema)
│   ├── config/
│   │   ├── JWTFilter.java                       (custom JWT filter, per HMCTS template)
│   │   ├── AuthDetails.java                     (request-scoped bean populated by JWTFilter)
│   │   ├── OpenApiConfig.java                   (Swagger Core; spec published by Gradle maven-publish as a Maven-format artefact)
│   │   └── CorrelationIdFilter.java
│                                                 (no IdempotencyFilter — retry safety is via native DB primitives; see ../architecture.md → Data Architecture)
│   ├── error/
│   │   ├── GlobalExceptionHandler.java          (@ControllerAdvice; RFC 9457 problem-details)
│   │   └── ProblemDetailFactory.java
│   └── exception/
│       ├── {Resource}NotFoundException.java
│       ├── BusinessRuleViolation.java
│       └── DependencyException.java
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-staging.yml
│   ├── application-production.yml
│   ├── logback-spring.xml                       (JSON logging + correlation-ID MDC)
│   └── db/changelog/                            (Liquibase)
│       ├── db.changelog-master.yaml
│       ├── 001-init.sql
│       ├── 002-add-judges-table.sql
│       └── ...
├── src/test/java/uk/gov/hmcts/ctam/{service}/
│   ├── controller/                              (unit tests, mocked deps)
│   ├── service/
│   ├── repository/                              (integration tests, Testcontainers)
│   └── client/
├── terraform/                                   (this repo's OWN Azure resources only, per-env stacks dev/staging/production — AR53 revised; the shared estate — AKS, PostgreSQL, ACR, APIM, App Insights, Key Vault — lives in the dedicated ctam-shared-infrastructure repo, provisioned in Epic 0.0 per the HMCTS CNP {product}-shared-infrastructure standard)
│   ├── dev/
│   ├── staging/
│   └── production/
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml                              (defaults)
│   ├── values-dev.yaml
│   ├── values-staging.yaml
│   ├── values-production.yaml                   (UK South production — multi-AZ node pool selection, zone-spread anti-affinity, min replicas)
│   └── templates/
│       ├── deployment.yaml                      (incl. topologySpreadConstraints for AZ spread)
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── configmap.yaml
│       └── hpa.yaml
├── postman/
│   ├── ctam-{service}-phase{N}.postman_collection.json
│   └── README.md                                (how to run; environment files)
├── api-spec/
│   └── openapi.yaml                             (committed snapshot, regenerated on release)
├── docs/
│   ├── README.md                                (service-specific architecture)
│   ├── decisions/                               (service-specific ADRs)
│   │   └── ADR-001-database-schema.md
│   ├── runbook.md                               (incident response per service)
│   ├── api/                                     (extended API docs beyond OpenAPI)
│   └── uat/                                     (manual UAT scripts: incumbent-vs-CTAM Pathfinder behavioural-parity walkthroughs per FR60 / NFR41 revised; domain services only)
├── .gitignore
└── .editorconfig
```

## Complete Project Directory Structure — UI repos

There are **two UI repos** with the same stack and conventions: `ctam-ui` (business-user-facing) and `ctam-admin-ui` (admin-facing). The split exists so admin workflows (Reference Data maintenance, User & Role admin) cannot leak into business users' nav, and so each has its own CI/CD, CODEOWNERS, and rollout cadence. `ctam-admin-ui` mirrors the structure below, with admin modules replacing the per-domain operational modules.

### `ctam-ui` (business)

```
ctam-ui/
├── README.md
├── package.json
├── package-lock.json (or yarn.lock / pnpm-lock.yaml)
├── tsconfig.json
├── vite.config.ts
├── playwright.config.ts
├── vitest.config.ts
├── eslint.config.js
├── .prettierrc
├── index.html
├── public/
│   ├── favicon.ico
│   └── assets/
├── src/
│   ├── main.tsx                                 (entry point; root render + StrictMode)
│   ├── App.tsx                                  (router root + auth wrapper + ErrorBoundary)
│   ├── routes.tsx                               (all route definitions)
│   ├── modules/                                 (per-domain UI modules)
│   │   ├── home/
│   │   │   ├── pages/HomePage.tsx
│   │   │   └── index.ts
│   │   ├── judge/
│   │   │   ├── pages/JudgeListPage.tsx
│   │   │   ├── pages/JudgeDetailPage.tsx
│   │   │   ├── components/JudgeCard.tsx
│   │   │   ├── components/WorkingPatternEditor.tsx
│   │   │   ├── hooks/useJudgeList.ts
│   │   │   ├── hooks/useJudge.ts
│   │   │   ├── api/                             (generated TypeScript client from Judge OpenAPI)
│   │   │   └── index.ts
│   │   ├── absence/
│   │   ├── vacancy/
│   │   ├── booking/
│   │   ├── sitting/
│   │   ├── payment/
│   │   ├── itinerary/
│   │   └── reports/
│   ├── shared/
│   │   ├── components/
│   │   │   ├── Layout.tsx
│   │   │   ├── Header.tsx
│   │   │   ├── ErrorBoundary.tsx
│   │   │   └── ErrorMessage.tsx
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   └── useCorrelationId.ts
│   │   ├── auth/
│   │   │   ├── HmctsIdpProvider.tsx             (OIDC client wrapper)
│   │   │   └── ProtectedRoute.tsx
│   │   └── api/
│   │       ├── httpClient.ts                    (TanStack Query setup; auth header attachment)
│   │       └── errorHandling.ts                 (RFC 9457 problem-details → display)
│   └── styles/
│       ├── govuk.scss                           (GOV.UK Design System imports)
│       └── overrides.scss                       (HMCTS / CTAM Pathfinder extensions)
├── tests/
│   ├── unit/                                    (Vitest)
│   └── e2e/                                     (Playwright; one suite per phase)
│       ├── phase-1-judge.spec.ts
│       ├── phase-2-absence.spec.ts
│       └── ...
├── api-clients/                                 (generated; regenerated in CI from per-service OpenAPI)
│   ├── judge-client/
│   ├── absence-client/
│   └── ...
├── helm/                                        (Helm chart for Static Web App / CDN deployment)
├── .github/
│   ├── CODEOWNERS
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── ci.yml                               (build + test + lint + axe-core)
│       └── deploy-{env}.yml
└── docs/
    ├── README.md
    └── decisions/                               (UI-specific ADRs)
```

### `ctam-admin-ui` (admin)

Same scaffolding as `ctam-ui` above — React + TypeScript + Vite + Vitest + Playwright, GOV.UK Design System, OIDC client, RFC 9457 error handling, axe-core in CI — but with admin modules instead of per-domain operational modules.

```
ctam-admin-ui/
├── (same top-level scaffolding as ctam-ui: package.json, vite.config.ts, etc.)
├── src/
│   ├── main.tsx
│   ├── App.tsx
│   ├── routes.tsx
│   ├── modules/                                 (admin modules only)
│   │   ├── home/
│   │   │   ├── pages/AdminHomePage.tsx          (admin-scoped Home; system administrator role)
│   │   │   └── index.ts
│   │   ├── reference-data/                      (FR6 — RSU-with-admin-rights and system administrators)
│   │   │   ├── pages/RegionsAdminPage.tsx
│   │   │   ├── pages/OfficesAdminPage.tsx
│   │   │   ├── pages/VocabulariesAdminPage.tsx  (12 judicial vocabularies)
│   │   │   ├── pages/CalendarAdminPage.tsx      (financial-year boundaries, calendar periods)
│   │   │   ├── components/NamedOwnerSignOff.tsx (cross-cutting sign-off pattern per FR6)
│   │   │   ├── hooks/useReferenceDataAdmin.ts
│   │   │   ├── api/                             (generated TypeScript client from ctam-reference-data OpenAPI)
│   │   │   └── index.ts
│   │   └── users-roles/                         (FR4 — system administrators)
│   │       ├── pages/UserListPage.tsx
│   │       ├── pages/UserDetailPage.tsx          (role assignment, Region/Area scope)
│   │       ├── components/RoleAssignmentEditor.tsx
│   │       ├── hooks/useUserAdmin.ts
│   │       ├── api/                             (generated TypeScript client from ctam-authorisation OpenAPI)
│   │       └── index.ts
│   ├── shared/                                  (mirrors ctam-ui — auth, http client, error handling, layout)
│   │   ├── components/Layout.tsx                 (Admin-specific Header marking this as the admin surface)
│   │   ├── hooks/useAuth.ts
│   │   ├── auth/HmctsIdpProvider.tsx
│   │   ├── auth/ProtectedRoute.tsx               (gates routes by admin role from ctam-authorisation)
│   │   └── api/httpClient.ts
│   └── styles/
│       ├── govuk.scss
│       └── admin-overrides.scss                  (visual marker: admin surface — distinct accent for the header / nav)
├── tests/
│   ├── unit/                                    (Vitest)
│   └── e2e/                                     (Playwright)
│       ├── reference-data.spec.ts
│       └── users-roles.spec.ts
├── api-clients/                                 (generated; regenerated in CI from ctam-reference-data + ctam-authorisation OpenAPI specs)
│   ├── reference-data-client/
│   └── authorisation-client/
├── helm/                                        (Helm chart for Static Web App / CDN deployment — separate from ctam-ui)
├── .github/
│   ├── CODEOWNERS                                (admin-team scoped; distinct from ctam-ui)
│   └── workflows/
│       ├── ci.yml                                (build + test + lint + axe-core)
│       └── deploy-{env}.yml
└── docs/
    ├── README.md
    └── decisions/                                (admin-UI-specific ADRs)
```

**Future admin surfaces reserved** (not built at MVP — placeholders only):

- `modules/activation/` — per-(jurisdiction, region) activation flag dashboard (FR57 admin side)
- `modules/migration-reports/` — Phase 0 reconciliation report viewer (FR57)
- `modules/audit/` — post-MVP user-action audit viewer (D7 roadmap)

**Deployment:** independent of `ctam-ui`. Same Azure Static Web Apps pattern, separate hostname (e.g. `admin.ctam.hmcts.gov.uk` vs `ctam.hmcts.gov.uk`), separate Helm release, separate per-environment rollout.

## Complete Project Directory Structure — `ctam-architecture` repo

```
ctam-architecture/
├── README.md
├── architecture.md                              (the index document — see ../architecture.md)
├── architecture/                                (sibling files referenced by architecture.md)
│   ├── gaps.md
│   ├── assumptions.md
│   ├── changelog.md
│   ├── conventions.md
│   ├── repo-structure.md
│   ├── starter-template.md
│   └── data-tables.md
├── prd.md                                       (mirror of PRD; canonical lives in planning-artifacts)
├── decisions/                                   (programme-level ADRs)
│   ├── ADR-001-greenfield-not-strangler.md
│   ├── ADR-002-no-shared-library.md
│   ├── ADR-003-rest-first-no-event-bus.md
│   └── ...
├── api-specs/                                   (aggregated per-service OpenAPI specs; mirror)
│   ├── reference-data/openapi.yaml
│   ├── authorisation/openapi.yaml
│   └── ...
├── diagrams/                                    (C4 model, sequence diagrams, deployment topology)
├── scaffolding/
│   ├── README.md
│   ├── ctam-scaffold.sh                          (creates new service from HMCTS starter)
│   ├── templates/                               (service-specific overlays applied by the script)
│   └── conventions/
├── (migration/ — does not exist: no legacy data migration per the revised D3; reference data arrives via ctam-reference-data's upstream ingestion)
│   ├── README.md                                (mapping notes, run procedure, sign-off checklist)
│   ├── reference-data/                          (extract + transform + POST to ctam-reference-data)
│   │   ├── extract-apex.sql                     (selects against APEX schema; produces CSV/JSON)
│   │   ├── transform.py (or .ts / .java)        (APEX shape → CTAM Pathfinder shape per data-tables.md)
│   │   └── load.py                              (calls Reference Data API: POST /v1/regions etc.)
│   ├── users-roles/                             (extract + reconcile to IdP + POST to ctam-authorisation)
│   │   ├── extract-apex.sql
│   │   ├── reconcile.py                         (email-then-employee-number match against IdP principals; produces matched / employee-matched / unmatched buckets)
│   │   ├── transform.py
│   │   └── load.py                              (calls Authorisation API)
│   ├── reports/                                 (per-run reconciliation reports for sign-off)
│   └── tests/                                   (golden-input → expected-output cases)
└── runbooks/
    ├── incident-response.md
    └── per-region-rollout-playbook.md
```

**Why `migration/` lives here, not as a separate service or as Liquibase changesets:**

- The migration is a **one-shot programme deliverable** (Phase 0; re-run per wave for incremental user activation). It is not a runtime service, so it has no `controller/` / `service/` / `repository/` shape.
- It is **owned by the architecture team** (and the named Phase 0 owners per Risk #13), not by any single domain service. Living under `ctam-architecture/` keeps that ownership visible.
- It **calls CTAM Pathfinder APIs** (Reference Data API, Authorisation API) — it does not write directly to CTAM Pathfinder tables. Per the v1.6 decision, writes go via the API so validation, idempotency, and any audit-logging hooks fire.
- It is **separate from Liquibase**. Liquibase in CTAM Pathfinder is for CTAM Pathfinder's DDL (creating tables, adding columns, granting permissions). The ETL is for moving APEX data into CTAM Pathfinder tables that Liquibase has already created.

## Complete Project Directory Structure — `ctam-shared-infrastructure` repo

```
ctam-shared-infrastructure/
├── README.md                          (estate overview, provisioning runbook, contacts)
├── terraform/
│   ├── modules/
│   │   ├── network/                   (resource group, VNet, subnets)
│   │   ├── aks/                       (cluster + multi-AZ node pools)
│   │   ├── postgres/                  (Flexible Server, zone-redundant HA, TLS-enforced)
│   │   ├── keyvault/                  (vault + AKS workload-identity wiring)
│   │   ├── acr/                       (container registry)
│   │   ├── observability/             (App Insights + Log Analytics + retention)
│   │   └── apim/                      (instance + base policies + smoke API)
│   ├── dev/                           (stack: composes modules; remote state backend)
│   ├── staging/
│   └── production/                    (UK South; zone-redundant SKUs — A34)
├── verification/                      (per-layer deploy-time smoke checks — Epic 0.0 ACs)
│   ├── aks-nodes.sh                   (kubectl get nodes + hello pod schedules)
│   ├── postgres-tls.sh                (TLS-only connect; plaintext refused; scratch DB)
│   ├── keyvault-roundtrip.sh          (secret round-trips from a pod via workload identity)
│   ├── acr-observability.sh           (image push/pull; test trace + log land in App Insights)
│   └── apim-smoke.sh                  (gateway → echo 200; testssl.sh TLS floor)
├── .github/
│   ├── CODEOWNERS                     (platform/infra team)
│   ├── PULL_REQUEST_TEMPLATE.md       (infra-change checklist)
│   └── workflows/
│       ├── ci.yml                     (terraform fmt + validate + plan on PR)
│       └── apply-{env}.yml            (gated apply on merge; manual approval staging/prod)
└── docs/
    ├── README.md
    └── decisions/                     (estate-level ADRs)
```

**Why the shared estate lives here, not in a service repo:** product-level shared infrastructure gets its own dedicated `{product}-shared-infrastructure` repo per the HMCTS Cloud Native Platform standard (AR53 revised) — it is not colocated inside the first service scaffolded. The `verification/` scripts are the deploy-time acceptance tests from Epic 0.0: each Terraform layer is proven as it lands (AKS reachable, PostgreSQL TLS-only, Key Vault round-trips, ACR pull works, telemetry ingests, APIM routes over TLS) before any service depends on it. This repo has **no `src/`, no Helm chart, no deployable workload** — Terraform provisions the estate; services (via Helm) deploy onto it.

## File Organisation Patterns

**Configuration files:**

- Per-service: `application.yml` defaults + per-profile overrides + Logback config.
- Per-environment: Helm `values-{env}.yaml` files; secrets externalised to Azure Key Vault.
- No environment-specific code branches; everything controlled by Spring profiles.

**Test organisation:**

- Unit tests: `src/test/java/.../{layer}/...` mirroring main package layout.
- Integration tests: same location, `*IT.java` suffix, Testcontainers PostgreSQL.
- Contract tests (Pact or equivalent): `src/test/java/.../contract/`.
- Manual UAT scripts (FR60 / NFR41 revised): `docs/uat/` per domain service — markdown walkthroughs for jurisdiction-incumbent-experienced users to follow side-by-side against the incumbent (`[ET-INCUMBENT-TBD]` wave 1; ListAssist wave 2; APEX waves 3+). Not part of automated CI.
- E2E tests: separate `tests/e2e/` directory in `ctam-ui` repo, Playwright per phase.

**Asset organisation (UI):**

- `public/` for static assets shipped as-is (favicon, robots.txt).
- `src/styles/` for SCSS sources; Vite compiles to bundled CSS.
- Per-module assets stay within the module (`modules/judge/assets/`).

## Development Workflow Integration

**Local development per service:**

```bash
# Clone the service repo
git clone https://github.com/hmcts/ctam-{service}.git
cd ctam-{service}

# Run locally (uses Testcontainers for DB and stub Authorisation in dev profile)
./gradlew bootRun --args='--spring.profiles.active=dev'

# Run tests
./gradlew check        # all checks (unit + integration + ArchUnit + lint)
./gradlew test         # unit only
./gradlew integrationTest

# Build container image
./gradlew jib          # or ./gradlew bootBuildImage
```

**Local development for UI:**

```bash
git clone https://github.com/hmcts/ctam-ui.git
cd ctam-ui

# Install dependencies
npm install   # or yarn / pnpm

# Regenerate API clients from latest committed OpenAPI specs
npm run generate-clients

# Run dev server (proxies to local backend services or stubs)
npm run dev

# Run tests
npm run test         # Vitest
npm run test:e2e     # Playwright
```

**Build / Deploy flow per service:**

```
git push origin feature/...
       │
       ▼
[GitHub Actions / Azure DevOps]
   ├─ Build (Gradle)
   ├─ Test (unit + integration)
   ├─ Lint (Spotless + Checkstyle + ArchUnit)
   ├─ OpenAPI lint (Spectral)
   └─ Helm chart lint
       │
PR merge to main
       │
       ▼
[Auto-deploy to dev]
   ├─ Build container image → Azure Container Registry
   └─ Helm upgrade → AKS (dev)
       │
Manual approval
       │
       ▼
[Deploy to staging]
       │
Manual approval (per region/wave)
       │
       ▼
[Deploy to production-uk-south] (or per-region)
   └─ Manual UAT sign-off by jurisdiction-incumbent-experienced users runs as gate (FR60 / NFR41 revised)
```

> The architectural rules for the per-region production gate (manual UAT, automated tests, migration sign-off, programme sign-off) and the rollback path live in [`../architecture.md`](../architecture.md) under *Region rollout flow (Phase 9+)*.

