<!-- BEGIN AGENT RULES -->

## Agent Delegation Rules

**Last Updated: 2026-09-27**

**Main Claude coordinates. Specialists implement. For non-trivial tasks, delegate to the appropriate specialist rather than implementing directly.**

### Delegation Table

| Task                                     | Delegate To             |
| ---------------------------------------- | ----------------------- |
| BATS tests                               | `bats test engineer`    |
| Shell scripts                            | `/shell-script` skill   |
| Go code/services                         | `go software engineer`  |
| E2E tests                                | `go e2e test engineer`  |
| API specs                                | `api architect`         |
| Documentation                            | `technical writer`      |
| System architecture                      | `solutions architect`   |
| Go architecture                          | `go software architect` |
| DevOps/Docker/CI                         | `devops engineer`       |
| Data schema/models                       | `data architect`        |
| Database migrations and data scripts     | `data engineer`         |
| Code review/compliance                   | `/code-review` skill    |
| Create or update README.md               | `/readme-writer` skill  |
| Create or update architectural documents | `/arch-docs` skill      |

### Constraints

- Architects and reviewers are **consultants** — they return recommendations; they do not coordinate
- Main Claude creates coordination plans and delegates; specialists execute
- Specialists may stage and commit their own work (`git add`, `git commit`); nobody but the user pushes

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

When a task depends on a library, framework, SDK, CLI, or cloud service, fetch current documentation with Context7 (`mcp__context7__resolve-library-id`, then `mcp__context7__query-docs`) instead of relying on memory. The repository's pinned versions and conventions take precedence.
<!-- END AGENT RULES -->
