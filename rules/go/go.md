---
paths:
  - "**/*.go"
---

# Go

## API design

- No stutter in exported names: `agent.Repository`, not `agent.AgentRepository`.
- Define an interface in the package that consumes it, not the one that implements it.
- Document exported APIs with concise godoc comments.

## Code shape

- Target the version in the module's `go` directive and use every idiom it allows: `slices`, `maps`, `iter`, range-over-func, range over ints, the `min`/`max` built-ins.
- Use `slices.Backward`, `slices.Contains`, `slices.Insert`, and `maps.Keys` instead of hand-written loops.
- Prefer recent stable Go versions for their security and runtime improvements.
- Past about 30 lines, split a function along its seams (collect, validate, decode).
- When a callback needs outer state, return it from a named function: `fs.WalkDir(fsys, root, copyTo(dest))`.
- Never pass a function call as an argument: call it, assign the result to a named variable, and pass the variable. A getter passed to a format call counts too (`repo.Root()` inside `fmt.Errorf`). Exempt: type conversions and built-ins (`string(b)`, `len(s)`, `max(a, b)`), `context.Background()` and `os.Environ()`, functions that return a callback (`copyTo(dest)` above), and chained builders (`lipgloss.NewStyle().Bold(true)`).

## Errors, concurrency, performance

- Wrap with `%w` when adding context to an error.
- Use channels for coordination and mutexes for shared mutable state.
- Give every goroutine a way to end, and wait for it with `sync.WaitGroup` or `errgroup.Group`.
- Optimize only after measuring: benchmark (`-bench`) or profile (`pprof`) first.

## Testing

- Unit tests sit beside the code in `*_test.go`; benchmarks go in separate `*_benchmark_test.go` files.
- Assert with `github.com/stretchr/testify`: `require` for preconditions that make the rest of the test meaningless, `assert` for every other check. Convert stdlib-style assertions in tests you touch.
- Use table-driven tests for behavior matrices, with `t.Run` subtests and `t.Helper` in helpers.
- Call `t.Parallel()` in independent tests.
- Fuzz parsers, decoders, and validators that take untrusted input.
- A bug fix ships with a test that reproduces the bug, written before or alongside the fix.
- Coverage is a signal, not a target; cover critical paths first.

## Security and dependencies

- Use `crypto/rand` for cryptographic randomness.
- Read secrets from env vars or a secret manager, never from source. Keep secrets and sensitive identifiers out of logs.
- Prefer the standard library; judge a new dependency on maintenance, security, and API stability.
- Keep `go.mod` and `go.sum` tidy.
- Use `replace` only for local development.
- Put non-public packages under `internal/`.

## Checks after any change

- If the project defines its own gates (Makefile targets, `CLAUDE.md` commands, a Docker build), run those instead of this list.
- Otherwise run, in order: `goimports -w .`, `golangci-lint run`, `govulncheck ./...`, `gosec ./...`, `go vet ./...`, `go test ./...`, `go test -race ./...`.
- Skip no step, and read each tool's output in full.
- Fix root causes, then rerun the whole sequence.
- Work is not complete while any step fails.
