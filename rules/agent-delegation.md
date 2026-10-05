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

## Constraints

- The API and data architects are **consultants**: they return recommendations and do not coordinate
- Specialists execute the task they are handed and return
- Specialists may stage, commit, and tag their own work (`git add`, `git commit`, `git tag`); nobody but the user pushes
- Design specs from `superpowers:brainstorming` go under `docs/architecture/` via the `/design-docs-writer` skill, not `docs/superpowers/specs/`; brainstorming honors this as a user preference
