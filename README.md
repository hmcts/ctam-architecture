# CTAM Architecture

Architectural artefacts for the **CTAM (Court and Tribunals Availability Management)** project.

> **Work in Progress** — these artefacts are evolving and not yet ratified. Please consult the author before using any of them for consumption or downstream decisions.

## Delivery

CTAM will be delivered in stages. The initial stage focuses on Tribunals, with requirements considered in the following order:

1. **ET**
2. **SSCS**
3. **IAC**

## What this repository is

This is the CTAM Pathfinder **context bus**. Two kinds of content live here, and the difference matters:

- **`agent-rules/` is authored here.** The binding *how-we-work* contract every Java service repo
  consumes — TDD discipline, modularity limits, uncertainty protocol, definition of done, plus a
  runnable enforcement pack. Change it here.
- **The rest of the prose is a published mirror.** `architecture.md`, `architecture-summary.md`,
  `architecture/*.md` and `prd.md` are copies of the canonical planning artefacts in `ctam-analysis`,
  produced by `ctam-analysis/scripts/publish-arch.sh`. **Never hand-edit them** — see
  [`architecture/PUBLISHED.md`](./architecture/PUBLISHED.md). The `asis/` and `tobe/` subtrees and
  everything under `docs/` and `input-docs/` are authored here as before.

Service repos embed this repository as a submodule at `_arch/`, pinned to an exact `arch-vN` tag, and
adopt a new version only by a deliberate bump. See
[`architecture/delivery-operating-model.md`](./architecture/delivery-operating-model.md).

## Folder structure

```
ctam-architecture/
├── agent-rules/                      THE AGENT DELIVERY CONTRACT — authored here, not a mirror
│   ├── index.md                      how-we-work rules: R/T/M/C/P/S/W/Q series
│   ├── 00-core.md … 90-definition-of-done.md
│   └── enforcement/                  ArchUnit, Checkstyle, Gradle gate, Spectral, hooks, verify.sh
│
├── architecture.md                   published mirror — canonical architecture index
├── architecture-summary.md           published mirror
├── prd.md                            published mirror
├── architecture/                     PROGRAM-LEVEL architecture
│   ├── PUBLISHED.md                  ← read before editing anything mirrored
│   ├── conventions.md · data-tables.md · gaps.md · assumptions.md · changelog.md
│   ├── delivery-operating-model.md · repo-structure.md · repository-strategy.md
│   ├── starter-template.md · user-types.md · FR/NFR coverage        (all mirrors)
│   ├── asis/SSCS/                    As-is artefacts (per jurisdiction)
│   └── tobe/                         To-be architecture
│       ├── ctam-architecture.c4      LikeC4 source model
│       └── diagrams/                 Rendered LikeC4 PNGs
│
├── input-docs/                       Raw inputs from source systems (PDFs, etc.)
│   ├── jo/                           Judicial Office / eLinks source docs
│   └── mrd/                          MRD source docs
│
└── docs/                             DETAILED design docs
    └── integrations/
        ├── jo/                       JO (eLinks) integration
        │   ├── jo-er-diagram.md      ER diagram narrative
        │   ├── jo-schema-mapping.md  Column-level source→CTAM mapping
        │   ├── diagrams/             PlantUML source + rendered PNGs
        │   └── confluence/           Confluence-ready HTML exports
        └── mrd/                      (placeholder for next integration)
```

## Previewing the Architecture Diagrams (LikeC4)

The program-level architecture is modelled in [LikeC4](https://likec4.dev). Rendered exports are committed at `architecture/tobe/diagrams/` (these are embedded in the design docs and Confluence page templates, so keep them in sync with the model). To serve interactively:

```bash
./scripts/serve.sh
```

To re-export PNGs after editing the `.c4` model (requires Playwright Chromium one-time install: `npx playwright install chromium`):

```bash
likec4 export png architecture --output architecture/tobe/diagrams --flatten
```

The `--flatten` flag is important — without it LikeC4 mirrors the source folder structure and writes to `diagrams/tobe/<view>.png` instead.

Requires `likec4` on your PATH (`npm install -g likec4`).

## Integration ER Diagrams (PlantUML)

Integration-level ER diagrams (e.g. `docs/integrations/jo/`) are authored in PlantUML. To re-render after edits (requires `brew install plantuml`):

```bash
plantuml -tpng docs/integrations/jo/diagrams/*.puml
```

See [`docs/integrations/jo/jo-er-diagram.md`](./docs/integrations/jo/jo-er-diagram.md) for the JO integration entry point, and [`docs/integrations/jo/confluence/README.md`](./docs/integrations/jo/confluence/README.md) for the Confluence publishing workflow.
