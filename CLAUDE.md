# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

See the [README](README.md) for an overview and installation guide. The retired Codex integration lives under `_archive/codex/`.

## Commands

See [README § Development Considerations](README.md#development-considerations) for
`make help`, `make install`, `make test`, and the RLM unit test suite.

To run a single RLM test:

```bash
(cd skills/rlm && python3 -m unittest tests.test_rlm_repl.<Class>.<test_method>)
```

To lint (contributors):

```bash
shellcheck install/*.sh                     # uses .shellcheckrc (bash, severity=warning)
markdownlint '**/*.md'                             # uses .markdownlint.json
markdownlint --ignore-path /dev/null agents/*/*.md   # .markdownlintignore skips agents/
```

## Layout and how the pieces connect

- `agents/<group>/*.md`: Claude agents with YAML frontmatter (`name` with spaces like `go software engineer`, hyphenated filenames, `tools` allowlist) plus a prompt body. See `agents/ABOUT-THE-AGENTS.md` for the specialist roles and the superpowers flow. Retired agent files remain on disk but are not registered anywhere.
- `skills/<skill>/`: Portable skill trees installed unchanged. `SKILL.md` is the entrypoint. The optional `agents/openai.yaml` is leftover Codex UI metadata; harmless, not read by Claude Code.
- `rules/`: Claude Code rules installed to `~/.claude/rules/` with subject folders intact. See `rules/index.md` for the path-scoped language rules and their file triggers. Files without `paths:` frontmatter like `agent-delegation.md`, `code-shape.md`, and `library-docs.md` load every session.
- `scripts/`: Optional toolchain installers (Go, Python, Node tools) with BATS tests in `scripts/tests/`, run by `make test`; not part of `make install`.
- `lib/print.sh`: `print::info/error/success/warning` helpers sourced by the installer.
- `_archive/`: Retired resources (Codex integration, agents, skills) not installed.

### Keeping things in sync

Adding, renaming, or removing a role means changing `agents/`, the role table in `README.md`, the agent table in `agents/ABOUT-THE-AGENTS.md`, and the delegation table in `rules/agent-delegation.md` (if it's routed there). A new or removed skill needs a README skill-table update. A retired agent or skill leaves a stale copy at `~/.claude` that you must delete by hand; see [README § Key Considerations](README.md#key-considerations).

Language standards live once, in `rules/`. The Go, Python, React, shell, and devops agents only point at their rule files (the Go engineer at `rules/go/go.md` and `rules/go/architecture.md`, the React engineer at `rules/react/react.md`, the shell engineer at `rules/shell/shell.md` and `rules/shell/bats.md`), so a change to a standard is a change to the rule, not the agent.

### Installers

See [README § How it works](README.md#how-it-works) for the three-phase installer order. Key behaviors:

- Files are copied, not symlinked: agent group subdirectories get flattened into one destination dir, each skill dir is replaced wholesale (`rm -rf` + `cp -R`), and so is each top-level entry of `rules/`. Broken symlinks from older installs are swept out.
- Phase 2 copies `rules/` into `~/.claude/rules/`, which also holds files this repo doesn't own. It replaces only the entries it ships and never touches `~/.claude/CLAUDE.md`.
- You can point any phase at a scratch location with env vars (`AGENT_SOURCE`, `AGENTS_DIR`, `SKILL_SOURCE`, `SKILLS_DIR`, `RULE_SOURCE`, `RULES_DIR`, `PROJ_ROOT`) so testing doesn't touch your real config. `.local/` is gitignored and works well for this.

### Skills with executable code

Most skills are prompt-only. `rlm` has `scripts/rlm_repl.py` and `tests/test_rlm_repl.py` (stdlib `unittest`); `python-uv-starter` has `scripts/scaffold.sh` and `tests/scaffold.bats`.

## Conventions

- Semantic Versioning: keep the version in the `README.md` header in sync with tags recorded in `CHANGELOG.md` (Keep a Changelog format).
- Default branch is `develop`.
