# About the agents

The agents under `agents/` are specialists. Each one is an implementer seat or
an artifact producer with a narrow remit: it takes a task, produces the code,
spec, tests, or documentation it is responsible for, and returns. None of them
coordinate other agents.

Process belongs to superpowers. The main session brainstorms, plans, reviews,
and integrates through the `superpowers:*` skills and hands implementation to
the specialist whose language or domain matches. `rules/agent-delegation.md`
is the routing table and says when a task is big enough to delegate; this
document explains the roles and the flow behind it.

## Agent hierarchy

| Area                    | Agent                      | Job                                                                                        |
| ----------------------- | -------------------------- | ------------------------------------------------------------------------------------------ |
| Architecture consultant | `api architect`            | Designs OpenAPI, GraphQL, Protocol Buffer, and AsyncAPI specs from an approved design       |
| Architecture consultant | `data architect`           | Selects the store and designs the data model, schema, indexes, and migration plan          |
| Implementation          | `go software engineer`     | Writes production Go under `rules/go/`                                                     |
| Implementation          | `python software engineer` | Writes production Python under `rules/python/`                                             |
| Implementation          | `dotnet software engineer` | Writes production C# and .NET                                                              |
| Implementation          | `react software engineer`  | Writes production React and TypeScript                                                     |
| Implementation          | `data engineer`            | Implements approved data designs as native migrations, schema definitions, and data scripts |
| Implementation          | `shell script engineer`    | Writes bash scripts under `rules/shell/` together with their BATS tests                    |
| Operations              | `devops engineer`          | Builds Dockerfiles, CI/CD pipelines, and deployment configuration                          |
| Documentation           | `technical writer`         | Creates and maintains README, CHANGELOG, and guides                                        |
| Support                 | `rlm subcall agent`        | Extracts what is relevant from one chunk of a long context for the `rlm` skill             |

The two architects are consultants. They return a recommendation or a
specification and never coordinate other agents.

## The flow

1. **Brainstorm.** `superpowers:brainstorming` works out intent, requirements,
   and design with the user. The approved design is recorded under
   `docs/design/` through the `/design-docs-writer` skill. When the design needs
   an API contract or a data model, the brainstorm draws on the
   `api architect` and `data architect` as consultants.
2. **Plan.** `superpowers:writing-plans` turns the spec into a plan of small,
   independent tasks.
3. **Implement.** `superpowers:subagent-driven-development` runs the plan with
   a fresh subagent per task, and the matching specialist takes the implementer
   seat: Go tasks go to the `go software engineer`, migrations to the
   `data engineer`, and so on. `superpowers:executing-plans` is the inline
   alternative when the main session implements the plan itself.
4. **Review.** `superpowers:requesting-code-review` checks the work against the
   plan and the spec before it merges.
5. **Finish.** `superpowers:finishing-a-development-branch` decides how the
   branch integrates: merge, pull request, or keep it open.

## Going straight to a specialist

A narrow request with a known owner skips the flow and goes to one agent:

- "Write a Dockerfile and GitHub Actions workflow for this Go service" goes to
  the `devops engineer`.
- "Add a migration that creates the invoices table" goes to the
  `data engineer`.
- "Update the README for the new CLI flag" goes to the `technical writer`.

If the request changes behavior or adds functionality, start at brainstorming
instead.

## Worked example

```text
User: "Build a user management REST API in Go"
1. superpowers:brainstorming settles scope, auth, and data shape; the api
   architect drafts the OpenAPI contract and the data architect the schema
2. /design-docs-writer records the approved design under docs/design/
3. superpowers:writing-plans breaks the design into tasks
4. superpowers:subagent-driven-development runs them: go software engineer
   implements handlers and their black-box tests, data engineer writes
   migrations, devops engineer adds the Dockerfile and CI
5. superpowers:requesting-code-review, then finishing-a-development-branch
```

## Library documentation (Context7)

Agents that design or write against third-party libraries fetch current
documentation from the Context7 MCP server instead of relying on training
data. The always-on `rules/library-docs.md` rule carries this to every
subagent: resolve the library with `mcp__context7__resolve-library-id`, query
the APIs, configuration, or version it needs with `mcp__context7__query-docs`,
and deliver artifacts that follow the repository's pinned versions and
conventions.

## Respect existing projects

Brownfield work starts by reading what exists. Brainstorming scans the codebase
to learn the language, stack, and CI/CD before proposing anything. Preserve
working CI/CD, infrastructure, and patterns; prefer incremental improvements
over rewrites; and give any necessary change a migration path.

## The rlm subcall utility

The `rlm subcall agent` is the sub-LLM behind the `rlm` skill's `llm_query`.
It receives one chunk of a long context, usually as a file path, plus a query,
and returns only what is relevant as a compact structured result. The `/rlm`
skill invokes it; it is not normally called directly.
