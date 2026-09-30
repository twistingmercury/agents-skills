# Claude Code Integration

This integration packages the shared specialist catalog for Claude Code. For
the project-wide role and skill catalogs, start with the [root README](../README.md).

## Agent definitions and naming

Claude agents are Markdown files under `agents/`. YAML frontmatter declares the
agent's display `name`, description, model, memory, and allowed tools; the body
contains its working instructions.

Display names use spaces, such as `go software engineer`, while definition
filenames use hyphens, such as `go-software-engineer.md`. Use the display name
when requesting or delegating to a role.

See [About the agents](../agents/ABOUT-THE-AGENTS.md) for the twelve live
agents and the workflow behind them.

## Main Claude workflow

Process belongs to superpowers. The main session brainstorms, plans, reviews,
and integrates through the `superpowers:*` skills and hands implementation to
the specialist whose language or domain matches. The `api architect` and
`data architect` are consultants the brainstorm draws on; the rest of the
catalog takes the implementer seat. For example:

```text
User: "Build a user management REST API in Go"

Main Claude:
  1. Brainstorms the design with superpowers:brainstorming; the api architect
     drafts the OpenAPI contract and the data architect the schema
  2. Records the approved design under docs/architecture/ with /arch-docs
  3. Writes the plan with superpowers:writing-plans
  4. Runs the plan with superpowers:subagent-driven-development: go software
     engineer implements handlers, data engineer writes migrations, go e2e
     test engineer writes black-box tests, devops engineer adds the
     Dockerfile and CI
  5. Reviews with superpowers:requesting-code-review
  6. Integrates with superpowers:finishing-a-development-branch
```

Narrow requests with a known owner skip the flow and go to one specialist:

```text
"Write a Dockerfile and GitHub Actions workflow" -> devops engineer
"Add a migration that creates the invoices table" -> data engineer
"Write scripts/backup.sh with its BATS tests" -> shell script engineer
"Update the project README" -> technical writer
```

If the request changes behavior or adds functionality, start at brainstorming
instead.

## Rules

The files under [`rules/`](../rules/) install to `~/.claude/rules/`, where
Claude Code loads them for the main session and for subagents.

- `agent-delegation.md`, `code-shape.md`, `library-docs.md`, and `index.md`
  have no `paths:` frontmatter and load in every session.
- The rules in the subject folders and `docker.md` carry `paths:` globs and
  load when a matching file is read.

## Installation

### Prerequisites

- Claude Code is installed.
- Bash 4 or newer is available.
- Make is available if using the Make targets below.
- The home directory is writable. The installer creates `~/.claude` as needed.

From the repository root, run either the Make target or direct entrypoint:

```bash
make install-claude
./install/install.sh
```

The entrypoint runs the agent, rules, and skill phases in order. The default
destinations are:

- agents: `~/.claude/agents/`
- rules: `~/.claude/rules/`
- skills: `~/.claude/skills/`

Run a single phase when troubleshooting or developing an installer:

```bash
./install/01_install_agents.sh
./install/02_install_rules.sh
./install/03_install_skills.sh
```

### Preservation behavior

- Agent and skill names absent from the repository catalog are preserved. An
  agent or skill whose name collides with a repository-managed one is
  overwritten. Local edits to installed copies are overwritten on the next run.
- An agent or skill that is renamed or removed from the repository leaves a stale
  copy behind in the destination. There is no automatic pruning; you must delete
  it manually.
- Broken symlinks left by previous installations are swept out; the installer
  replaces the skill directory wholesale with `cp -R`.
- Rules follow the same contract per top-level entry of `rules/`: a rule file
  or subject folder with a matching name in `~/.claude/rules/` is replaced
  wholesale, and other entries there are preserved.
- The installer no longer reads or writes `~/.claude/CLAUDE.md`.

Restart Claude Code after installation so it reloads agents, rules, and skills.

## Troubleshooting

### Removing stale .NET starter copies

The .NET API starter skill was removed from the catalog pending a rewrite, and
the installer never prunes, so installed copies named `dotnet-postgres-api-starter`
(or the older `dotnet-minimal-api-starter`) remain until you delete them.
Save any custom changes, then remove those entries from `SKILLS_DIR` when set,
otherwise `~/.claude/skills`, and restart Claude Code.

### Removing stale agent and skill copies

The `bats test engineer`, `code reviewer`, `go software architect`, and
`solutions architect` agents and the `shell-script` skill were retired from
the catalog, and the installer never prunes, so copies installed by an earlier
run remain until you delete them. Save any custom changes, then remove these
files from `AGENTS_DIR` when set, otherwise `~/.claude/agents`:

- `bats-test-engineer.md`
- `code-reviewer.md`
- `go-software-architect.md`
- `solutions-architect.md`

Remove the `shell-script` directory from `SKILLS_DIR` when set, otherwise
`~/.claude/skills`, and restart Claude Code.

### Agents or skills do not appear

Rerun the installer and restart Claude Code. Moving or deleting the checkout
does not break an existing installation, but the installer must be rerun to
pick up repository updates.

### Rules load twice after upgrading

Earlier versions wrote the delegation, Code Shape, and Library Documentation
rules into `~/.claude/CLAUDE.md` between `<!-- BEGIN AGENT RULES -->` and
`<!-- END AGENT RULES -->`. The installer no longer manages that block and does
not remove it. Delete the block, markers included, so the same rules are not
loaded from both `CLAUDE.md` and `~/.claude/rules/`.

## Testing

With ShellCheck installed, validate the installer shell scripts:

```bash
shellcheck install/*.sh
```

Run the shared test suites from the repository root using `make test`; see the
[root README](../README.md#testing) for details.
