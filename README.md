# CTAM Architecture

Architectural artefacts for the **CTAM (Court and Tribunals Availability Management)** project.

> **Work in Progress** — these artefacts are evolving and not yet ratified. Please consult the author before using any of them for consumption or downstream decisions.

## Delivery

CTAM will be delivered in stages. The initial stage focuses on Tribunals, with requirements considered in the following order:

1. **ET**
2. **SSCS**
3. **IAC**

## Folder structure

```
ram-architecture/
├── input-docs/                       Raw inputs from source systems (PDFs, etc.)
│   ├── jo/                           Judicial Office / eLinks source docs
│   └── mrd/                          MRD source docs
│
├── architecture/                     PROGRAM-LEVEL architecture
│   ├── asis/SSCS/                    As-is artefacts (per jurisdiction)
│   └── tobe/                         To-be architecture
│       ├── ctam-architecture.c4      LikeC4 source model
│       └── diagrams/                 Rendered LikeC4 PNGs
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
