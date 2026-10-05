# Claude Code Agent Ecosystem

> **Maturity Level**: Basic - Ready for use and actively evolving.
> **Version**: v3.0.0
>
> - **Emerging**: Prototype, not production-ready, expect breaking changes
> - **Basic**: Production-ready but actively evolving, expect minor version changes
> - **Mature**: Stable, battle-tested, changes are rare

Specialized development agents and reusable skills for AI-assisted software
work in Claude Code.

## Table of Contents

- [Usage](#usage)
- [Prerequisites](#prerequisites)
- [How it works](#how-it-works)
- [Key Considerations](#key-considerations)
- [Development Considerations](#development-considerations)
- [Versioning](#versioning)

## Usage

Request a role by name, or describe the outcome and let Claude route work to
the appropriate specialist. The table lists roles by their snake_case label;
Claude Code display names use spaces (`go software engineer`).

| Area           | Roles                                                                                                                                               |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Architecture   | `api_architect`, `data_architect`                                                                                                                   |
| Implementation | `go_software_engineer`, `python_software_engineer`, `dotnet_software_engineer`, `react_software_engineer`, `shell_script_engineer`, `data_engineer` |
| Operations     | `devops_engineer`                                                                                                                                   |
| Documentation  | `technical_writer`                                                                                                                                  |
| Support        | `rlm_subcall_agent`                                                                                                                                 |

Portable skills:

| Skill                                                          | Purpose                                                |
| -------------------------------------------------------------- | ------------------------------------------------------ |
| [`check-push-readiness`](skills/check-push-readiness/SKILL.md) | Read-only audit of unpushed commits before a push      |
| [`design-docs-writer`](skills/design-docs-writer/SKILL.md)     | Create and update architecture documentation           |
| [`docker-first-ci`](skills/docker-first-ci/SKILL.md)           | Implement and harden Docker-first CI/CD pipelines      |
| [`mermaid-diagrams`](skills/mermaid-diagrams/SKILL.md)         | Write Mermaid diagrams locally, never to third parties |
| [`prime`](skills/prime/SKILL.md)                               | Survey a repository and build working context          |
| [`python-uv-starter`](skills/python-uv-starter/SKILL.md)       | Scaffold an empty uv-based Python CLI project          |
| [`readme-writer`](skills/readme-writer/SKILL.md)               | Create or update a README from a standard template     |
| [`rlm`](skills/rlm/SKILL.md)                                   | Run long-context tasks using a persistent local REPL   |

## Prerequisites

The catalog requires the following before installation and use.

### Claude Code plugins and skills

| Plugin              | Marketplace                                                 | Needed for                                                                                                                                                                        | Required |
| ------------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `superpowers`       | `claude-plugins-official`                                   | The design/plan/review/finish flow in `rules/agent-delegation.md` and `agents/ABOUT-THE-AGENTS.md`; seven agents also preload its verification, debugging, TDD, and review skills | Required |
| `elements-of-style` | `obra/superpowers-marketplace`                              | The `writing-clearly-and-concisely` skill preloaded by the `api architect`, `data architect`, and `technical writer`                                                              | Optional |
| `frontend-design`   | `claude-plugins-official`                                   | Preloaded by the `react software engineer`                                                                                                                                        | Optional |
| `gopls-lsp`         | `claude-plugins-official`                                   | Code intelligence, refactoring, and analysis for the `go software engineer`                                                                                                       | Required |
| `pyright-lsp`       | `claude-plugins-official`                                   | Static type checking and code intelligence for the `python software engineer`                                                                                                     | Required |
| `python-debugpy`    | GitHub repo `marco9442/openclaw-skills` (skill, not plugin) | Interactive Python debugging for the `python software engineer`                                                                                                                   | Required |

Run these inside Claude Code:

```text
/plugin install superpowers@claude-plugins-official
/plugin marketplace add obra/superpowers-marketplace
/plugin install elements-of-style@superpowers-marketplace
/plugin install frontend-design@claude-plugins-official
/plugin install gopls-lsp@claude-plugins-official
/plugin install pyright-lsp@claude-plugins-official
```

For `python-debugpy`, copy the `python-debugpy` folder from
`marco9442/openclaw-skills` into `~/.claude/skills/`, or use skillfish:
`npx skillfish add marco9442/openclaw-skills`. That repository mirrors many
unrelated skills and skillfish may install all of them, so keep only
`python-debugpy`.

Claude Code skips a missing preloaded skill with only a debug-log warning, so optional plugins degrade an agent but do not break it.

#### Dependencies of these

- `gopls-lsp` requires the `gopls` binary, installed by `scripts/go_tool_chain.sh`,
  with `$GOPATH/bin` (or `$HOME/go/bin`) on PATH; this needs the Go toolchain.
- `pyright-lsp` requires the `pyright` binary, installed by `scripts/python_tool_chain.sh`, which
  needs `uv` installed first.
- `python-debugpy` requires `python3` and the `debugpy` package:
  `python3 -m pip install debugpy`.

### MCP server

**Context7**: The catalog requires Context7 for library documentation; every agent lists it in its tools, and `rules/library-docs.md` has agents fetch current library documentation from it instead of relying on memory. Install per the Context7 Claude Code guide: `npx ctx7 setup --claude`. Manual option: `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY`. Context7 is a hosted service, so library questions agents send it leave the machine.

### Local tools

To install and test this repository:

- `bash`, `git`, GNU `make`, Python 3.11+, `bats`

To lint it (contributors):

- `shellcheck`, `markdownlint`

For Python projects and `scripts/python_tool_chain.sh` (install `uv` first, see the table below):

- `uv` (the per-project `uv add --dev` route, the `python-uv-starter` skill, and the Python tool script)

Used when a skill runs:

- `docker` (`docker-first-ci`, `python-uv-starter`)
- `git` (`check-push-readiness`, `prime`, `readme-writer`, `design-docs-writer`)
- `mmdc` (mermaid-cli, optional; used by `mermaid-diagrams` skill for local validation)

### Development environments

Install the toolchain for each language you want a specialist agent to work in; you only need
the ones you use.

| Specialist agent           | Install                                                                                                                                                              | The agent runs                                                                                                                                                              |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `go software engineer`     | Go toolchain (match the project's `go.mod`), `goimports`, `golangci-lint`, `govulncheck`, `gosec`, `gopls`                                                           | `goimports -w .`, `golangci-lint run`, `govulncheck ./...`, `gosec ./...`, `go vet ./...`, `go test ./...`, `go test -race ./...`                                           |
| `python software engineer` | Python 3.12+, `uv`, `ruff`, `mypy`, `pyright`, `pytest`, `bandit`, `debugpy`                                                                                         | `ruff format .`, `ruff check --fix .`, `mypy .`, `pytest`, `bandit -r . -q`                                                                                                 |
| `dotnet software engineer` | .NET 10 SDK                                                                                                                                                          | `dotnet format`, `dotnet build --warnaserror`, `dotnet test`, `dotnet list package --vulnerable`                                                                            |
| `react software engineer`  | Node.js with npm (or the project's package manager); TypeScript, Vite, ESLint, Prettier, Vitest, and Playwright come from the project's own `package.json`           | `npm run typecheck`, `lint`, `format:check`, `test`, `build`, plus `test:e2e` when Playwright is configured                                                                 |
| `shell script engineer`    | `bash`, `shellcheck`, `bats` (the `bats-support` and `bats-assert` helpers are vendored in `tests/bats/`)                                                            | `bash -n`, `shellcheck`, `bats`                                                                                                                                             |
| `devops engineer`          | Docker with Compose and buildx, plus `shellcheck` and `bats` for build scripts; Helm, Terraform, minikube, and kubectl                                               | `docker build`, `docker compose`, `shellcheck`, `bats`; `helm lint`/`template`; `terraform fmt`/`validate`/`plan`; `minikube start`; `kubectl apply`/`get`/`rollout status` |
| `data engineer`            | Docker (verification runs in throwaway containers; database clients run inside); optional `sqlfluff` when the project configures it; migration tools are per project | `docker run`/`docker exec` with `psql`, `mysql`, `sqlcmd`, `mongosh`, `cqlsh`, or `cypher-shell`, then `sqlfluff lint`                                                      |
| `technical writer`         | `markdownlint`                                                                                                                                                       | `markdownlint`                                                                                                                                                              |

The `api architect` and `data architect` need nothing installed beyond the plugins and MCP server above.

### Installing local tools

Three optional scripts install toolchain dependencies for Go, Python, and Node:
`scripts/go_tool_chain.sh` (needs `go`), `scripts/python_tool_chain.sh` (needs `uv`),
and `scripts/node_tool_chain.sh` (needs `npm`); install that base tool first. They take no flags, need no sudo,
and can be re-run safely. Shell, DevOps, and .NET toolchains have no script; use
the table below as your reference.

Each tool is listed once. The `go install` tools land in `$HOME/go/bin`, which must be on your PATH.

| Tool                           | Install                                                                                                                                                                                                             | Needed by                            |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| bash                           | Built in                                                                                                                                                                                                            | Core                                 |
| git                            | macOS `brew install git`; Linux `apt install git` or `dnf install git`                                                                                                                                              | Core                                 |
| GNU make                       | macOS Xcode Command Line Tools (`xcode-select --install`) or `brew install make` (installed as `gmake`); Linux `apt install make` or `dnf install make`                                                             | Core                                 |
| Python 3.11+                   | macOS `brew install python@3.11`; Linux `dnf install python3.11` (Fedora) or [python.org](https://www.python.org/downloads/)                                                                                        | Core, testing                        |
| bats                           | macOS `brew install bats-core`; Linux `apt install bats` or `dnf install bats`                                                                                                                                      | Testing, shell engineer              |
| shellcheck                     | macOS `brew install shellcheck`; Linux `apt install shellcheck` or `dnf install shellcheck`                                                                                                                         | Linting, shell engineer              |
| markdownlint                   | `scripts/node_tool_chain.sh`                                                                                                                                                                                        | Linting, technical writer            |
| Docker with Compose and buildx | macOS [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) (includes both); Linux [Docker Engine](https://docs.docker.com/engine/install/) plus the Compose and buildx plugins it describes | Skills, DevOps and data engineers    |
| uv                             | macOS `brew install uv`; Linux `curl -LsSf https://astral.sh/uv/install.sh \| sh`                                                                                                                                   | Python engineer, `python-uv-starter` |
| mmdc                           | `scripts/node_tool_chain.sh`                                                                                                                                                                                        | `mermaid-diagrams` (optional)        |
| Go toolchain                   | macOS `brew install go`; Linux [go.dev/doc/install](https://go.dev/doc/install)                                                                                                                                     | Go engineer                          |
| goimports                      | `scripts/go_tool_chain.sh`                                                                                                                                                                                          | Go engineer                          |
| govulncheck                    | `scripts/go_tool_chain.sh`                                                                                                                                                                                          | Go engineer                          |
| gosec                          | `scripts/go_tool_chain.sh`                                                                                                                                                                                          | Go engineer                          |
| golangci-lint                  | macOS `brew install golangci-lint`; Linux [install page](https://golangci-lint.run/docs/welcome/install/)                                                                                                           | Go engineer                          |
| .NET 10 SDK                    | macOS `brew install dotnet`; Linux [.NET 10 downloads](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)                                                                                                     | .NET engineer                        |
| Node.js with npm               | macOS `brew install node`; Linux [nodejs.org](https://nodejs.org/en/download)                                                                                                                                       | React engineer, npm tools above      |
| ruff, mypy, pytest, bandit     | Per project: `uv add --dev ruff mypy pytest bandit`, then `uv run <tool>`. Or run `scripts/python_tool_chain.sh` for a global install                                                                               | Python engineer                      |
| sqlfluff                       | Per project: `uv add --dev sqlfluff`, then `uv run sqlfluff`. Or run `scripts/python_tool_chain.sh` for a global install                                                                                            | Data engineer                        |
| Helm                           | macOS `brew install helm`; Linux [helm.sh](https://helm.sh/docs/intro/install/)                                                                                                                                     | DevOps engineer                      |
| Terraform                      | [HashiCorp install page](https://developer.hashicorp.com/terraform/install) (macOS and Linux)                                                                                                                       | DevOps engineer                      |
| minikube                       | macOS `brew install minikube`; Linux [minikube start](https://minikube.sigs.k8s.io/docs/start/)                                                                                                                     | DevOps engineer                      |
| kubectl                        | macOS `brew install kubernetes-cli`; Linux [kubernetes.io](https://kubernetes.io/docs/tasks/tools/)                                                                                                                 | DevOps engineer                      |

`gopls`, `pyright`, and `debugpy` install under [Dependencies of these](#dependencies-of-these).

## How it works

The installer runs three phases:

1. Install agent definitions.
2. Install rules.
3. Install skills.

Superpowers owns design, planning, review, and integration: the main session
runs `superpowers:brainstorming`, `writing-plans`, `requesting-code-review`,
and `finishing-a-development-branch` itself. The catalog's specialists
implement. The API and data architects are consultants that return a
specification; every other role takes the implementer seat for its language
or domain.

## Key Considerations

This is a reference implementation, not a framework. Adapt prompts and routing
rules to the needs of each project. Projects generated by these agents follow
a specific internal structure, vertical slices inside clean architecture,
recorded in [`rules/go/architecture.md`](rules/go/architecture.md).

The installer copies agent definitions, rules, and skills into `~/.claude`
(`agents/`, `rules/`, `skills/`), flattening agent group subdirectories,
replacing each shipped skill and rule entry, and never modifying
`~/.claude/CLAUDE.md`. Since it never prunes, a renamed or removed agent or
skill leaves a stale copy behind; you must delete it by hand. Rerun the
installer to refresh your installation with updates from an updated checkout.
Review potential name conflicts and existing global guidance before installation.

## Development Considerations

### Quick Start

Check the [Prerequisites](#prerequisites) section above. Then install from the
repository root:

```bash
make install
```

Restart Claude Code after installation.

### Building & running

This repository has no compiled build artifact. List the supported install and
test targets with:

```bash
make help
```

### Testing

With Python 3.11+ and Make available, run the test suites from the repository
root:

```bash
make test
```

This runs the RLM unit tests, the python-uv-starter bats tests, and the toolchain
script tests in `scripts/tests/`. You may also run the RLM tests directly:

```bash
(cd skills/rlm && python3 -m unittest discover -s tests -v)
```

### Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/).

See [CHANGELOG.md](CHANGELOG.md) for release notes. Inspect the checked-out
revision relative to Git tags with:

```bash
git describe --tags --always
```

Between tags, the command includes the commit count and abbreviated commit hash.
