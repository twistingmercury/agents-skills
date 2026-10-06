---
name: design-docs-writer
description: Creates and updates architecture documents under docs/design/ from standardized templates, using snake_case filenames and frontmatter versioning, always updating in place. Use when writing architecture recommendations, recording decisions (ADRs), or scaffolding docs/design/.
---

# Architecture Documentation Skill

Create and maintain structured architecture documentation in `docs/design/` using standardized templates.

## Inputs

Accept document numbers such as `00 01 02 03 05`, or `all`. If the requested documents are unclear, ask which document numbers to create or update.

Available documents:

| #  | Filename                           | Description                                           |
| -- | ---------------------------------- | ----------------------------------------------------- |
| 00 | `00_overview.md`                   | High-level system overview and document navigation    |
| 01 | `01_requirements.md`               | Problem statement, goals, non-goals, success criteria |
| 02 | `02_architectural_decisions.md`    | ADR log with Context/Decision/Consequences format     |
| 03 | `03_system_architecture.md`        | Component breakdown, data flow, boundaries            |
| 04 | `04_communication_patterns.md`     | API protocols, endpoints, integration patterns        |
| 05 | `05_deployment_architecture.md`    | Deployment topology, infrastructure, scaling          |
| 06 | `06_security_architecture.md`      | Auth model, access control, encryption, audit         |
| 07 | `07_observability_architecture.md` | Monitoring, logging, tracing, alerting                |
| 08 | `08_data_architecture.md`          | Database stack, data models, storage, migrations      |

## Naming and versioning

- Use lowercase snake_case for generated documentation filenames.
- Preserve conventional ecosystem filenames such as `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, and `LICENSE`.
- Name architecture documents `NN_document_name.md`, with no version suffix.
- Record `version`, `date`, and `notes` as YAML frontmatter on the first lines of every document:

  ```yaml
  ---
  version: 1
  date: 2026-10-06
  notes: Initial version.
  ---
  ```

- Start a new document at `version: 1` with `notes: Initial version.`.
- Always update a document in place. Never create a second copy or a successor file.
- On every update, increment `version` by one, set `date` to the ISO date (`YYYY-MM-DD`) of the update, and set `notes` to a brief summary of what changed in that update.
- Git history holds earlier versions; do not preserve them as separate files.

## Step-by-step procedure

### Step 1: Ensure directory exists

Check if `docs/design/` exists. If not, create it with `mkdir -p docs/design/`.

### Step 2: Check existing documents

Find requested documents using the `NN_document_name.md` pattern. Update an existing document in place and bump its frontmatter `version`, `date`, and `notes`. For a new document, create it from the matching template at `version: 1`.

For architectural decisions, append new ADRs to the `02_architectural_decisions.md` rather than replacing earlier ADRs. Determine the next ADR number from the existing ADRs, and bump the frontmatter version.

### Step 3: Read templates

Read the corresponding template(s) from this skill's `templates/` directory (the templates directory is alongside this SKILL.md file). Templates provide section structure and guidance comments explaining what content belongs in each section.

### Step 4: Write documents

Write each document to `docs/design/` using the template structure. Fill in project-specific content from conversation context or the calling agent's analysis.

**Document format rules:**

- Title as H1
- YAML frontmatter with `version`, `date`, and `notes` as the first lines of the file, before the H1
- Navigation links follow the H1 and point to the overview and `../../README.md`
- Table of Contents after navigation
- Mermaid diagrams for visual architecture (use fenced ```mermaid blocks)
- Tables for structured comparisons and decisions
- `**Next:** [Document Name](filename.md)` at the bottom, linking to the next document
- ADR format: Context / Decision / Consequences (positive + negative)
- Cross-references between docs using relative links
- Only create documents you have actual content for — no empty stubs

### Step 5: Update overview navigation

If an overview exists or other documents were added, update the overview's Document Navigation table to list only existing documents.

### Step 6: Return summary

Return a summary to the caller listing:

- Files created (with paths)
- Files updated (with what changed)
- Total document count in `docs/design/`

## When used by agents

Any agent writing architecture documentation can use this skill. When invoked by an agent:

- The agent provides architectural analysis as context
- This skill handles structuring that analysis into the correct document format
- The agent should specify which document numbers to create based on what analysis was performed
- The skill writes the files and returns a summary

## Key principles

- **Convention over configuration** — always writes to `docs/design/`
- **No empty stubs** — only create documents with actual content
- **Update in place** — one file per document; bump the frontmatter `version`, `date`, and `notes` on every change
- **Consistent format** — all docs follow the same navigation, TOC, and linking patterns
- **Living documents** — designed to be updated as architecture evolves
