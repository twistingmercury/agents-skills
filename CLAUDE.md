# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A catalog of specialist agent definitions, rules, and portable skills for Claude Code. There is no compiled artifact. The "product" is Markdown prompt files plus the Bash installer that copies them into `~/.claude`. The retired Codex integration lives under `_archive/codex/`.

## Commands

```bash
make help              # list targets
make test              # shared-skill test suites (needs Python 3.11+ and bats)
make install           # install agents, rules, skills into ~/.claude

# Individual suites
(cd skills/rlm && python3 -m unittest discover -s tests -v)
(cd skills/rlm && python3 -m unittest tests.test_rlm_repl.<Class>.<test_method>)

# Lint
shellcheck install/*.sh                     # uses .shellcheckrc (bash, severity=warning)
markdownlint '**/*.md'                             # uses .markdownlint.json
markdownlint --ignore-path /dev/null agents/*/*.md   # .markdownlintignore skips agents/
```

## Layout and how the pieces connect

- `agents/<group>/*.md`: Claude agents. YAML frontmatter (`name` with spaces like `go software engineer`, `description`, `model`, `memory`, `tools` allowlist) plus a prompt body. Filenames use hyphens.
- `skills/<skill>/`: one skill tree installed **unchanged**. `SKILL.md` is the entrypoint. The optional `agents/openai.yaml` is leftover Codex UI metadata; harmless, not read by Claude Code.
- `claude/rules/`: Claude Code rules, installed to `~/.claude/rules/` with their subject folders intact. Files without `paths:` frontmatter load every session: `agent-delegation.md`, `code-shape.md`, and `library-docs.md` are the global coordination rules, and `index.md` points at the language rules. The language rules (`shell/`, `go/`, `python/`, `docker.md`) have `paths:` and load when a matching file is read.
- `lib/print.sh`: `print::info/error/success/warning` helpers sourced by the installer.
- `_archive/`: retired resources, including the whole Codex integration (`_archive/codex/`). Not installed.

### Keeping things in sync

Adding, renaming, or removing a role means changing `agents/`, the role table in `README.md`, and the delegation table in `rules/agent-delegation.md` (if it's routed there). A new or removed skill needs a README skill-table update.

Language standards live once, in `rules/`. The Go, Python, shell, BATS, and devops agents only point at their rule file, so a change to a standard is a change to the rule, not the agent.

### Installers

`install/install.sh` runs three phases in order: `01_install_agents.sh`, `02_install_rules.sh`, then `03_install_skills.sh`. Key behaviors:

- They copy files instead of symlinking. Agent group subdirectories get flattened into one destination dir. Each skill dir is replaced wholesale (`rm -rf` + `cp -R`), and so is each top-level file or folder of `rules/`. Broken symlinks from older installs get swept out.
- There's no pruning: renamed or removed agents/skills leave stale copies behind at the destination.
- Phase 2 copies `rules/` into `~/.claude/rules/`, which also holds files this repo doesn't own. It replaces only the entries it ships and never touches `~/.claude/CLAUDE.md`.
- You can point any phase at a scratch location with env vars (`AGENT_SOURCE`, `AGENTS_DIR`, `SKILL_SOURCE`, `SKILLS_DIR`, `RULE_SOURCE`, `RULES_DIR`, `PROJ_ROOT`) so testing doesn't touch your real config. `.local/` is gitignored and works well for this.

### Skills with executable code

Most skills are prompt-only. `rlm` ships `scripts/rlm_repl.py`, a persistent-REPL helper tested by `tests/test_rlm_repl.py` (stdlib `unittest`).
`python-uv-starter` ships `scripts/scaffold.sh`, which renders `assets/project/*.tmpl` into the current directory, tested by `tests/scaffold.bats`.

## Conventions

- Semantic Versioning. Record changes in `CHANGELOG.md` (Keep a Changelog format) and keep the version in the `README.md` header in sync.
- Default branch is `develop`.
