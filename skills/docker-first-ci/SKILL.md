---
name: docker-first-ci
description: Implements and hardens Docker-first CI/CD pipelines in repository workflows: CI builds and tests the image once, and CD promotes that exact immutable artifact without rebuilding. Use when setting up or fixing CI/CD, enforcing Docker build-and-test in CI, gating CD on trusted events, or publishing and promoting immutable images.
---

# Docker-First CI/CD Implementation

## Overview

Implement Docker-first CI/CD so CI builds and validates the image once, then CD promotes that exact immutable output.

## Implementation Workflow

1. Inspect current implementation:

- Build entrypoints (`build.sh`, `Makefile`, `Dockerfile`)
- CI and CD workflow files
- Test orchestration (compose/test runners)

2. Implement CI:

- Build runtime image from Dockerfile.
- Run quality gates and unit tests in the build container stage.
- Run integration or E2E tests before publish.
- Fail on any gate failure.

3. Implement CI-to-CD handoff:

- Publish image/artifact once in CI.
- Pass digest/tag/commit metadata forward.
- Require CD to resolve and promote CI output only.
- Do not rebuild app image in CD.

4. Implement release gates:

- Gate CD on trusted events only (push/tag/approval per policy).
- Keep branch/tag policy explicit (for example `latest` only from `main`).
- Block PR-originated publish paths unless explicitly required.

5. Validate end to end:

- Confirm local and CI build/test behavior match.
- Confirm CD runs only under policy gates.
- Confirm failed tests prevent artifact publication.
- Confirm published tags/digests match CI outputs.

## Rules

1. Separate CI and CD responsibilities:

- CI: build, test, scan, package, publish immutable artifact.
- CD: fetch artifact, deploy/promote, verify, rollback/promote decision.

2. Keep policy and mechanism distinct:

- Policy: branch/tag/approval and promotion rules.
- Mechanism: concrete actions, commands, and artifact transport.

3. Keep changes minimal:

- Pin action/tool versions where practical.
- Avoid environment-dependent branching in build scripts.
- Preserve existing release intent; patch only what enforces the Docker-first flow and gates.

4. Preserve published documentation:

- Before editing generated documentation or diagrams, inspect Git history and upstream or remote-tracking refs.
- Never edit a published standalone document; preserve it and create the next snake_case version with synchronized `Version`, `Date`, and `Notes` metadata.
- If publication status is uncertain, treat committed documents as published.
- Canonical living configuration and documentation files that require fixed paths may be updated in place.

## References

Read these when you need a concrete shape to copy, not before:

- `references/example-build.sh`: build entrypoint shared by local and CI builds.
- `references/example-Dockerfile`: multi-stage image with quality gates in the build stage.
- `references/example-ci.yaml`: CI workflow that builds, tests, and publishes once.
- `references/example-cd.yaml`: CD workflow gated on a successful CI run.
