---
paths:
  - "**/*.go"
  - "**/go.mod"
---

# Go architecture

## Dependency rule

- Source dependencies point inward: frameworks and drivers, then interface adapters, then use cases, then entities. Inner layers know nothing about outer ones.
- Inner layers declare the interfaces they need (ports); outer layers implement them (adapters).
- Pass plain data across boundaries. ORM entities, framework request types, and wire formats never reach the core.
- Organize by subdomain (a business capability), then by use-case slice. Top-level packages name capabilities, never layers or frameworks.
- The rule is fixed; the layer count is not. Collapse layers in small services and CLIs, and record that decision in an ADR.
- Design for observability and testability from the start.

## Packages

- The subdomain root package is the core: entities, value objects, domain errors, ports shared by two or more slices, and published events. Name it after the subdomain (`patterns.Pattern`, `patterns.Repository`), never `domain`; Go's ban on import cycles then keeps the core from importing its slices or adapters.
- Each use case is a slice subpackage: handler or command, use-case logic, and slice-only ports. Slices in one subdomain never import each other; shared behavior moves to the core. One or two use cases share a single slice package.
- Another subdomain may use only this one's slice entry points and published events, never its entities, ports, or adapters.
- Framework and driver types (`*gin.Context`, `pgx.Rows`, `sql.Null*`, generated protobuf) stay in adapters and are mapped at the boundary.
- Wire concrete adapters in the composition root under `cmd/`, with a thin `main`. Inject dependencies through constructors, never hidden globals.
- Generated API code lives in its own package; the slice handler maps it to use-case input.
- Enforce direction mechanically: `internal/` visibility plus a `depguard` rule in `golangci-lint`.
- Test use cases with in-memory fakes of their ports; test adapters against real dependencies.
- In existing code, enforce dependency direction within the current layout first, then migrate one subdomain at a time.
- Never add top-level `handlers`, `services`, or `repositories` packages.

## Layout

```text
cmd/<binary>/            composition root: thin main, wires adapters into slices
internal/
  <subdomain>/           package <subdomain>: the core
    <usecase>/           slice: handler or command, use case, slice-only ports
    postgres/            adapter implementing the core's ports
  platform/              config, db pool, telemetry, server
tests/                   integration/E2E support and fixtures
```

- Service: `cmd/server`. CLI: `cmd/cli`, where each slice's entry point is a command. Hybrid: both under `cmd/`, sharing subdomains; each binary wires only the slices it exposes.

## API style

- REST/OpenAPI: public API, CRUD-heavy domain, broad client compatibility, HTTP caching. Cost: over- and under-fetching.
- GraphQL: varied client data shapes, federation, subscription-style realtime. Cost: caching and operational complexity.
- gRPC: internal service-to-service calls, strict contracts, performance or streaming. Cost: weak browser ergonomics.
- Combine external REST or GraphQL with internal gRPC when both sets of needs apply.
- Settle the contract before implementing. Generate code where the contract benefits from strong typing.

## CLI

- Domain-oriented command tree.
- Explicit config injection; no hidden globals.
- Separate global flags from command-local flags.
- Output modes `json|table|yaml`, plus quiet and verbose.
- Stable exit code conventions.
