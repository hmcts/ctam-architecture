# Published mirror — do not hand-edit

Every `.md` beside this file, plus `../architecture.md`, `../architecture-summary.md` and
`../prd.md`, is a **published mirror**. The canonical source is the control plane:

    ctam-analysis/_bmad-output/planning-artifacts/

To change any of it: change the canonical file there, then re-run
`ctam-analysis/scripts/publish-arch.sh` and publish a new `arch-vN` tag. Editing a file here
creates exactly the drift the delivery operating model exists to prevent, and the next publish
would silently overwrite it.

`agent-rules/` is **not** a mirror — it is authored here, on the bus. See `agent-rules/index.md`.
