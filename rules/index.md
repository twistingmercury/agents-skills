# Rules index

Path-scoped rules load only when Claude reads, writes, or edits a matching file. Before creating the first file of a kind in a project, read its rule:

- Shell script (`*.sh`, `*.bash`): `~/.claude/rules/shell/shell.md`
- BATS test (`*.bats`): `~/.claude/rules/shell/bats.md`
- Go source (`*.go`): `~/.claude/rules/go/go.md`
- Go architecture (`*.go`, `go.mod`): `~/.claude/rules/go/architecture.md`
- Python source (`*.py`): `~/.claude/rules/python/python.md`
- React/TypeScript source (`*.ts`, `*.tsx`): `~/.claude/rules/react/react.md`
- Dockerfile: `~/.claude/rules/docker.md`
