---
name: rlm
description: Runs a Recursive Language Model-style loop over a large file or document directory using a persistent local REPL: load the context once, then search, chunk, and extract across multiple queries. Use when the user supplies a context too large to paste into chat, or asks to analyze a corpus of PDFs, DOCX, ODT, or text files.
---

# rlm (Recursive Language Model workflow)

Use this skill when:

- The user provides a large context file or document directory.
- You need iterative search/chunk/extract over that context.
- You want to reuse loaded context across multiple queries.

## Inputs

Required:

- `context=<path>`: file path (single-file mode) or directory path (corpus mode)
- `query=<question>`: question/task to run against the loaded context

Optional:

- `chunk_chars=<int>` (default ~200000)
- `overlap_chars=<int>` (default 0)
- `strict=true` (corpus mode only, fail on first parse error)

If arguments are missing, ask for:

1. context path
2. query

Resolve `<skill-dir>` to the directory containing this `SKILL.md` before running bundled scripts. Do not assume the repository working directory contains `scripts/rlm_repl.py`.

## Workflow

1. Initialize state.

   Single-file mode:

   ```bash
   python3 <skill-dir>/scripts/rlm_repl.py init <context_path>
   python3 <skill-dir>/scripts/rlm_repl.py status
   ```

   Corpus mode (recursive, honors `.rlmignore` if present):

   ```bash
   python3 <skill-dir>/scripts/rlm_repl.py init-corpus <context_dir>
   python3 <skill-dir>/scripts/rlm_repl.py status
   ```

   Corpus strict mode:

   ```bash
   python3 <skill-dir>/scripts/rlm_repl.py init-corpus <context_dir> --strict
   ```

2. Check/install optional parsers when needed.

   ```bash
   python3 <skill-dir>/scripts/rlm_repl.py check-deps
   python3 <skill-dir>/scripts/rlm_repl.py install-deps --all --dry-run
   ```

   Install missing dependencies only with user approval.

3. Scout the loaded context.

   ```bash
   python3 <skill-dir>/scripts/rlm_repl.py exec -c "print(peek(0, 3000))"
   python3 <skill-dir>/scripts/rlm_repl.py exec -c "print(peek(len(content)-3000, len(content)))"
   ```

4. Materialize chunks for subagent analysis.

   ```bash
   python3 <skill-dir>/scripts/rlm_repl.py exec <<'PY'
   paths = write_chunks('.rlm/chunks', size=200000, overlap=0)
   print(len(paths))
   print(paths[:5])
   PY
   ```

5. Use the host's available subagent mechanism for chunk analysis when useful, then synthesize results. If subagents are unavailable, analyze chunks sequentially.

## Guardrails

- Do not paste large raw chunks into chat.
- Quote only needed excerpts.
- Keep scratch/state files under `.rlm/`.
- For first iteration, refresh manually when sources change:
  - run `python3 <skill-dir>/scripts/rlm_repl.py reset`
  - then reinvoke the skill with `context=... query=...`

## Notes

- Optional document parsers:
  - PDF: `pypdf`
  - DOCX: `python-docx`
  - ODT: `odfpy`
- Default corpus excludes: `.git/`, `node_modules/`, `bin/`, `_archive/`.
- Corpus-mode design history. Read these only when changing corpus mode, not to run the skill:
  - [Design](references/plans/2026-02-23-rlm-corpus-design.md): goals, architecture, ignore and extraction rules, decision log.
  - [Implementation plan](references/plans/2026-02-23-rlm-corpus-implementation-plan.md): phased work, test plan, definition of done.
