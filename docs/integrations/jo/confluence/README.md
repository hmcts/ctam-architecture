# Confluence-ready exports

These files are derived from the markdown sources in the parent folder and are formatted for direct copy-paste into the Confluence editor.

## Files

| File | Use |
|---|---|
| `jo-er-diagram.html` | Confluence page **JO (eLinks) Integration — RAM ER Diagram**. Embeds both PNG diagrams inline. |
| `jo-schema-mapping.html` | Confluence page **JO (eLinks) Integration — RAM Schema & Source Mapping**. Tables for every column. |
| `jo-er-diagram-full.png` | Full ER diagram (rendered from `../jo-er-diagram-full.mmd`). |
| `jo-er-diagram-core.png` | Transactional-core ER diagram (rendered from `../jo-er-diagram-core.mmd`). |
| `*.confluence.md` | Intermediate markdown used to produce the HTML (kept for re-builds; ignore if you're just publishing). |

## Copy into Confluence

For each `.html` file:

1. **Open** the file in a browser (Chrome / Edge / Firefox / Safari all work — just double-click the file).
2. **Select all** the rendered content (`Cmd + A`).
3. **Copy** (`Cmd + C`).
4. In the Confluence page editor, place the cursor where you want the content and **paste** (`Cmd + V`).
5. Confluence preserves headings, tables (with header rows), bulleted/numbered lists, bold/italic, links and inline code.

The PNG diagrams embedded in `jo-er-diagram.html` come across as inline images and Confluence auto-uploads them as page attachments on paste.

## If a paste comes out wrong

- **Tables look squashed** — click into the table, then use the Confluence table controls to set column widths. The HTML carries column-width hints but Confluence sometimes overrides them.
- **Images dropped** — drag the corresponding `.png` from Finder onto the Confluence page after pasting the rest.
- **Code blocks plain** — wrap them in a Confluence "Code Block" macro (`/code`) and pick the language.

## To re-generate after editing the markdown

From this folder, run pandoc + mmdc:

```bash
# Re-render PNGs (from the parent folder's .mmd sources)
mmdc -i ../jo-er-diagram-full.mmd -o jo-er-diagram-full.png -s 2 -b white
mmdc -i ../jo-er-diagram-core.mmd -o jo-er-diagram-core.png -s 2 -b white

# Re-render HTML
pandoc jo-er-diagram.confluence.md   -o jo-er-diagram.html   --standalone --embed-resources --css=.pandoc-confluence.css
pandoc jo-schema-mapping.confluence.md -o jo-schema-mapping.html --standalone --embed-resources --css=.pandoc-confluence.css
```

If you edit the upstream markdown in the parent folder, propagate the change into the `*.confluence.md` files (they only differ in the cross-doc link and the diagram embed) and re-run the pandoc commands.
