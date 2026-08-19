---
id: agent-rules/tdd
title: Tests and the TDD loop (T1–T16)
status: draft
last_updated: 2026-08-19
---

# Tests and the TDD loop

> Expands **R2**, **R3**, **R12**. The point of every rule here is one property: **a test that cannot fail proves nothing.** An AI agent writing tests after the code has already been written produces exactly that kind of test — it describes what the code does rather than what the requirement demands, and it passes for the rest of the codebase's life without ever protecting anything.

## The loop, in full

### T1 — Red first, and prove it (blocking)

For each behaviour, in this order:

1. Pick **one** acceptance criterion, or one slice of one.
2. Write **one** test for it.
3. **Run it.** Capture the output.
4. Confirm it failed **on an assertion**, and that the assertion message describes the missing behaviour.
5. Write the **minimum** production code to pass it. Not the design you expect to need later — the minimum.
6. **Run it.** Capture the output.
7. Refactor within the limits of [`20-modularity.md`](./20-modularity.md). Re-run.

Both captures go in the transcript (formats in [`00-core.md`](./00-core.md) → *Evidence formats*).

### T2 — A compile error is not a red test

If the test does not compile, you have not yet learned anything. Introduce the minimum signature — an interface, an empty method, a record — so the test compiles and then **fails on its assertion**. Only that failure tells you the test is wired to the behaviour.

### T3 — Never weaken a test to reach green

If a test needs to change, the requirement changed. Cite the AC that justifies it and say so explicitly in the handoff. Deleting an assertion, loosening a matcher, widening an expected exception type, or adding `@Disabled` to reach green is prohibited and is the clearest possible signal that the production code is wrong.

### T4 — Bug fixes start with a reproduction

Before touching the fix: a failing test at the **lowest level that reproduces the bug** (unit if the logic is wrong, integration if the mapping or SQL is wrong). Then fix. The regression test stays forever and keeps the bug's ticket or story id in its name or `@DisplayName`.

## Naming and traceability

### T5 — One behaviour per test; the name states the behaviour

The name says what the system does under what condition — not which method is called.

```java
// Good — reads as a requirement
@Test void rejectsSecondBookingForSameJohAndSlot() { … }
@Test void returns422WhenAbsenceEndDatePrecedesStartDate() { … }
@Test void propagatesCorrelationIdToNotificationClient() { … }

// Bad — describes the code, not the requirement
@Test void testCreateBooking() { … }
@Test void createBooking_success() { … }
@Test void shouldWork() { … }
```

### T6 — Every AC maps to at least one named test

Carry the AC id in `@DisplayName` so traceability survives into the test report and the PR:

```java
@Test
@DisplayName("AC-3: a JOH already booked for the slot cannot be booked again")
void rejectsSecondBookingForSameJohAndSlot() { … }
```

The handoff includes the AC → test map (see [`90-definition-of-done.md`](./90-definition-of-done.md)). An AC with no test is an incomplete story, whatever the coverage number says.

## The test taxonomy

Per `_arch/architecture/conventions.md` → *Test conventions*. Choose the **cheapest level that can actually detect the failure**.

| Level | Named | Contains | Must not |
|---|---|---|---|
| **Unit** | `{Class}Test.java` | Business logic, validation, state transitions, error mapping. Plain JUnit 5 + Mockito; **no Spring context**. | Touch a DB, network, clock, or filesystem |
| **Integration** | `{Class}IT.java` | JPA mappings, native queries, Liquibase changelogs, transaction boundaries — Testcontainers PostgreSQL. | Re-test business logic already covered by a unit test |
| **Contract** | `{Consumer}{Provider}PactTest.java` / provider verification | Every endpoint published or consumed | Assert on internal implementation |
| **Architecture** | `ArchitectureFitnessTest.java` | The rules in [`20-modularity.md`](./20-modularity.md) | Be modified to accommodate a violation |

### T7 — Spring context tests are rationed

At most **one** `@SpringBootTest`-class-level context per story, and only when the behaviour genuinely lives in the wiring (a filter chain, a `@ControllerAdvice`, a scheduled trigger). Controller behaviour uses a sliced `@WebMvcTest`; everything else is a plain unit test. A Spring context is roughly two orders of magnitude slower than a unit test, and a suite that takes minutes stops being run.

### T8 — Every schema change gets an integration test

A Liquibase changelog, a new entity, a new query, a new index intended to be used: prove it against real PostgreSQL via Testcontainers. H2 and in-memory substitutes are prohibited — they silently accept SQL that PostgreSQL rejects. See [`40-data-and-liquibase.md`](./40-data-and-liquibase.md).

### T9 — Every endpoint gets a contract test

Both sides. Provider verification for what you publish, consumer test for what you call. An inter-service call added without a Pact test is prohibited (**R6**). See [`30-api-contracts.md`](./30-api-contracts.md).

## Test quality

### T10 — Mock at the boundary, nowhere else

Mock **collaborators the class under test owns a reference to** — other services' clients, repositories, the notification client. Do **not** mock: value objects, records, DTOs, entities, `java.time` types, or anything you could simply construct. Never mock or spy the class under test — a partial mock means the class does too much (see M-series) and the test is asserting on itself.

### T11 — No logic in tests

No `if`, no loops driving assertions, no `try/catch` around the act step, no reflection to reach private state. A test with branches has untested branches. If you need the same behaviour over many inputs, use `@ParameterizedTest` with explicit cases — each case visible in the report.

### T12 — Deterministic or it does not ship

- **No wall clock.** Inject `java.time.Clock`; assert against a fixed instant. Direct `LocalDate.now()` / `Instant.now()` / `LocalDateTime.now()` in production code is prohibited — in a scheduling system it is also a real defect class (month boundaries, DST, the year-end sitting window), not just a testing inconvenience.
- **No `Thread.sleep`.** Use Awaitility or a deterministic trigger.
- **No randomness** without a fixed seed. No `UUID.randomUUID()` in an assertion.
- **No order dependence, no shared mutable static state**, no reliance on another test having run.
- **No network.** An outbound call in a unit test is a defect in the test.

### T13 — Test what you own

Do not test the framework: that Spring injects, that Jackson serialises a plain field, that a Lombok getter returns. Do test **your** behaviour: the custom serialiser, the MapStruct mapper's non-trivial mappings, the validation annotations you rely on for a 422.

### T14 — Arrange / act / assert, visibly

Three blocks, blank-line separated, act is one line. Build test data with a named builder or factory method that states intent (`aBookingFor(joh).onDate(SITTING_DAY)`), not a wall of setters. Test data builders live in `src/test/java/.../support/`.

### T15 — Never disable a test

No `@Disabled`, no `@Ignore`, no commented-out test, no `assumeTrue` used to skip a real case. If a test cannot pass, either the story is not done or there is an open question — both are **R5** stops, not skips.

## The gates

### T16 — Numeric thresholds (build-failing)

Amended into the conventions by SCP 2026-08-19 (architecture v4.2): behaviour coverage remains the goal; these are the floors that stop it being merely aspirational.

| Gate | Threshold | Scope |
|---|---|---|
| **JaCoCo** line coverage | **≥ 85%** | `**/service/**`, `**/domain/**` |
| **JaCoCo** branch coverage | **≥ 75%** | `**/service/**`, `**/domain/**` |
| **PIT** mutation score | **≥ 70%** | `**/service/**`, `**/domain/**` |

**Excluded from all three:** `**/config/**`, `**/dto/**`, `**/*Application.java`, generated sources (MapStruct output, generated API clients), Liquibase changelogs.

Read the thresholds correctly:

- They are a **floor, not a target.** Reaching 85% is not evidence the story is tested; the AC → test map is.
- **The mutation score is the honest number.** Line coverage can be manufactured by executing code without asserting on it; a surviving mutant is a specific, named statement your tests do not actually check. When PIT reports survivors in code your story touched, treat each as a missing test, not as a threshold to be topped up elsewhere.
- **Never chase a number with a vacuous test.** A test that executes a method and asserts nothing — or asserts only `notNull` — is prohibited. It is worse than no test: it consumes the coverage that would otherwise have flagged the gap.
