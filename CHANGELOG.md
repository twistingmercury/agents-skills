# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-09-27

### Added

- Added language-agnostic Code Shape rules (never-nester, named callbacks,
  why-comments, modern stdlib, no inline linter suppressions) to the Claude and
  Codex global rules.
- Added a Code shape subsection with Go examples to the Go software engineer,
  and a Code Shape checklist to the code reviewer, for both platforms.
- Added Context7 documentation guidance to the global rules and to every
  specialist that writes or designs against third-party libraries.
- Added clean architecture principles (dependency rule, ports and adapters,
  boundary data, proportional layering) to the solutions, Go, API, and data
  architects, each with guidance for applying them in its own domain. The Go
  architect's recommended layouts now include a domain package and composition
  root.
- Added the project structure convention, vertical slices inside clean
  architecture (subdomain, then use-case slice), to the architects, the Go,
  .NET, Python, and React engineers, and a structure checklist to the code
  reviewer. `docs/project_structure.md` explains its justification and
  tradeoffs.
- Added superpowers skills to the Claude specialists:
  `verification-before-completion`, `test-driven-development`,
  `systematic-debugging`, and `receiving-code-review` for the engineers and
  test engineers, and `writing-plans` for the Go software architect. The Codex
  counterparts carry the same discipline as a Working Discipline section.

### Changed

- The Go software engineer now requires testify, defers to project-defined
  quality gates, and targets the module's `go` directive instead of Go 1.21.
- The code reviewer derives conventions from project instructions, linter
  configuration, and surrounding code instead of a pattern store.
- Specialists may now stage and commit their own work (`git add`,
  `git commit`); `git push` is explicitly denied for every Claude agent and
  forbidden in the Codex instructions. The code reviewer and RLM subcall agent
  remain unable to stage or commit.
- The data architect and data engineer are now database-agnostic, covering
  relational (PostgreSQL, MySQL, SQL Server), document (MongoDB), wide-column
  (Cassandra), and graph (Neo4j) stores. The architect selects stores and
  designs per family; the engineer follows a per-family playbook and owns
  native and tool-format migrations, while ORM code migrations stay with the
  language engineers.
- The data engineer verifies migrations against a disposable container using
  the engine's own client (up, down, up), with Bash access limited to Docker,
  the database clients, migration CLIs, `make`, `bats`, and `sqlfluff`. It can
  write engine-native files anywhere and other formats only inside
  `migrations/`, `db/`, or `database/` directories.

### Removed

- Removed `superpowers:brainstorming` from the solutions architect; it needs a
  user dialogue that a subagent cannot hold.
- Removed all Mnemonic MCP tool grants, retrieval sections, and the global
  Mnemonic Patterns rule, plus the stale Cognee documentation.
- Removed `ralph-loop-docs-writer` from the shared skill catalog and README; it
  now lives in the Gralph project. Existing installed copies are not pruned
  and must be deleted manually.
- Removed the `make upload` target, which called a script that no longer
  exists in this repository.

### Fixed

- Stopped tracking Python bytecode caches and ignored `__pycache__/`.

## [1.5.0] - 2026-09-14

### Added

- Added `capture-requirements`, a shared skill for iterative requirements
  discovery, verifiable acceptance criteria, and versioned architecture handoffs
  with explicit assumptions, open questions, and readiness assessments.

## [1.4.0] - 2026-09-14

### Changed

- Both Claude Code and Codex installers now use plain `cp`/`install` to create
  local copies of agents and skills instead of symlinks. This allows installed
  content to remain usable after moving or removing the repository checkout.
- Installed copies no longer track the checkout, so the installer must be rerun
  to pick up repository updates.
- Codex installer no longer requires `rsync`. Running the test suites requires
  BATS, Python 3.11+, Bash 4+, and Make.

### Removed

- Claude Code and Codex no longer maintain installer test suites (`claude/tests/`,
  `codex/tests/`, `make test-claude`, and `make test-codex` targets have been
  deleted). The shared skill test suites remain and are run via `make test`.
- Codex manifest-based preservation contract and the `$CODEX_HOME/.mnemonic-agents-skills/managed-paths`
  manifest file. Agents and skills installed from the repository are still
  overwritten on update, but stale copies from renamed or removed repository
  entries must be manually deleted.
- `codex/install/lib/` helper scripts (`managed_state.sh`, `materialize_file.sh`).
- The `FORCE` flag from Claude Code and Codex agent and skill installers
  (`01_install_agents.sh`, `03_install_skills.sh`). The `FORCE` flag remains
  in `02_install_global_agents.sh` for the global-rules phase.

## [1.3.3] - 2026-09-14

### Changed

- Updated `ralph-loop-docs-writer` to generate typed `LOOP_TASKS.yaml` and a
  self-contained `LOOP_PROMPT.md`, with Gralph-owned status, agent checkpoints,
  Markdown activity logs, and separate JSON results.
- Unified embedded activity and JSON examples with their standalone templates;
  clarified best-effort failure finalization and bounded validation retries.
- Added explicit state-preserving migration and moved legacy resources outside
  the installed package into `_archive/ralph_loop_docs_writer/`. Installation
  leaves existing project workflows unchanged.

## [1.3.2] - 2026-09-11

### Changed

- Strengthened code reviews to trace production behavior, inspect observability,
  assess test value and missing regression coverage, and challenge unnecessary
  complexity across staged, unstaged, and untracked changes.
- Required independent review perspectives, evidence-backed finding dispositions,
  re-review of fixes, and explicit verdict and assessment-completeness rules.
- Standardized reports with stable finding IDs, concrete triggers and impact,
  code locations, remediation guidance, observable acceptance checks, and
  verification evidence tied to the reviewed candidate.
- Changed the default report path to `./local/code_review_YYYY_mm_dd_vN.md`,
  allocating a new version for every review and re-review without overwriting
  earlier reports.
- Required explicit coverage of user concerns and relevant test groups, with
  inspected cases, sampling limits, and material omissions recorded.
- Required re-reviews to reconcile every prior finding, preserving identifiers
  and evidence so missed findings cannot silently disappear.
- Updated the report template, README guidance, and document-naming test to
  match the revised review workflow.

## [1.3.1] - 2026-09-09

### Changed

- Renamed `dotnet-minimal-api-starter` to `dotnet-postgres-api-starter` and removed
  the `base-api` application-only alternative.
- Black-box tests now require and preserve the existing database image produced
  by `make build-db`; CI builds that image explicitly before `make build`.

### Fixed

- Scaffold rendering preserves supported Git and agent metadata while rejecting
  existing application files.
- Scaffold tests resolve the renderer relative to the checkout instead of a
  hard-coded installed skill path.
- Black-box cleanup removes the temporary test image after success or failure
  while preserving supplied API and prebuilt database images.
- CI defaults to a lowercase GHCR image name derived from the GitHub repository,
  with an `IMAGE_NAME` repository-variable override, matching its GHCR login.

## [1.3.0] - 2026-09-08

### Added

- Added a complete .NET 10 minimal API and PostgreSQL repository scaffold with
  Docker builds, unit and black-box tests, Compose, CI, Helm, and Envoy assets.

## [1.2.1] - 2026-09-06

### Changed

- Simplified Codex installers by removing unused `FORCE` assignments and agent
  discovery helpers, sharing staged file copying, and removing redundant
  rsync `--delete` for empty skill staging directories. Existing ownership,
  refresh, migration, and preservation behavior remains unchanged.
- Strengthened BATS coverage for temporary-file creation, copy, and rename
  failures, including staging cleanup and preservation of existing managed files.

### Fixed

- Corrected README descriptions of Codex copies, ordinary refresh, staged skill
  replacement, Claude preservation behavior, and agent sandbox configuration.
- Updated the README skill catalog, installation targets, prerequisites, and
  test commands that clear inherited destination overrides.
- Made RLM README examples runnable with bundled files and documented working
  directories, state paths, and optional parser dependencies.

## [1.2.0] - 2026-09-03

### Fixed

- Materialized Codex agents, skills, and global rules as manifest-owned local
  copies rather than repository symlinks, allowing Codex to load them without
  depending on the checkout location.

## [1.1.1] - 2026-08-19

### Added

- Added the `check-push-readiness` skill to assess the committed changes that
  the next push would transfer.

## [1.1.0] - 2026-08-17

### Changed

- Reorganized Claude and Codex agents, installers, and tests under their
  respective top-level platform directories.
- Moved portable skills to `shared/skills/` and the shared print helper to
  `lib/print.sh`.
- Renamed installer phases to snake_case and removed the legacy root-level
  `install/`, `agents/`, and `skills/` directories.
- Changed the project license from Apache-2.0 to MIT.

## [1.0.0] - 2026-03-16

### Added

- BATS unit tests for all three install scripts (`01-install-agents.sh`, `02-install-global-agent-rules.sh`, `03-install-skills.sh`) — 53 tests in `install/tests/`
- `make test` target to run the full test suite (requires `bats` on `PATH`)
- `FORCE` flag support for `03-install-skills.sh` — `FORCE=1` removes and replaces existing skill symlinks
- Safety guard in `remove_repo_managed_skills`: refuses to operate when `SKILLS_DIR` is empty or `/`

### Changed

- All install scripts now use `set -euo pipefail` for strict error handling
- Install scripts refactored for testability: removed logging side effects, guarded entry points with `BASH_SOURCE[0] == $0` check, made path variables env-var overridable via `${VAR:-default}`
- `02-install-global-agent-rules.sh`: extracted top-level flow into `install_global_agent_rules()` function; `TIMESTAMP` preserved as a standalone overridable variable; `trap` changed from `EXIT` to `RETURN` for correct function-scoped cleanup
- `03-install-skills.sh`: safety check for empty/root `SKILLS_DIR` moved before the `! -d` early-return guard (was previously unreachable for empty strings)

### Fixed

- `make install` target pointed to wrong script path (`./setup/scripts/installer.sh` → `./install/scripts/install.sh`)

## [0.0.1] - 2026-03-16

Initial release. Agent definitions, global delegation rules, skill bundles, and installer scripts.
