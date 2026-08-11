# Confluence-ready exports

These files are derived from the markdown sources in the parent folder and are formatted for direct copy-paste into the Confluence editor.

## Files

| File | Use |
|---|---|
| `jo-er-diagram.html` | Confluence page **JO (eLinks) Integration — CTAM ER Diagram**. Embeds both ER diagram PNGs inline (base64) so the HTML is self-contained. |
| `jo-schema-mapping.html` | Confluence page **JO (eLinks) Integration — CTAM Schema & Source Mapping**. Tables for every column. |
| `*.confluence.md` | Intermediate markdown used to produce the HTML. Reference `../diagrams/*.png` for images. Edit and re-run pandoc to refresh. |
| `.pandoc-confluence.css` | Stylesheet used by pandoc for in-browser preview before paste. |

PNG sources live in [`../diagrams/`](../diagrams/) — not duplicated here. The HTML embeds them inline so paste-to-Confluence remains a single step.

## Copy into Confluence

For each `.html` file:

1. **Open** the file in a browser (Chrome / Edge / Firefox / Safari all work — just double-click the file).
2. **Select all** the rendered content (`Cmd + A`).
3. **Copy** (`Cmd + C`).
4. In the Confluence page editor, place the cursor where you want the content and **paste** (`Cmd + V`).
5. Confluence preserves headings, tables (with header rows), bulleted/numbered lists, bold/italic, links and inline code.

The PNGs embedded in `jo-er-diagram.html` come across as inline images and Confluence auto-uploads them as page attachments on paste.

## If a paste comes out wrong

- **Tables look squashed** — click into the table, then use the Confluence table controls to set column widths. The HTML carries column-width hints but Confluence sometimes overrides them.
- **Images dropped** — drag the corresponding `.png` from `../diagrams/` onto the Confluence page after pasting the rest.
- **Code blocks plain** — wrap them in a Confluence "Code Block" macro (`/code`) and pick the language.

## Re-generating after edits

PNGs are produced by D2 from sources in [`../diagrams/`](../diagrams/) (D2 with the ELK layout engine was adopted to get field-level connection points and orthogonal, non-crossing lines on the ER diagrams). HTML is produced by pandoc from the `*.confluence.md` files in this folder.

From the repo root:

```bash
# 1) Re-render the PNGs (only needed if the .d2 sources changed)
scripts/render-jo-er-diagrams.sh

# 2) Re-render the Confluence HTML (embeds PNGs as base64)
cd docs/integrations/jo/confluence
pandoc jo-er-diagram.confluence.md     -o jo-er-diagram.html     --standalone --embed-resources --css=.pandoc-confluence.css
pandoc jo-schema-mapping.confluence.md -o jo-schema-mapping.html --standalone --embed-resources --css=.pandoc-confluence.css
```

If you edit the upstream markdown in `../jo-er-diagram.md` or `../jo-schema-mapping.md`, propagate the change into the `*.confluence.md` files (they only differ in the cross-doc link and the diagram embed) and re-run the pandoc commands.
