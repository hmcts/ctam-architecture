---
id: agent-rules/definition-of-done
title: Definition of done (Q1–Q13)
status: draft
last_updated: 2026-08-19
---

# Definition of done

> Expands **R12**. Every line is a claim you must be able to evidence with pasted output or a named artefact. "I believe so" is not an answer to any of them.

## The gate

One command runs everything. It lives in the service repo at `scripts/verify.sh` (template: [`enforcement/scripts/verify.sh`](./enforcement/scripts/verify.sh)):

```bash
./scripts/verify.sh
```

| Step | Task | Fails on |
|---|---|---|
| Format | `spotlessCheck` | Formatting drift |
| Structure | `checkstyleMain` `checkstyleTest` | M1–M8 size/complexity limits |
| Architecture | ArchUnit, inside `test` | M9–M22 layering, injection, naming, time |
| Unit + integration | `test` (Testcontainers PostgreSQL) | Any failing or disabled test |
| Coverage | `jacocoTestCoverageVerification` | < 85% line / < 75% branch on `service` + `domain` |
| Mutation | `pitest` | Mutation score < 70% on `service` + `domain` |
| Contracts | `pactTest` / provider verification | Contract breach either side |
| API lint | spec generation + `spectral lint` | OpenAPI convention breach |
| Leftovers | forbidden-pattern scan | `TODO`/`FIXME`, `System.out`, `printStackTrace`, `@Disabled`, `LocalDate.now()`, `trustAll` |
| SBOM | `cyclonedxBom` | Dependency graph that will not resolve |

`pitest` is the slowest step by an order of magnitude. Run the fast steps continuously while working; the full gate is required before handoff, not after every edit.

## The checklist

| Q | Done means | Evidence |
|---|---|---|
| **Q1** | Every acceptance criterion has at least one passing test whose name states the behaviour | The AC → test map, below |
| **Q2** | Every behaviour was driven red-first | Red and green output for each, in the transcript (**R2**) |
| **Q3** | The full gate passes | Pasted tail of `./scripts/verify.sh`, including the JaCoCo and PIT lines (**R12**) |
| **Q4** | No unfinished work anywhere in the diff | The leftovers scan is clean (**R8**) |
| **Q5** | No unsanctioned surface added | Every new dependency, table, column, endpoint, env var, config key cited or approved (**R6**) |
| **Q6** | Every endpoint touched has both sides of a contract test, and the generated spec is Spectral-clean | Pact + Spectral output (**C2**, **C3**) |
| **Q7** | Every schema change runs from an empty database and is proved by an `*IT` | Testcontainers IT output (**P6**) |
| **Q8** | Nothing forbidden is logged or stored | Reviewed the log statements you added against **S1**; scan clean |
| **Q9** | The story packet is current | `status`, decisions with citations, *Open Questions* (**W8**) |
| **Q10** | The diff is minimal and scoped | File list reviewed; no unrelated file, no drive-by reformat, no uninvited refactor (**R14**) |
| **Q11** | Anything **not** done is stated explicitly | The "Not done" section of the handoff — never a silent omission (**W10**) |
| **Q12** | Handoff carries the signal fields the control plane needs | Per **W12** |
| **Q13** | The packet's `Status:` line reads `review`, not `done`; the control plane is untouched | **W13** |

## Handoff format

```markdown
## Story 0.1.4 — <title>            Status: review    bus: arch-v1.0

### What changed
<one paragraph: the behaviour that now exists, and why it is shaped that way>

### AC → test
- AC-1 → JohIngestionServiceTest.mapsPersonnelNumberToJohIdentity
- AC-2 → JohIngestionServiceTest.rejectsRecordWithoutPersonnelNumber
- AC-3 → JohIngestionIT.persistsIngestedPeopleFromEmptySchema

### Files
- src/main/java/.../service/JohIngestionService.java   new — ingestion rule
- src/main/resources/db/changelog/004-ctam-joh-identities.sql   new — table + uq
- src/test/java/.../service/JohIngestionServiceTest.java   new — 6 behaviours

### Gate
<pasted tail of ./scripts/verify.sh — coverage and mutation lines included>

### Not done
<anything deferred, and why — or "nothing">

### Open questions
<each with the AC or file it blocks — or "none">

### Suggested commit
feat: ingest JOH identities from jo_people
```

## Definition of *not* done

Any one of these means the story is not ready, regardless of how green the build looks:

- An AC with no test.
- A test that was never seen red.
- A threshold met by a test that asserts nothing (**T16**).
- A suppression, `@SuppressWarnings`, or raised limit added to pass the gate (**R9**).
- A `TODO` or a stub (**R8**).
- An open question that was resolved by guessing (**R5**).
- A diff containing work nobody asked for (**R14**).
- A claim of success with no pasted output (**R12**).
