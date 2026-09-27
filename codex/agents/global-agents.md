# Codex Global Agent Guidance

The main agent owns the user request, integration decisions, and final response. Custom agents work only on the concrete task delegated by their parent, report results and blockers back to that parent, and do not coordinate unrelated work.

Delegate bounded tasks to the specialist whose registered `name` matches the work. Parallelize only independent tasks, give write agents non-overlapping file ownership, and wait for every delegated result before integrating or responding. Consultants and reviewers return recommendations unless explicitly tasked with changes; implementation specialists should not broaden their scope. Writable specialists may stage and commit their own work; no agent pushes.

## Custom agent registry

The exact TOML `name` is authoritative when selecting an agent:

- `api_architect`: designs REST, GraphQL, gRPC, and AsyncAPI contracts.
- `bats_test_engineer`: writes isolated black-box BATS coverage for shell scripts.
- `code_reviewer`: reviews correctness, security, maintainability, and project conventions.
- `data_architect`: designs storage schemas, relationships, constraints, and indexes.
- `data_engineer`: implements SQL/Cypher migrations and data transformations.
- `devops_engineer`: implements containers, CI/CD, and deployment infrastructure.
- `dotnet_software_engineer`: implements and refactors production C#/.NET systems.
- `go_e2e_test_engineer`: writes black-box Go tests for APIs and CLIs.
- `go_software_architect`: creates detailed Go implementation architecture and plans.
- `go_software_engineer`: implements, refactors, and tests production Go code.
- `python_software_engineer`: implements, refactors, and tests production Python code.
- `react_software_engineer`: implements and tests React and TypeScript applications.
- `rlm_subcall_agent`: extracts compact, query-specific evidence from large context chunks.
- `shell_script_engineer`: implements portable, maintainable shell scripts.
- `solutions_architect`: recommends high-level, language-agnostic system architecture.
- `technical_writer`: creates and maintains project documentation.

## Code Shape

These rules apply to code in every language. Language agents carry their own examples.

- **Never-nester.** Handle errors and edge cases first and return early; keep the happy path at the left margin. Move non-trivial loop and `case` bodies into named functions.
- **Blank line after every `if` block**, except before the enclosing block's closing brace or an `else`.
- **Named callbacks.** A callback longer than a line or two becomes a named function, not an inline literal.
- **One job per function.** When a function grows long, split it along its seams.
- **Modern standard library.** Prefer current built-ins and stdlib helpers over hand-written equivalents.
- **Comments explain why.** State the reason code exists or has its shape. If code needs a comment to say *what* it does, rewrite the code.
- **Bare minimum.** Build only what the task needs; ask before adding abstractions, layers, or dependencies.
- **Fix, don't suppress.** Never silence linters or security scanners with inline suppressions (`#nosec`, `//nolint`, `# noqa`, `// eslint-disable`); fix the code.

## Library Documentation

When a task depends on a library, framework, SDK, CLI, or cloud service, fetch current documentation from the Context7 MCP server, when available, instead of relying on memory. The repository's pinned versions and conventions take precedence.

Installed skills are instruction packages, not agents. Follow every applicable installed skill when its trigger conditions match the task.

More specific project instructions and direct user instructions override this global guidance according to Codex instruction precedence.
