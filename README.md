# Claude Code Agent Ecosystem

> **Maturity Level**: Basic - Ready for use and actively evolving.
> **Version**: v2.0.0
>
> - **Emerging**: Prototype, not production-ready, expect breaking changes
> - **Basic**: Production-ready but actively evolving, expect minor version changes
> - **Mature**: Stable, battle-tested, changes are rare

Specialized development agents and reusable skills for AI-assisted software
work in Claude Code. See the [Claude Code guide](claude/README.md) for
installation and client-specific behavior.

## Table of Contents

- [Usage](#usage)
- [How it works](#how-it-works)
- [Key Considerations](#key-considerations)
- [Development Considerations](#development-considerations)
- [Versioning](#versioning)

## Usage

Request a role by name, or describe the outcome and let Claude route work to
the appropriate specialist. The table lists roles by their snake_case label;
Claude Code display names use spaces (`go software engineer`).

| Area                     | Roles                                                                                                                                               |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Architecture             | `api_architect`, `data_architect`                                                                                                                   |
| Implementation           | `go_software_engineer`, `python_software_engineer`, `dotnet_software_engineer`, `react_software_engineer`, `shell_script_engineer`, `data_engineer` |
| Testing                  | `go_e2e_test_engineer`                                                                                                                              |
| Operations               | `devops_engineer`                                                                                                                                   |
| Documentation            | `technical_writer`                                                                                                                                  |
| Support                  | `rlm_subcall_agent`                                                                                                                                 |

Portable skills:

| Skill                                                          | Purpose                                                  |
| -------------------------------------------------------------- | -------------------------------------------------------- |
| [`arch-docs`](skills/arch-docs/SKILL.md)                       | Create and update architecture documentation             |
| [`capture-requirements`](skills/capture-requirements/SKILL.md) | Capture requirements for architecture and design handoff |
| [`check-push-readiness`](skills/check-push-readiness/SKILL.md) | Assess committed changes before pushing                  |
| [`code-review`](skills/code-review/SKILL.md)                   | Coordinate review across multiple concerns               |
| [`docker-first-ci`](skills/docker-first-ci/SKILL.md)           | Implement and harden Docker-first CI/CD pipelines        |
| [`prime`](skills/prime/SKILL.md)                               | Survey a repository and build working context            |
| [`python-uv-starter`](skills/python-uv-starter/SKILL.md)       | Scaffold an empty uv-based Python CLI project            |
| [`readme-writer`](skills/readme-writer/SKILL.md)               | Create or update a README from a standard template       |
| [`rlm`](skills/rlm/SKILL.md)                                   | Run long-context tasks using a persistent local REPL     |

The [code-review skill](skills/code-review/SKILL.md) writes reports by
default to `docs/.code_reviews/code_review_YYYY_mm_dd_HHMM.md` in the reviewed
repository, creating the directory if needed and keeping it untracked through
the local Git exclude file. Each review and re-review creates a new file without
overwriting earlier reports.

Findings use stable IDs and describe the trigger, impact, code location,
evidence, recommended change, and observable acceptance checks. Reports use
`ACCEPTABLE`, `CHANGES_REQUIRED`, or `INCOMPLETE` verdicts, with assessment
completeness recorded separately as `COMPLETE` or `INCOMPLETE`. An open finding
or failed required check requires changes; missing required evidence or
independent reviewers prevents acceptance. The skill defines the full report
format, disposition requirements, and verdict rules. Reviews account for explicit
user concerns and relevant test groups, disclosing sampling and omissions.
Re-reviews reconcile every prior finding with evidence; a finding that was not
rediscovered remains open until its disposition is justified.

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

The installer copies agent definitions, rules, and skills, so they remain
usable after moving or removing the checkout. Rerun the installer to refresh your
installation with updates from an updated checkout. Review potential name
conflicts and existing global guidance before installation.

Read the [Claude Code guide](claude/README.md) for naming, preservation
rules, and destinations before installing.

## Development Considerations

### Quick Start

Install from the repository root after checking the prerequisites in the
Claude Code guide:

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

This runs the shared RLM unit tests. You may also run them directly:

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
