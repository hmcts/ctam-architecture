---
id: agent-rules/core
title: Core non-negotiables (R1–R14)
status: draft
last_updated: 2026-08-19
note: This file is the source of each service repo's CLAUDE.md. Keep it short enough to stay in context for a whole session.
---

# Core non-negotiables

Fourteen rules. They are always in context, they are not negotiable, and none of them is waived by time pressure, by a "trivial" change, or by a story that appears to ask for it.

If you are an agent reading this at the start of a session: read [`60-session-protocol.md`](./60-session-protocol.md) next, then the story packet, then stop and plan.

## Precedence

When two sources conflict, this is the order — and the last line is the important one:

1. An explicit instruction from the human in this session.
2. These core rules (R1–R14).
3. The story packet's acceptance criteria (`docs/stories/<id>.md`).
4. The detail rules in this pack (`10-` … `90-`).
5. `_arch/architecture/conventions.md` and the rest of the published architecture.

**A conflict between the story and the architecture is never yours to resolve.** Stop, record it under *Open Questions* in the story packet, and say so (R5). Silently picking the more convenient of two contradictory sources is the single most expensive failure mode available to you.

## The rules

| ID | Rule |
|---|---|
| **R1** | **Scope comes from the story.** Read the story packet and this file before your first edit. The story's Gherkin acceptance criteria are the *only* definition of done-ness for scope. Nothing outside them ships in this change. |
| **R2** | **Red before green, with evidence.** No edit to `src/main/**` without a test that was *executed* and *failed on an assertion* first. A compile error is not a red test. Paste the failing output, then the passing output. Detail: [`10-tdd.md`](./10-tdd.md). |
| **R3** | **One behaviour per test.** Every acceptance criterion maps to at least one named test whose name states the behaviour, not the method under test. |
| **R4** | **Cite or ask.** Every non-obvious decision names its authority: a file + heading in `_arch/`, a story AC id, or an `FR`/`NFR`/`D`/`AR` id. If you cannot name one, you are guessing — see R5. |
| **R5** | **Unknown means stop.** Never infer a business rule, a validation threshold, a state transition, or an upstream field meaning. Write the question into the story packet's *Open Questions*, halt that thread, and continue with the parts that do not depend on the answer. |
| **R6** | **No unsanctioned surface area.** No new dependency, table, column, endpoint, environment variable, config key, profile, or public method beyond what the story or a cited convention calls for. Each of those is a long-term maintenance liability someone else inherits. |
| **R7** | **Never assert an API or version from memory.** Read `build.gradle` and the Spring Boot BOM; read the actual class or interface you are calling. Your training data is older than this codebase. |
| **R8** | **Nothing unfinished ships.** No `TODO`, `FIXME`, stub returning `null`, `UnsupportedOperationException` placeholder, commented-out code, or disabled test in a story you call done. If it is not finished, the story is not done. |
| **R9** | **Limits are the design speaking.** Stay inside the size, complexity, and layering limits in [`20-modularity.md`](./20-modularity.md). When a limit blocks you, **change the design — never raise the limit** and never add a suppression. A suppression requires a human's explicit approval, in the diff, with a reason. |
| **R10** | **Contract before controller.** For every endpoint: the contract test comes first, errors are RFC 9457 `application/problem+json`, and the generated OpenAPI spec must pass Spectral. Detail: [`30-api-contracts.md`](./30-api-contracts.md). |
| **R11** | **Never log or store what must not leak.** No PII, personnel or payroll numbers, bank details, case-level identifiers, tokens, or raw request bodies in logs — at any level, including `DEBUG`. Never store bank details at all (NFR14). Detail: [`50-security-and-logging.md`](./50-security-and-logging.md). |
| **R12** | **No success claim without evidence.** Run `./scripts/verify.sh`, read the output, paste it. "Should pass", "tests are green" without output, and "this completes the story" without the gate having run are all prohibited. If the gate fails, say so plainly with the failure. |
| **R13** | **Never write to a protected branch.** Staging, committing and pushing on **this story's `story/<id>` branch** are allowed — dispatch created it, and you do not cut another (**W7**) — the **pull request is the human gate**. Never commit, merge, rebase or push to `main`/`master`; never force-push; never tag; never use `gh`/`hub`; never discard work (`reset --hard`, `clean`, `rm`, `restore`, `checkout -- <path>`). If HEAD is on a protected branch, create a feature branch before committing. |
| **R14** | **No uninvited work.** No opportunistic refactoring, no "while I was in there" fixes, no extra features, no reformatting untouched files. Real problems you notice go into *Open Questions* in the packet, not into this diff. A large diff is not evidence of productivity; it is evidence the review will be shallow. |

## The loop

Every story, every time:

```
1  READ      story packet + this file + the rule file for what you are about to touch
2  PLAN      restate the ACs as a test list; surface unknowns (R5) BEFORE writing anything
3  RED       one AC → one test → run it → paste the assertion failure
4  GREEN     minimum production code to pass → run → paste the pass
5  REFACTOR  inside the limits (20-modularity.md) → re-run
6  repeat 3–5 per behaviour, smallest first
7  VERIFY    ./scripts/verify.sh → paste output (R12)
8  HANDOFF   branch, commit, push; then diff summary, AC→test map, Open Questions
```

Steps 3–5 are per behaviour, not per story. A story finished in one giant green step did not follow this loop.

## Stop conditions

Halt and ask. Do not work around any of these:

- An acceptance criterion is ambiguous, or two ACs conflict.
- The story contradicts `_arch/`, or `_arch/` contradicts itself.
- The work needs something in R6's list that the story does not sanction.
- An upstream field, code value, or business threshold is undocumented.
- A limit in `20-modularity.md` cannot be met without a design you were not asked to make.
- The gate fails for a reason you cannot attribute to your own change.
- The story appears to need a write to a protected branch, a tag, a deployment, a secret, or access you do not have.

Stopping costs one message. Guessing costs a defect that outlives the story, in a codebase where duplication is deliberate and there is no shared library to fix it in one place.

## Read-before-you-touch index

| About to… | Read first |
|---|---|
| Write any test, or any production code at all | [`10-tdd.md`](./10-tdd.md) |
| Add or change a class, package, method, or dependency between them | [`20-modularity.md`](./20-modularity.md) |
| Add or change an endpoint, DTO, status code, or error | [`30-api-contracts.md`](./30-api-contracts.md) |
| Touch an entity, repository, or Liquibase changelog | [`40-data-and-liquibase.md`](./40-data-and-liquibase.md) |
| Log anything, handle a token/secret, or touch auth | [`50-security-and-logging.md`](./50-security-and-logging.md) |
| Start a story, or hand one back | [`60-session-protocol.md`](./60-session-protocol.md) · [`90-definition-of-done.md`](./90-definition-of-done.md) |

## Evidence formats

R2 and R12 require pasted output. These are the accepted shapes — abbreviate the stack trace, never the verdict line.

**Red (R2)** — the assertion must be the failure, and it must name the behaviour:

```
> Task :test FAILED
BookingServiceTest > rejectsSecondBookingForSameJohAndSlot() FAILED
    org.opentest4j.AssertionFailedError: expected DoubleBookingException to be thrown
        at BookingServiceTest.rejectsSecondBookingForSameJohAndSlot(BookingServiceTest.java:58)
1 test completed, 1 failed
```

**Green (R2)**:

```
> Task :test
BookingServiceTest > rejectsSecondBookingForSameJohAndSlot() PASSED
BUILD SUCCESSFUL
```

**Gate (R12)** — the tail of `./scripts/verify.sh`, including the JaCoCo and PIT lines, not just `BUILD SUCCESSFUL`.

Not acceptable: a summary of output you did not run, output from a previous run presented as current, or `BUILD SUCCESSFUL` from a task set that skipped the gate.
