---
id: runbook-github-setup
title: GitHub manual setup runbook — repo creation, protection, access, agent wiring
status: draft
bus_version: see *Publication* at the end of this file
last_updated: 2026-08-20
---

# Runbook — GitHub manual setup for a CTAM repository

> **Audience:** the platform engineer creating one of the 16 CTAM repositories
> ([`../architecture/repository-strategy.md`](../architecture/repository-strategy.md) → *Repository List*).
> **Method:** the **GitHub web UI**, by hand. The `gh` CLI is not available in this programme — see
> *Why there is no CLI in this runbook* below.

Every step below is a web-UI action or a plain `git` command. Nothing here uses the GitHub CLI, and
no step should be automated without a decision recorded in the control plane.

## What this runbook is, and is not

| | |
|---|---|
| **This runbook** | Creates and configures an **empty, protected, correctly-owned** GitHub repository, then wires it so a cold agent session in it is governed. |
| **Not this runbook** | Scaffolding the code. `ctam-scaffold.sh` does that — see *Part C*. |
| **Not this runbook** | GitHub **org-level** policy, SSO, or GitHub team provisioning. That is the HMCTS platform team, outside CTAM. |
| **Not this runbook** | Any Azure resource. Terraform, per [`../architecture/repository-strategy.md`](../architecture/repository-strategy.md); the shared estate is Epic 0.0. |

**This runbook is the precondition of Stories 0.0.1, 0.1.1, 0.2.1, 0.2.4 and 0.5.1.** Each of those
stories scaffolds or provisions into a repository that must already exist and already be protected.
The dependency is recorded **here, once** — those stories do not restate it.

## Why there is no CLI in this runbook

The `gh` CLI is unavailable to engineers and denied to agent sessions. Two authorities, and they
say different things — read both:

- **D10** (PRD, 2026-05-15; the no-CLI clause is explicitly *unchanged* by the 2026-06-10 amendment):
  *"The `gh` CLI is **not** available in the engineering environment — all GitHub repo creation,
  branch-protection setup, CODEOWNERS configuration, and PR workflow happen via the GitHub web UI
  manually."* That is the reason this runbook exists at all.
- **Agent enforcement** — `_arch/agent-rules/enforcement/claude/hooks/block-git-writes.sh` denies
  `gh` and `hub` outright, at any subcommand, with the recorded reason: *"repository administration,
  PR approval and PR merge are the human gate in this programme … (Also: the HMCTS template's
  `setup-new-repo.sh` makes a repository PUBLIC, which is another reason gh stays closed.)"*

### Do not run the HMCTS template's `setup-new-repo.sh`

**Prohibited.** The HMCTS template ships a `setup-new-repo.sh` helper. **It makes the repository
PUBLIC.** CTAM repositories are **private** (Step 1.3). Create the repository by hand in the web UI
instead, per this runbook. Authority: the `block-git-writes.sh` deny reason quoted above.

## Before you start — what this runbook cannot tell you

Two facts are **not recorded anywhere in the bus or the control plane**, and this runbook will not
guess them. Get an answer before you reach the step that needs it.

> **TBD-1 — HMCTS org-level policy on a new private repo.**
> Which org-level policies apply (SSO enforcement, required org rulesets, default permissions,
> allowed merge methods), whether any of them override the branch-protection settings in Part B,
> and in particular **whether `main` is protected from the moment the repository exists** — if it
> is, the sequencing in Part B changes and the scaffold's first push must go via a branch and a PR.
> **Who can answer:** the HMCTS platform / GitHub org administrators.
>
> *Not unknown:* **repository-creation rights are confirmed.** The engineer running this runbook has
> permission to create repositories in the `hmcts` org through the GitHub web UI (confirmed by the
> CTAM operator, 2026-08-20). Step 1.1 needs no escalation.

> **TBD-2 — differentiated ownership per repository.** *Narrowed 2026-08-20.*
> **The owning team is `@hmcts/ai-enablement`** (confirmed by the CTAM operator, 2026-08-20). Use it
> for team access (Step 2) and as the `CODEOWNERS` owner (Step 3) of every CTAM repository.
> What is still open is whether ownership stays **uniform across all 16 repos**.
> [`../architecture/repo-structure.md`](../architecture/repo-structure.md) anticipates *different*
> owners per repo — *"CTAM Pathfinder team + service-specific reviewers"* for a service,
> *"platform/infra team"* for `ctam-shared-infrastructure`, *"admin-team scoped"* for
> `ctam-admin-ui` — on the reasoning that the shared Azure estate and the admin UI are
> higher-stakes surfaces than a domain service. One team owning everything is a reasonable starting
> position while the programme is small, but it is a **narrower review gate than the architecture
> assumed**, and it should be a deliberate choice rather than a default nobody revisits.
> **Who can answer:** the CTAM delivery lead, when a second team exists to hand a repo to.

Do not substitute a plausible-looking team handle for one you have not been given. A wrong
`CODEOWNERS` owner silently routes review to the wrong people, which is worse than a missing one.

---

## Part A — Create the repository (web UI)

**Step 1.1** Sign in to GitHub and go to the **`hmcts`** organisation → **Repositories** → **New
repository**. The engineer running this runbook holds the permission to do so (see *Before you
start*); if the button is missing, the org grant has changed and that is a platform-team question.

**Step 1.2 — Name it per the CNP convention.**

| Kind of repo | Name |
|---|---|
| A service or UI repo | **`ctam-{service}`** — e.g. `ctam-reference-data`, `ctam-booking`, `ctam-admin-ui` |
| The shared Azure estate | **`ctam-shared-infrastructure`** — the HMCTS Cloud Native Platform `{product}-shared-infrastructure` standard, where the product is `ctam` (AR53 revised) |

The full list of 16 names is in
[`../architecture/repository-strategy.md`](../architecture/repository-strategy.md) → *Repository
List*. Use the name from that table verbatim — the artefact coordinates
(`uk.gov.hmcts.ctam:api-ctam-{service}`) and the package layout
(`uk.gov.hmcts.ctam.{service-name}`) are derived from it
([`../architecture/starter-template.md`](../architecture/starter-template.md) → *Per-service CTAM
Pathfinder Conventions*).

**Step 1.3 — Visibility: PRIVATE.** Select **Private**. Not internal, not public. This is the
setting `setup-new-repo.sh` gets wrong, which is why that script is prohibited.

**Step 1.4 — Initialise with nothing.** No README, no `.gitignore`, no licence. The repository must
be **empty**: `ctam-scaffold.sh` pushes the first commit (Part C), and an auto-created initial
commit puts the scaffold's history behind a merge it does not need.

**Step 1.5** Click **Create repository**. Copy the HTTPS clone URL from the landing page — Part C
needs it.

---

## Part B — Team access, `CODEOWNERS` and branch protection

> **Sequencing matters.** Do **Step 2** (access) now, then **Part C** (the scaffold's first push),
> then **Step 3** and **Step 4** (`CODEOWNERS` and branch protection). Branch protection on `main`
> refuses a direct push, and `CODEOWNERS` is a file that has to exist in the repository — both need
> the scaffold to have landed first. If org policy forces protection at creation time (**TBD-1**),
> the scaffold's first push has to go via a branch and a PR instead; confirm before you start.

**Step 2 — Grant the owning team access.** *Settings → Collaborators and teams → Add teams.*
Add **`@hmcts/ai-enablement`** — the owning team for CTAM repositories — with the access level its
role requires (**Write** for a delivery team; **Admin** only if that team also administers the repo's
settings). Scope access to that team and no wider: polyrepo exists so that each repo has *"its own pipeline, release cadence, CODEOWNERS,
branch protection, and review policy"*
([`../architecture/repository-strategy.md`](../architecture/repository-strategy.md) → *Repository
Strategy: Polyrepo*). A repo readable by everyone and owned by no one has neither.

**Step 3 — `CODEOWNERS` and the PR template** (AR29; and Story 0.0.0 AC-1).

Both are files in the repository, at `.github/CODEOWNERS` and `.github/PULL_REQUEST_TEMPLATE.md`
([`../architecture/repo-structure.md`](../architecture/repo-structure.md) — per-repo trees). If
`ctam-scaffold.sh` already produced them, review them; if not, add them on a branch and open a PR.

`CODEOWNERS` must make the owning team the owner of the repository root, so that every PR requires
that team's review:

```
# Every path in this repository is owned by the CTAM delivery team.
*       @hmcts/ai-enablement
```

**Own the root, not a list of paths.** A `CODEOWNERS` that enumerates directories leaves anything it
forgot unowned, and "unowned" means Step 4's *Require review from Code Owners* has nothing to
require. Add narrower rules **below** the root rule later if a path genuinely needs a different
reviewer — the last matching rule wins.

**Never list individual people.** An individual owner blocks every PR while they are on leave, and
[`../architecture/repo-structure.md`](../architecture/repo-structure.md) records owners as *teams*
throughout. The team must also have write access to the repository (Step 2) or GitHub silently
ignores it as an owner.

**Step 4 — Branch protection on `main`.** *Settings → Branches → Add branch protection rule*,
branch name pattern `main`. Enable:

| Setting | Why |
|---|---|
| **Require a pull request before merging**, with **at least one approving review** — and **Require review from Code Owners** | The PR **is** the human gate. `_arch/agent-rules/60-session-protocol.md` **W7**: *"You own the branch. A human owns `main`."* An agent may branch, commit and push; it may never write to `main`. |
| **Require status checks to pass before merging** | The CI gate — Spotless, Checkstyle, ArchUnit, JaCoCo floor, PIT, Spectral — is only a gate if merging waits for it ([`../architecture/conventions.md`](../architecture/conventions.md) → *Pattern enforcement mechanisms*). |
| **Require linear history** | Per-repo history stays linear and reviewable (`delivery-operating-model.md` → *Parallel execution*: *"serialise within a repo (per-repo history stays linear and reviewable)"*). |
| **Do not allow bypassing the above settings** | A gate with an admin bypass is a convention, not a control. `delivery-operating-model.md` → *Human gates*: enforcement lives in *"per-repo CODEOWNERS and branch protection"*, backed **server-side**. |

Two notes on the status-check box:

- GitHub only offers a check in that list once it has **reported at least once** on this repository.
  On a brand-new repo the list is empty. Enable the rule now, let CI run on the first PR, then come
  back and select the required checks.
- **Which checks** to require is the repo's own CI workflow's business, not this runbook's — the
  workflow lands with the scaffold. Take the names from `.github/workflows/ci.yml` in the repo.

Leave `main` as the PR target: *"PR target: `main`. Trunk-based development"*
([`../architecture/conventions.md`](../architecture/conventions.md) → *Git conventions*).

Branch names for the work that will target it, from the same heading: **`story/{story-id}`** for
dispatched story work — one branch per story, from dispatch to PR — and `bugfix/{ticket-id}-{desc}`,
`chore/{desc}`, `feature/{ticket-id}-{desc}` for everything else. Do not add a protection rule that
contradicts those patterns.

---

## Part C — Hand over to scaffolding (the boundary)

**`ctam-scaffold.sh` does not create or configure a repository.** It scaffolds **locally** — clones
the HMCTS Crime SpringBoot template, renames the package and artefact, overlays the CTAM
conventions — and then pushes to the **remote you created in Part A**, over plain `git`
([`../architecture/starter-template.md`](../architecture/starter-template.md) → *Initialisation
Flow (per service)*). It sets no visibility, no branch protection, no team access, no `CODEOWNERS`.
Those are Parts A and B, by hand, and they are why this runbook exists.

So the handover is exactly this: the repository exists, it is private, the owning team has access,
and it is empty. Run `ctam-scaffold.sh` against the clone URL from Step 1.5 and let it push. Then
return to Step 3 and Step 4.

Everything `ctam-scaffold.sh` is responsible for is inventoried in
[`../architecture/starter-template.md`](../architecture/starter-template.md) §B (*Added by
`ctam-scaffold.sh`*). The script itself is Story 0.1.1.

---

## Part D — Per-repo agent-enforcement wiring

A repository can host a **cold agent session** — one that has never seen this programme — only if
the rules and their enforcers are present in the working tree. Four steps. Do them on a branch and
merge by PR, like any other change.

The target shape is `_arch/agent-rules/index.md` → *How these rules reach a service repo*:

```
ctam-{service}/
├── CLAUDE.md          # generated from _arch/agent-rules/enforcement/claude/CLAUDE.md.template
├── .claude/
│   ├── settings.json  # copied from settings.json.template
│   └── hooks/         # copied from _arch/agent-rules/enforcement/claude/hooks/
├── _arch/             # submodule → ctam-architecture @ arch-vN
└── docs/stories/<id>.md
```

**Step 5 — Pin the context bus as a submodule at `_arch`, at an exact tag.**

```bash
git submodule add https://github.com/hmcts/ctam-architecture.git _arch
git -C _arch fetch --tags
git -C _arch checkout arch-vN          # the exact tag — never a branch, never HEAD
git add .gitmodules _arch
git commit -m "chore: pin context bus at arch-vN"
```

Substitute the real tag for `arch-vN`. Two things to understand about what you just committed:

- What git records is the **commit the tag points at**, as a gitlink. The tag is how humans name the
  pin; the SHA is the pin. That is what makes it exact.
- **The pin moves only by an explicit, committed bump.** `delivery-operating-model.md` → *The
  bus-pinning rule*: *"A service repo re-syncs to a newer `ctam-architecture` version only by an
  explicit, committed submodule bump. The bus never mutates a downstream repo silently."* A
  convention change is therefore one PR on the bus **plus one deliberate bump PR per repo that
  adopts it**. Repos may sit on different bus versions intentionally. Never `git submodule update
  --remote` on a whim, and never point `_arch` at a branch — both re-introduce exactly the silent
  drift the model exists to prevent.

**Step 6 — Generate `CLAUDE.md` from the template.**

Copy `_arch/agent-rules/enforcement/claude/CLAUDE.md.template` to `CLAUDE.md` in the repository
root and substitute **two** placeholders — and nothing else:

| Placeholder | Value |
|---|---|
| `{{SERVICE_NAME}}` | the service segment of the repo name — e.g. `reference-data` for `ctam-reference-data` |
| `{{ARCH_VERSION}}` | the exact tag pinned in Step 5 — e.g. `arch-v1.1` |

**Change nothing else.** The template says so itself: *"this file is generated, and local edits are
lost on the next bus bump. Rule changes go through the control plane."* If the generated file is
wrong for this repo, that is a change to the template on the bus, not a local edit.

**Step 7 — Install the hooks.**

```bash
mkdir -p .claude
cp _arch/agent-rules/enforcement/claude/settings.json.template .claude/settings.json
cp -R _arch/agent-rules/enforcement/claude/hooks .claude/hooks
chmod +x .claude/hooks/*.sh
```

`settings.json` registers two `PreToolUse` hooks and is copied **as-is**:
`block-git-writes.sh` on the `Bash` matcher (enforces **R13** — protected branch, force-push, tags,
`gh`/`hub`, discarding work) and `require-red-test.sh` on `Edit|Write|MultiEdit` (enforces
**R2**/**T1**). The `chmod` is not optional: a hook that is not executable does not run, and a hook
that does not run fails **open** — the session is unguarded and nothing says so.

**Step 8 — Verify the wiring actually took.** Do not assume; prove it.

In the new repository, start a session and, with **HEAD on `main`**, have it attempt a commit:

```bash
git rev-parse --abbrev-ref HEAD        # must print: main
git commit --allow-empty -m "wiring check"
```

**Expected result: the commit is DENIED**, by the hook, before git runs — with a reason naming
`main` as a protected branch and pointing at the pull-request gate. If the commit **succeeds**, the
wiring did not take. Check, in this order: the hooks are executable (Step 7's `chmod`);
`.claude/settings.json` exists and registers `$CLAUDE_PROJECT_DIR/.claude/hooks/block-git-writes.sh`;
`jq` is on `PATH` (the hook parses its input with it). Do not proceed until the denial is real —
this check is the only thing standing between a cold session and a direct write to `main`.

Then move onto a branch and confirm the same commit is **allowed** there. The gate is "not `main`",
not "no commits": `delivery-operating-model.md` → *Human gates* — an agent *may* branch, commit and
push; only `main` and the PR are the human's.

---

## Acceptance check — every clause, and where it lives

| Requirement (Story 0.0.0) | Section |
|---|---|
| Created via the web UI, HMCTS org, **private**, CNP naming | Part A, Steps 1.1–1.5 |
| `setup-new-repo.sh` prohibited, because it makes the repo PUBLIC | *Do not run the HMCTS template's `setup-new-repo.sh`* |
| Branch protection on `main`: PR review, status checks, linear history | Part B, Step 4 |
| `CODEOWNERS` + team access scoped to the owning team (AR29) | Part B, Steps 2–3 |
| No step invokes the GitHub CLI | whole file; *Why there is no CLI in this runbook* |
| `ctam-scaffold.sh` scaffolds locally, pushes to a pre-created remote, never creates or configures a repo | Part C |
| Named as the precondition of 0.0.1, 0.1.1, 0.2.1, 0.2.4, 0.5.1 | *What this runbook is, and is not* |
| Submodule pin at `_arch`, exact `arch-vN` tag, moves only by an explicit recorded bump | Part D, Step 5 |
| `CLAUDE.md` generated from the template, two substitutions only | Part D, Step 6 |
| `.claude/settings.json` + `hooks/` copied, hooks made executable | Part D, Step 7 |
| Verification: a session is denied a commit while HEAD is on `main` | Part D, Step 8 |

## Open questions

Answer these before the step that depends on them; they are not optional detail.

- **TBD-1** — HMCTS org-level settings and repository-creation rights → HMCTS platform / GitHub org administrators.
- **TBD-2** — *narrowed.* The owning team is `@hmcts/ai-enablement`; what is open is whether ownership stays uniform across all 16 repos, where `repo-structure.md` anticipated a separate platform/infra and admin owner → CTAM delivery lead.

## Publication

**Published under: `arch-v1.2` — pending.** This runbook lands in the bus release that follows
`arch-v1.1`. Creating the tag is a human release action: *"an `arch-vN` tag is a release action that
downstream repos pin as a submodule"* (`block-git-writes.sh`; `delivery-operating-model.md` → *The
bus-pinning rule*), and it is denied to agent sessions. **When the tag is cut, replace `pending`
above with the tag that was actually published** — downstream repos pin this bus by tag, so a
runbook that does not name its own version cannot be cited precisely.
