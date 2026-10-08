# Agent delegation

**The main session runs brainstorming, planning, review, and integration itself through superpowers. It hands implementation to the specialist whose language or domain matches, and may seat that specialist as the implementer in `superpowers:subagent-driven-development`.**

## Delegation table

| Task                                     | Delegate To                 |
| ---------------------------------------- | --------------------------- |
| Shell scripts                            | `shell script engineer`     |
| Go code/services                         | `go software engineer`      |
| Python code/services                     | `python software engineer`  |
| C# / .NET code                           | `dotnet software engineer`  |
| React / TypeScript front ends            | `react software engineer`   |
| API specs                                | `api architect`             |
| Documentation                            | `technical writer`          |
| DevOps/Docker/CI                         | `devops engineer`           |
| Data schema/models                       | `data architect`            |
| Database migrations and data scripts     | `data engineer`             |
| Create or update README.md               | `/readme-writer` skill      |
| Create or update architectural documents | `/design-docs-writer` skill |

## When to delegate

The table says who to hand work to. This section says whether to hand it off at all.

Delegate an implementation task when any of these is true:

- It touches about 3 or more files
- It needs a write-test, run-test, fix loop
- It is a task from a plan running under `superpowers:subagent-driven-development`
- It can run in parallel with other independent work

Otherwise do it inline in the main session. The path-scoped language rules load
when the main session touches a matching file, so inline work follows the same
standards. When in doubt, go inline; delegating later costs less than
re-verifying a needless handoff.

This applies to the language engineers and the `devops engineer`. The architects
are consultants and the `technical writer` and skills are already scoped by
their own triggers.

## Constraints

- The API and data architects are **consultants**: they return recommendations and do not coordinate
- Specialists execute the task they are handed and return
- Specialists may run any git command that neither destroys nor rewrites work: read-only commands, `git fetch`, `git pull`, and staging, committing, and tagging their own work. Nobody but the user runs `git push`
- Design specs from `superpowers:brainstorming` go under `docs/design/` via the `/design-docs-writer` skill, not `docs/superpowers/specs/`; brainstorming honors this as a user preference
