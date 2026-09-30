# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A catalog of specialist agent definitions and portable skills, packaged for two clients: Claude Code and Codex. There is no compiled artifact. The "product" is Markdown/TOML prompt files plus the Bash installers that copy them into `~/.claude` and `$CODEX_HOME` (default `~/.codex`).

## Commands

```bash
make help              # list targets
make test              # shared-skill test suites (needs Python 3.11+ and bats)
make install-claude    # (alias: make install) install agents, rules, skills into ~/.claude
make install-codex     # same for $CODEX_HOME
make install-all

# Individual suites
(cd skills/rlm && python3 -m unittest discover -s tests -v)
(cd skills/rlm && python3 -m unittest tests.test_rlm_repl.<Class>.<test_method>)

# Lint
shellcheck claude/install/*.sh codex/install/*.sh   # uses .shellcheckrc (bash, severity=warning)
markdownlint '**/*.md'                             # uses .markdownlint.json
```

## Layout and how the pieces connect

- `claude/agents/<group>/*.md`: Claude agents. YAML frontmatter (`name` with spaces like `go software engineer`, `description`, `model`, `memory`, `tools` allowlist) plus a prompt body. Filenames use hyphens.
- `codex/agents/<group>/*.toml`: the **same roles** as native Codex agents (`name` in snake_case, `description`, `sandbox_mode`, `developer_instructions`). No model settings (they inherit from the session). Filenames match the snake_case `name`.
- `skills/<skill>/`: one skill tree installed **unchanged** to both clients. `SKILL.md` is the entrypoint. The optional `agents/openai.yaml` holds Codex UI metadata.
- `claude/rules/`: Claude Code rules, installed to `~/.claude/rules/` with their subject folders intact. Files without `paths:` frontmatter load every session: `agent-delegation.md`, `code-shape.md`, and `library-docs.md` are the global coordination rules, and `index.md` points at the language rules. The language rules (`shell/`, `go/`, `python/`, `docker.md`) have `paths:` and load when a matching file is read.
- `codex/agents/global-agents.md`: the global coordination/delegation rules for Codex.
- `lib/print.sh`: shared `print::info/error/success/warning` helpers sourced by the installers.
- `_archive/`: retired resources. Not installed.

### Parallel maintenance

Every role exists twice, once per client. Adding, renaming, or removing a role means changing both `claude/agents/` and `codex/agents/`, the role tables in `README.md`, the delegation table in `claude/rules/agent-delegation.md` (if it's routed there), and the registry in `codex/agents/global-agents.md`. A new or removed skill needs a README skill-table update. The Codex prompts aren't a copy of the Claude ones: they open with Codex-specific constraints (sandbox, no commits, handoff to the parent) before the shared role instructions.

### Installers

Each client has `install/install.sh`, which runs three phases in order: agents (`01_install_agents.sh`), global guidance (`02_install_rules.sh` for Claude, `02_install_global_agents.sh` for Codex), then skills (`03_install_skills.sh`). Key behaviors:

- They copy files instead of symlinking. Agent group subdirectories get flattened into one destination dir. Each skill dir is replaced wholesale (`rm -rf` + `cp -R`), and so is each top-level file or folder of `claude/rules/`. Broken symlinks from older installs get swept out.
- There's no pruning: renamed or removed agents/skills leave stale copies behind at the destination.
- Claude phase 2 copies `claude/rules/` into `~/.claude/rules/`, which also holds files this repo doesn't own. It replaces only the entries it ships and never touches `~/.claude/CLAUDE.md`.
- Codex phase 2 writes `$CODEX_HOME/AGENTS.md` but leaves an existing untracked one alone. A non-empty `AGENTS.override.md` shadows it.
- You can point any phase at a scratch location with env vars (`AGENT_SOURCE`, `AGENTS_DIR`, `SKILL_SOURCE`, `SKILLS_DIR`, `RULE_SOURCE`, `RULES_DIR`, `CODEX_HOME`, `PROJ_ROOT`) so testing doesn't touch your real config. `.local/` is gitignored and works well for this.

### Skills with executable code

Most skills are prompt-only. `rlm` ships `scripts/rlm_repl.py`, a persistent-REPL helper tested by `tests/test_rlm_repl.py` (stdlib `unittest`).
`python-uv-starter` ships `scripts/scaffold.sh`, which renders `assets/project/*.tmpl` into the current directory, tested by `tests/scaffold.bats`.

## Conventions

- Semantic Versioning. Record changes in `CHANGELOG.md` (Keep a Changelog format) and keep the version in the `README.md` header in sync.
- Default branch is `develop`.
