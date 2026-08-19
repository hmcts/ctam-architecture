---
id: agent-rules/modularity
title: Modularity, size limits and layering (M1–M23)
status: draft
last_updated: 2026-08-19
---

# Modularity, size limits and layering

> Expands **R9**. Every number here is enforced by Checkstyle or ArchUnit and fails the build. They exist because there is **no shared library** in this programme (`project-context.md` → *Delivery & repo discipline*): a bad abstraction cannot be fixed centrally, so the defence is that every unit stays small enough to be read, understood, and replaced on its own.
>
> **When a limit blocks you, the design is wrong — not the limit.** Do not raise a threshold, do not add a `@SuppressWarnings`, do not add a Checkstyle suppression. Split the type, extract the collaborator, or ask (**R5**).

## Size and complexity limits

Enforced by Checkstyle ([`enforcement/config/checkstyle-ctam.xml`](./enforcement/config/checkstyle-ctam.xml)):

| M | Limit | Value | Rationale |
|---|---|---|---|
| **M1** | Method length | **≤ 30 lines** | A method you cannot see at once, you cannot reason about |
| **M2** | File length (one public type per file, so ≈ class length) | **≤ 300 lines** | Past this, the class has more than one reason to change |
| **M3** | Parameters per method **and per constructor** | **≤ 4** | 5+ constructor parameters means 5+ collaborators, which means more than one responsibility |
| **M4** | Cyclomatic complexity | **≤ 8** | Each branch is a test case; 9+ means the tests will not be exhaustive |
| **M5** | Nesting: `if` depth ≤ 3, loop depth ≤ 2, `try` depth ≤ 1 | | Deep nesting hides the happy path; use guard clauses and early return |
| **M6** | Instance fields per class | **≤ 8** | Enforced by ArchUnit (Checkstyle has no equivalent module) |
| **M7** | One public top-level type per file | **1** | Navigability; also makes M2 a real class-size limit |
| **M8** | Boolean-parameter methods | **prohibited** | `book(joh, slot, true)` is unreadable at the call site — use two methods or a named enum |
| **M23** | Public methods per class **≤ 10**, total methods ≤ 20, distinct collaborating types ≤ 20 | | A long public surface is a package pretending to be a class |

**Documented exemptions** (in [`enforcement/config/checkstyle-suppressions.xml`](./enforcement/config/checkstyle-suppressions.xml)):

- `*Test.java` / `*IT.java` — exempt from **M1**, **M2** and the magic-number check. Test size is governed by T5 (one behaviour per test) and reviewed, not counted: a data-heavy parameterised test is legitimately long.
- `error/**` — exempt from the "no catching `Exception`" check. The `@ControllerAdvice` catch-all is required by `conventions.md`.
- Generated sources (MapStruct output, generated API clients) — excluded from all analysis. Never hand-edit generated code.

## Layering

The package layout is fixed by `_arch/architecture/conventions.md` → *Structure Patterns*: `controller` · `service` · `repository` · `domain` · `dto` · `client` · `config` · `error` · `exception`. These rules govern how those packages may depend on each other, and are enforced by [`enforcement/java/ArchitectureFitnessTest.java`](./enforcement/java/ArchitectureFitnessTest.java).

```
controller ──▶ service ──▶ repository ──▶ domain
    │            │  └────▶ client ──▶ dto
    └──▶ dto     └────────────────────▶ domain
                          (nothing depends on controller)
```

| M | Rule |
|---|---|
| **M9** | Dependencies flow one way only: `controller` → `service` → (`repository` \| `client`). Nothing depends on `controller`. |
| **M10** | **`controller` must never touch `repository`.** A controller with a repository has business logic hiding in it. |
| **M11** | **`domain` is pure.** It may depend on `jakarta.persistence`, `java.*`, and other `domain` types — never on `controller`, `dto`, `client`, `service`, `config`, or `error`. |
| **M12** | **Entities never cross the API boundary.** No controller method returns, or accepts, a `@Entity` type. Map to a `dto` record. |
| **M13** | `repository` and `client` are reachable **only from `service`**. |
| **M14** | No package cycles anywhere in `uk.gov.hmcts.ctam.{service}`. |
| **M15** | `@Transactional` appears on `service` methods only — never on a controller, never on a repository interface method. |
| **M16** | Cross-service data access is an API call through `client`, never a JPA read of another service's tables. The **one** documented exception is Reference Data, read directly via JPA (`project-context.md`); there is no `ReferenceDataClient`. |

## Construction and state

| M | Rule |
|---|---|
| **M17** | **Constructor injection only.** No `@Autowired`, `@Inject`, `@Value`, or `@Resource` on a field or setter. Prefer Lombok `@RequiredArgsConstructor` with `private final` fields. Field injection hides M3 breaches and makes the class untestable without a container. |
| **M18** | All injected fields are `final`. |
| **M19** | **No mutable static state.** `static` fields must be `final` (loggers and constants only). |
| **M20** | **No `LocalDate.now()`, `LocalDateTime.now()`, `Instant.now()`, `ZonedDateTime.now()`, `new Date()`, `System.currentTimeMillis()` in production code.** Inject `java.time.Clock` and read time from it. In a scheduling and availability system this is a correctness rule first and a testability rule second. |
| **M21** | **No `java.util.Date`, `Calendar`, `SimpleDateFormat`, or `Timestamp`** in new code — `java.time` only, stored UTC (`conventions.md` → *Format Patterns*). |
| **M22** | **No vague type names**: `*Util`, `*Utils`, `*Helper`, `*Manager`, `*Processor`, `*Handler`, `*Data`, `*Info`, `*Service` outside the `service` package. A name that does not say what the type does becomes the place where unrelated code accumulates. Name it after the behaviour: `SittingDayCalculator`, `AbsenceOverlapRule`, `PaymentBatchWindow`. |

## When you hit a limit

The limit is a prompt to look for the missing concept. In order of preference:

1. **Extract the concept.** A 40-line method usually contains a named domain rule (`AbsenceOverlapRule`, `BookingEligibility`) that wants to be its own small class with its own unit test.
2. **Introduce a parameter object.** A 5th parameter is usually two parameters that belong together — a `DateRange`, a `BookingRequest` record.
3. **Split the class by reason-to-change.** A 350-line service is typically one orchestration path plus two independent rules.
4. **Push branching into polymorphism** where the branch is on a stable domain type — but only if the types genuinely exist. Do not introduce a strategy interface for two `if`s.
5. **Ask (R5)** if none of the above works without a design decision that was not in the story.

What is **never** an answer: raising a threshold, a suppression annotation, moving code to a package that is exempt, or splitting a method into `doThingPart1` / `doThingPart2`.

## Anti-patterns

- ❌ A `service` class with 12 public methods — that is a package pretending to be a class.
- ❌ A "god" DTO reused for request, response, and internal state. Requests and responses are separate records.
- ❌ Business logic in a `@ControllerAdvice`, an entity setter, a Liquibase changelog, or a mapper.
- ❌ Interfaces with a single implementation created "for testability". Constructor injection already gives you that; an interface earns its place when there is a second implementation or a genuine boundary (`client`).
- ❌ Introducing a shared utility class to be reused across repos. There is no shared library. Duplicating a small, well-tested rule in two repos is the accepted cost of the polyrepo (`project-context.md`).
- ❌ `Optional` as a field type or parameter type — return type only.
- ❌ Catching an exception to log and rethrow it unchanged. Handle it or let it reach the `@ControllerAdvice`.
