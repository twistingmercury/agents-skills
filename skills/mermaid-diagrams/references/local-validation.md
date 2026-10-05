# Local Validation with mmdc

Render diagrams locally before committing to verify legibility and avoid syntax errors in the
repository.

## Prerequisites

Check if `mmdc` (mermaid-cli) is installed:

```bash
command -v mmdc || command -v ~/.local/bin/mmdc
```

If not found, you can still debug by reading the syntax pitfalls guide in the skill's reference
documentation.

## Extract and render diagrams

Create a temporary directory and render both light and dark themes:

```bash
TEMPDIR=$(mktemp -d)
# Light theme with white background
mmdc -i FILE.md -o "$TEMPDIR/light.png" -t default -b '#ffffff' -q
# Dark theme with GitHub dark background
mmdc -i FILE.md -o "$TEMPDIR/dark.png" -t dark -b '#0d1117' -q
```

The `-i` flag accepts a Markdown file and renders every mermaid block in it. With `-o output.png`,
each block is saved as `output-1.png`, `output-2.png`, etc.

## Check exit codes

- Exit code `0`: Success. Images are written to the output path.
- Non-zero exit code: Syntax error in the diagram.

Example error output for unquoted special characters:

```text
Error: Parse error on line 2:
...chart TD    A[User (authenticated)]
----------------------^
Expecting 'SQE', 'DOUBLECIRCLEEND', 'PE', ...got 'PS'
Parser.parseError (...)
```

Fix the syntax and re-run `mmdc`.

## What to look for in the images

### Light image (`-b '#ffffff'`)

- All text legible against the white background.
- Node colors have sufficient contrast (text color `#1f2328` on palette fills meets >= 8.2:1).
- Edges and labels are readable.

### Dark image (`-b '#0d1117'`)

- All text legible against the GitHub dark background.
- Node stroke `#6e7781` visible against the dark canvas (4.16:1 contrast).
- Edge routing and label placement do not overlap illegibly.

### Structure

- Nodes are in a sensible top-to-bottom or left-to-right order.
- Related nodes are grouped in subgraphs where intended.
- Crossing edges are minimal; if present, assess whether splitting the diagram would help.
- Arrows point in the direction of the flow or relationship.

## Example workflow

1. Write or edit a diagram in a Markdown file.
2. Create a temporary directory: `TEMPDIR=$(mktemp -d)`.
3. Render light theme: `mmdc -i doc.md -o "$TEMPDIR/light.png" -t default -b '#ffffff' -q`.
4. Render dark theme: `mmdc -i doc.md -o "$TEMPDIR/dark.png" -t dark -b '#0d1117' -q`.
5. Read the output PNG files (`light-1.png`, `dark-1.png`, then `-2`, and so on for further blocks)
   to inspect each diagram.
6. If rendering failed, fix the syntax and re-run mmdc.
7. Clean up: `rm -rf "$TEMPDIR"`.

## Tested with

Mermaid CLI 12.0.0. Key options used above:

- `-i` (input): Markdown file path; mmdc extracts and renders every mermaid block.
- `-o` (output): Output file path; mmdc appends `-1`, `-2`, etc. for multiple blocks.
- `-t` (theme): `default` (light) or `dark`.
- `-b` (background): Background color (hex).
- `-q` (quiet): Suppress progress output.

Other options available: `-s` (scale factor), `-c` (config file), `--outputFormat` (svg|png|pdf).

Note: mmdc has no width flag (`-w`). Use `-s` to adjust scale if needed.
