---
# CTAM STORY PACKET TEMPLATE — the canonical shape for docs/stories/<id>.md in a service repo.
#
# It is BMad's story template (from bmad-create-story) with CTAM's polyrepo fields added.
# The reconciliation rule is simple and non-negotiable:
#
#   * EVERY top-level section below is BMad's, at BMad's heading level, with BMad's spelling.
#     bmad-dev-story reads and writes them; renaming or dropping one breaks the dev workflow.
#   * CTAM content is added ONLY as this frontmatter and as SUBSECTIONS of "## Dev Notes".
#     Never as a new top-level section.
#   * There is exactly ONE status: the `Status:` line, using BMad's vocabulary. Do not add a
#     status field here. `sprint-status.yaml` uses the same vocabulary, so a status means the same
#     thing everywhere — two statuses in two vocabularies is what caused this template to exist.
#
# Delete these comments when instantiating. Validate with:
#   ctam-analysis/scripts/validate-story-packet.sh <path-to-packet>
#
story_id: 0.0.0                       # matches the epic's story numbering
epic: epic-0.0-<slug>                 # the authored epic this derives from
repo: ctam-<service>                  # the execution unit this lands in
bus_version: arch-v1.0                # the _arch/ submodule pin this packet was written against
frs: []                               # FRs this story delivers, e.g. [FR6, FR7]
nfrs: []                              # NFRs this story delivers, e.g. [NFR24]
depends_on_stories: []                # intra-graph prerequisites, e.g. [0.0.3]
sprint_status_key: 0-0-0-<kebab-title>  # this story's key in sprint-status.yaml
---

# Story {{epic_num}}.{{story_num}}: {{story_title}}

Status: ready-for-dev

<!-- BMad vocabulary: ready-for-dev | in-progress | review | done — the same words used in
     sprint-status.yaml. There is no second status vocabulary anywhere. -->

## Story

As a {{role}},
I want {{action}},
so that {{benefit}}.

## Acceptance Criteria

<!-- Numbered, one behaviour each, testable. Gherkin is encouraged inside a numbered item —
     the epics author ACs in Gherkin and T6 requires each AC to be traceable into a test
     @DisplayName. Keep the number: "AC-3" in a test name must resolve to item 3 here. -->

1. [from the epic — verbatim where possible]

## Tasks / Subtasks

<!-- bmad-dev-story works through these and ticks them off. Every task cites the AC it serves.
     Order them the way the TDD loop will run: one behaviour at a time (agent-rules T1). -->

- [ ] Task 1 (AC: 1)
  - [ ] Write the failing test for AC-1, run it, capture the assertion failure (R2)
  - [ ] Minimum production code to pass; re-run
- [ ] Task 2 (AC: 2)

## Dev Notes

<!-- Everything CTAM adds lives here as subsections. Nothing CTAM-specific goes above this line. -->

### Context distilled from the bus

<!-- What THIS story needs from _arch @ bus_version — not the whole architecture. Quote the rule
     and cite file + heading so the dev agent never has to guess or browse (R4). -->

### Rules that apply

<!-- The agent-rules files to read before touching each area, per CLAUDE.md's read-before-you-touch
     index. Name the specific rule ids that will bite on this story. -->

### Project Structure Notes

<!-- Expected file layout for this story, per conventions.md Structure Patterns. Anything not
     listed needs a citation or a decision (R6). Note any variance and why. -->

### Out of scope / boundaries

<!-- What a reader might reasonably expect that this story does NOT include, and where it went
     instead (a later phase, another repo, a deferred decision). -->

### Recorded deviations

<!-- Any departure from the epic or from agent-rules, with the id, the rule affected, and WHO
     approved it. A deviation nobody recorded is indistinguishable from a defect.
     Omit the section entirely when there are none — do not write "none". -->

### Definition of done

<!-- _arch/agent-rules/90-definition-of-done.md applies. List only the deltas: which Q-items are
     waived or not applicable for this story, and why. -->

### References

<!-- Cite every technical detail with a source path and section, e.g.
     [Source: _arch/architecture/conventions.md#naming-patterns] -->

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

<!-- Include the red/green evidence required by R2 and the gate output required by R12, or a
     pointer to where they were pasted. -->

### File List

<!-- Every file added, changed or deleted. Grouped by layer. This is what a reviewer reads first. -->
