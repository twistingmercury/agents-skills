# Archive

Nothing in this directory is maintained. It is kept for historical reference
only: the installer skips it, the docs do not describe it, and nothing here is
tested or updated. Do not install from it or point new work at it.

- `codex/`: the Codex integration (agents, global rules, installer). Retired
  2026-09-30 when Codex was removed from the machine.
- `ralph_loop_docs_writer/`: the `ralph-loop-docs-writer` skill, moved to the
  gralph project in 1.3.3 (2026-09-14).
- `agents/`: four Claude agents (BATS test engineer, code reviewer, Go
  software architect, solutions architect) retired in 2.0.0 because
  superpowers owns their steps (`test-driven-development`,
  `requesting-code-review`, `writing-plans`, `brainstorming`).
- `skills/`: the `shell-script` skill, retired in 2.0.0 because the shell
  script engineer owns its scripts and BATS tests, and the
  `capture-requirements` skill, retired after 2.0.0 because superpowers
  `brainstorming` covers its elicitation and handoff.
