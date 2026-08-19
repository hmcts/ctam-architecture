---
id: agent-rules/enforcement
title: Enforcement pack — rule → enforcer map
status: draft
last_updated: 2026-08-19
---

# Enforcement pack

Each rule in `agent-rules/` is stated once in prose and enforced once here. **A rule whose enforcer
below reads _review only_ is a known soft spot** — recorded deliberately, so nobody mistakes the
prose for a guarantee.

Editing anything in this directory to make a build pass is prohibited (**R9**). Threshold and rule
changes go through a Sprint Change Proposal in the control plane and a new context-bus version.

## Contents

| File | Enforces | Installed at |
|---|---|---|
| `java/ArchitectureFitnessTest.java` | M-series layering, injection, naming, time | `src/test/java/uk/gov/hmcts/ctam/` |
| `java/TestConventionsFitnessTest.java` | Test naming, no in-memory DB, Testcontainers placement | `src/test/java/uk/gov/hmcts/ctam/` |
| `config/checkstyle-ctam.xml` | M-series size/complexity, R8, S5, S8, T15 | `config/checkstyle/` |
| `config/checkstyle-suppressions.xml` | The only sanctioned exemptions | `config/checkstyle/` |
| `gradle/ctam-quality.gradle` | Spotless, Checkstyle, JaCoCo floor, PIT threshold, task wiring | `gradle/` |
| `openapi/.spectral.yaml` | C-series OpenAPI conventions | repo root |
| `scripts/verify.sh` | The gate (Q3) | `scripts/` |
| `scripts/red.sh` | Red-test evidence (R2/T1) | `scripts/` |
| `scripts/forbidden-patterns.sh` | S/P-series patterns outside Java | `scripts/` |
| `claude/CLAUDE.md.template` | The always-on core in each repo | repo root as `CLAUDE.md` |
| `claude/settings.json.template` | Hook registration | `.claude/settings.json` |
| `claude/hooks/block-git-writes.sh` | R13 / W7 | `.claude/hooks/` |
| `claude/hooks/require-red-test.sh` | R2 / T1 (guardrail) | `.claude/hooks/` |

## Install (first scaffolding story per service)

```bash
# from the service repo root, with _arch/ already added as a submodule at the pinned tag
mkdir -p config/checkstyle gradle scripts .claude/hooks src/test/java/uk/gov/hmcts/ctam

cp _arch/agent-rules/enforcement/java/*.java              src/test/java/uk/gov/hmcts/ctam/
cp _arch/agent-rules/enforcement/config/*.xml             config/checkstyle/
cp _arch/agent-rules/enforcement/gradle/ctam-quality.gradle gradle/
cp _arch/agent-rules/enforcement/openapi/.spectral.yaml    .
cp _arch/agent-rules/enforcement/scripts/*.sh              scripts/
cp _arch/agent-rules/enforcement/claude/hooks/*.sh         .claude/hooks/
cp _arch/agent-rules/enforcement/claude/settings.json.template .claude/settings.json
cp _arch/agent-rules/enforcement/claude/CLAUDE.md.template  CLAUDE.md
chmod +x scripts/*.sh .claude/hooks/*.sh
echo '.ctam/' >> .gitignore     # red-marker state, never committed
```

Then substitute `{{SERVICE_NAME}}` and `{{ARCH_VERSION}}` in `CLAUDE.md`, add the plugin and
dependency lines listed at the top of `gradle/ctam-quality.gradle` to `build.gradle`, and run
`./scripts/verify.sh`.

Copies are **deliberate, one-time, and recorded**: the authored source stays in the bus, and a bus
bump re-copies. Do not diverge a local copy — fix the bus and bump.

## Validation status

**Verified against a real Spring Boot 4.1 / Java 25 build on 2026-08-19.** The pack was installed into a scaffolded service repo, compiled, and run.

| Artefact | Status |
|---|---|
| `ArchitectureFitnessTest.java`, `TestConventionsFitnessTest.java` | **Compiled and run — all 23 rules pass.** Two fixes were needed and are in this pack: `withOptionalLayers(true)` (an absent layer was reported as a violation) and `archunit.properties` below |
| `archunit.properties` | **Required.** ArchUnit's default fails any rule that matched no classes; on a young codebase that fails almost every rule for the wrong reason. See the file for the trade-off accepted |
| `checkstyle-ctam.xml`, `checkstyle-suppressions.xml` | **Run — `checkstyleMain` and `checkstyleTest` pass.** Caught a real defect on first run (a source file with no trailing newline) |
| `ctam-quality.gradle` | **Executed.** Plugins resolve; `check` wires Spotless, Checkstyle, ArchUnit, tests, the JaCoCo floor and the forbidden-pattern scan |
| `forbidden-patterns.sh` | **Executed.** Two false positives found and fixed: it flagged the ArchUnit rules for *naming* the things they forbid, and matched a CVE note in a `build.gradle` comment |
| `pitest` | **Starts cleanly on the JUnit 6 platform.** On a service with no `service`/`domain` classes yet it exits with "No mutations found", which is expected — not a platform problem |
| `.spectral.yaml` | **Not yet executed** against a generated spec. Expect JSONPath / function-option corrections on first run |
| `verify.sh`, `red.sh`, `require-red-test.sh` | `bash -n` syntax-checked; `red.sh` and the hook not yet exercised end-to-end |
| `settings.json.template` | Valid JSON |
| `block-git-writes.sh` | **Verified against a 46-case matrix** in both branch contexts (feature branch, and `main` on an unborn branch) |

### Two things the first build settled

1. **Use `archunit-junit6`, not `archunit-junit5`.** Spring Boot 4.1 ships the **JUnit 6** platform (`jupiter 6.0.3`). `archunit-junit5` drags in `junit-platform-launcher` 1.14.x, and the version mismatch stops **both** engines initialising — so no tests run at all, including the template's own. The annotation imports are identical, so only the dependency line changes:

   ```groovy
   testImplementation 'com.tngtech.archunit:archunit-junit6:1.5.0'
   ```

   Note that `starter-template.md` §A still describes the baseline as JUnit 5; it is wrong on that point.

2. **PIT works on Java 25 / Spring Boot 4.** `pitest 1.25.9` with `pitest-junit5-plugin 1.2.3` starts and runs under the JUnit 6 platform, closing the doubt recorded in **G1.4c**. The mutation gate is safe to keep.

Anything corrected in a service repo is reported **back to the bus** rather than fixed per-repo — that is the drift this model exists to prevent.

## Rule → enforcer

### Core (R)

| Rule | Enforcer |
|---|---|
| R1 scope from the story | Review + `W2` plan step — *no automated enforcer* |
| R2 red before green | `require-red-test.sh` hook + `red.sh` (guardrail); evidence in transcript reviewed |
| R3 one behaviour per test | Review of the AC → test map — *no automated enforcer* |
| R4 cite or ask | Review — *no automated enforcer* |
| R5 unknown means stop | Review of *Open Questions* — *no automated enforcer* |
| R6 no unsanctioned surface | Partial: `forbidden-patterns.sh` (S14 versions), Spectral (undeclared API); otherwise review |
| R7 never assert from memory | Review; build failure catches the worst cases — *no direct enforcer* |
| R8 nothing unfinished ships | Checkstyle `TodoComment`, `ctamNoDisabledTests` |
| R9 limits are the design speaking | Checkstyle + ArchUnit (the limits themselves); suppression additions caught in review |
| R10 contract before controller | Spectral + Pact task in `verify.sh`; ordering is review |
| R11 never log or store what must not leak | `forbidden-patterns.sh` S1/S2 + Checkstyle S5 |
| R12 no success claim without evidence | `verify.sh` (all-or-fail, no silent skips); pasting is review |
| R13 protected-branch writes | `block-git-writes.sh` hook (branch/commit/push allowed; writes to `main`, force-push, tags, `gh` denied) + server-side branch protection |
| R14 no uninvited work | Diff review — *no automated enforcer* |

### Tests (T)

| Rule | Enforcer |
|---|---|
| T1 red first | `require-red-test.sh` + `red.sh` |
| T2 compile error is not red | `red.sh` (detects compile failure, refuses the marker) |
| T3 never weaken a test | Review — *no automated enforcer* |
| T4 bug fixes start with a reproduction | Review |
| T5, T6 naming and AC mapping | `TestConventionsFitnessTest` (class naming); behaviour naming is review |
| T7 Spring context rationing | Review — *no automated enforcer* |
| T8 schema change gets an IT | `forbidden-patterns.sh` P6 (no H2) + review |
| T9 endpoint gets a contract test | Pact step in `verify.sh` |
| T10 mock at the boundary | Review — *no automated enforcer* |
| T11 no logic in tests | Review — *no automated enforcer* |
| T12 determinism | ArchUnit `time_comes_from_an_injected_clock`; sleeps/randomness are review |
| T13 test what you own | Review |
| T14 arrange/act/assert | Review |
| T15 never disable a test | Checkstyle `ctamNoDisabledTests` |
| T16 thresholds | `jacocoTestCoverageVerification` + `pitest` |

### Modularity (M)

| Rule | Enforcer |
|---|---|
| M1–M5, M7 size/complexity/nesting | Checkstyle `MethodLength`, `FileLength`, `ParameterNumber`, `CyclomaticComplexity`, `NestedIfDepth`/`NestedForDepth`/`NestedTryDepth`, `OneTopLevelClass` |
| M6 instance fields ≤ 8 | ArchUnit `classes_have_few_fields` |
| M8 no boolean parameters | **Review only** — Checkstyle has no equivalent module and a regex would be unreliable |
| M9, M10, M13 layering | ArchUnit `layers_flow_one_way`, `controllers_never_touch_repositories` |
| M11 domain purity | ArchUnit `domain_is_pure` |
| M12 entities not at the boundary | ArchUnit `entities_do_not_cross_the_api_boundary` (raw types only; generics are review) |
| M14 no cycles | ArchUnit `no_package_cycles` |
| M15 `@Transactional` placement | ArchUnit `transactional_only_on_services`, `transactional_classes_are_services` |
| M16 no cross-service JPA | Review + the control plane's grants fitness function (`gaps.md` G6.4) |
| M17, M18, M19 injection and state | ArchUnit `no_field_injection`, `collaborator_fields_are_final`, `no_mutable_static_state` |
| M20, M21 time | ArchUnit `time_comes_from_an_injected_clock`, `no_legacy_date_types` |
| M22 no vague names | ArchUnit `no_vague_type_names` + the package/naming rules |
| M23 public surface | Checkstyle `MethodCount`, `ClassFanOutComplexity` |

### API contracts (C)

| Rule | Enforcer |
|---|---|
| C1 contract test first | Review — *no automated enforcer* |
| C2 both sides of a Pact | Pact step in `verify.sh` (fails when no Pact task exists) |
| C3 Spectral clean | `verify.sh` Spectral step |
| C4 `/v1` append-only | **Review only** — needs spec-diff-against-published-version tooling; a future control-plane control |
| C5 consumers pin, producers publish | Review of `build.gradle` dependencies |
| C6 no undeclared surface | Spectral (`ctam-operation-has-summary`, error-response rules) + review |
| C7 RFC 9457 via `@ControllerAdvice` | Spectral `ctam-problem-json-for-errors`; the advice pattern is review |
| C8 new problem types need a source | Review |
| C9 400 vs 422 | Review — *no automated enforcer* |
| C10 error bodies leak nothing | Review + `forbidden-patterns.sh` S1 |
| C11 DTOs are records per direction | Review; M12 covers entity leakage |
| C12 validate at the boundary once | Review |
| C13 clients speak domain language | Review — *no automated enforcer* |
| C14 retry only what is safe | Review |

### Persistence (P)

| Rule | Enforcer |
|---|---|
| P1 Liquibase only | `forbidden-patterns.sh` P1 (Flyway) |
| P2 applied changesets immutable | **Review only** — Liquibase checksum failure catches it downstream, not in this repo's build |
| P3 one change per changeset, with rollback | Review |
| P4 only change tables you own | Review + `data-tables.md`; the cross-service collision check is a control-plane fitness function (G6.4, G6.6) |
| P5 `jo_*`/`mrd_*` read-only | Review — *no automated enforcer* |
| P6 real PostgreSQL | `forbidden-patterns.sh` P6 + `TestConventionsFitnessTest.no_in_memory_database_substitutes` |
| P7 entity/changelog agree | `forbidden-patterns.sh` P7 (`ddl-auto`) + `validate` in ITs |
| P8–P11 entity design, N+1, queries | Review — *no automated enforcer* |
| P12 `@Transactional` placement | ArchUnit (M15) |
| P13 no transaction across a network call | **Review only** — a runtime property no static check sees |
| P14 native concurrency constructs | Review |
| P15, P16 time and audit columns | ArchUnit (M20) + review |

### Security (S)

| Rule | Enforcer |
|---|---|
| S1, S2 forbidden log content | `forbidden-patterns.sh` S1/S2 (text scan — coarse by design) |
| S3, S4 levels and correlation id | Review |
| S5 SLF4J only | Checkstyle `ctamNoConsoleOutput`, `ctamNoPrintStackTrace` + ArchUnit `slf4j_is_the_only_logging_api` |
| S6 Key Vault only | `forbidden-patterns.sh` S6 |
| S7 fake test credentials | Review |
| S8 never weaken TLS | Checkstyle `ctamNoTrustAll` + `forbidden-patterns.sh` S8 |
| S9, S10, S11 auth path and decisions | **Review only** — the highest-consequence review items in the pack |
| S12 mock auth never in production | `forbidden-patterns.sh` S12 (profile files) |
| S13 encode on output, parameterise on input | Review |
| S14 dependency hygiene | `forbidden-patterns.sh` S14 + `cyclonedxBom` |
| S15 never store bank details | Review — *no automated enforcer* |
| S16 no real judicial data in the repo | Review — *no automated enforcer* |

### Workflow and done (W, Q)

| Rule | Enforcer |
|---|---|
| W1–W4, W8–W11 protocol | Review — *no automated enforcer* |
| W5 `_arch/` read-only | Review; a submodule change is visible in the diff |
| W6 stay inside this repo | Review |
| W7 the PR is the human gate | `block-git-writes.sh` + branch protection on `main` |
| W12, W13 handoff and status | Review of the handoff against `sprint-status.yaml` |
| Q1–Q2, Q9–Q13 | Review of the handoff |
| Q3–Q8 | `verify.sh` |

## Where the gaps are

Read the *review only* rows as a to-do list, not as decoration. The four worth strengthening first:

1. **C4 (`/v1` append-only)** — the highest blast radius of anything unenforced, because it breaks
   other repos. Wants a CI step diffing the generated spec against the last published artefact.
2. **S9–S11 (the auth path)** — highest consequence. Wants an ArchUnit rule asserting every
   controller method's authorisation, once the annotation or `AuthDetails` idiom settles.
3. **P2 (changeset immutability)** — cheap to add: a CI step failing on a modified file under
   `db/changelog/` that is not the newest one.
4. **R3 (AC → test coverage)** — could be mechanised by parsing `@DisplayName` AC ids against the
   story packet's AC list.
