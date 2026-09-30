# Agent delegation

**Main Claude coordinates. Specialists implement. For non-trivial tasks, delegate to the appropriate specialist rather than implementing directly.**

## Delegation table

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

## Constraints

- Architects and reviewers are **consultants** — they return recommendations; they do not coordinate
- Main Claude creates coordination plans and delegates; specialists execute
- Specialists may stage and commit their own work (`git add`, `git commit`); nobody but the user pushes
