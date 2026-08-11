# Confluence-ready exports

These files are derived from [`../ctam-integration-design.md`](../ctam-integration-design.md) and are formatted for direct copy-paste into the Confluence editor.

## Files

| File | Use |
|---|---|
| `ctam-integration-design.html` | Confluence page **CTAM — Integration Design Document (High Level)**. Embeds the system context diagram inline (base64) so the HTML is self-contained. |
| `ctam-integration-design.confluence.md` | Intermediate markdown used to produce the HTML. References `../../../architecture/tobe/diagrams/*.png` for images. Edit and re-run pandoc to refresh. |
| `.pandoc-confluence.css` | Stylesheet used by pandoc for in-browser preview before paste. |

The PNG sources live in [`architecture/tobe/diagrams/`](../../../architecture/tobe/diagrams/) — not duplicated here. The HTML embeds them inline so paste-to-Confluence remains a single step.

## Copy into Confluence

1. **Open** `ctam-integration-design.html` in a browser (Chrome / Edge / Firefox / Safari all work — just double-click the file).
2. **Select all** the rendered content (`Cmd + A`).
3. **Copy** (`Cmd + C`).
4. In the Confluence page editor, place the cursor where you want the content and **paste** (`Cmd + V`).
5. Confluence preserves headings, tables (with header rows), bulleted/numbered lists, bold/italic, links and inline code.

The system context diagram embedded in the HTML comes across as an inline image and Confluence auto-uploads it as a page attachment on paste.

## If a paste comes out wrong

- **Tables look squashed** — click into the table, then use the Confluence table controls to set column widths. The HTML carries column-width hints but Confluence sometimes overrides them.
- **Image dropped** — drag `systemContext.png` from [`../../../architecture/tobe/diagrams/`](../../../architecture/tobe/diagrams/) onto the Confluence page after pasting the rest.
- **Code blocks plain** — wrap them in a Confluence "Code Block" macro (`/code`) and pick the language.

## Re-generating after edits

`ctam-integration-design.confluence.md` mirrors [`../ctam-integration-design.md`](../ctam-integration-design.md) — they only differ in the relative links and the diagram embed. If you edit the upstream doc, propagate the change into the `.confluence.md` file, then re-run pandoc.

If the `.c4` model changed, re-export the PNGs first (see the root [README](../../../README.md#previewing-the-architecture-diagrams-likec4)):

```bash
# 1) Re-export the LikeC4 PNGs (only needed if the .c4 model changed)
likec4 export png architecture --output architecture/tobe/diagrams --flatten

# 2) Re-render the Confluence HTML (embeds the diagram as base64)
cd docs/integrations/confluence
pandoc ctam-integration-design.confluence.md -o ctam-integration-design.html --standalone --embed-resources --css=.pandoc-confluence.css
```
