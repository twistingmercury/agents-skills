---
name: docker-first-ci
description: Implements and hardens Docker-first build, test, and release pipelines, where one build script runs the quality gates, the build, and the e2e tests inside containers for both local and CI runs. Covers artifact output (binaries, wheels) and image output (services), plus the gates for publishing images and cutting releases. Use when setting up or fixing CI/CD, moving checks into a Dockerfile, adding container-based e2e tests, publishing images to a registry, or hardening release workflows.
---

# Docker-First CI/CD

## Core pattern

Every project, whatever it produces:

- `build/build.sh` is the single entrypoint. Local builds and CI both run it.
- The Dockerfile's `build` stage runs the quality gates (lint, static analysis, vulnerability scan, unit tests) and only then compiles or packages. A failed gate fails the build.
- CI runs `build/build.sh` and nothing else for build and test.
- E2E tests run in a container against the exact thing that was just built.

## Requirements

- Docker with buildx (`docker build --output` for the artifact shape) and Compose (the image shape's e2e tests)
- `bash` and `git`: `build.sh` takes the version from the latest tag
- `shellcheck` and `bats`, when you add or change the build scripts (they follow `rules/shell/`)

Install instructions are in the README's local tools table of the repository that ships this skill.

## Choose the output shape

The two shapes are equals. Pick by what the project produces.

### Artifact output (binaries, wheels)

- A `scratch` stage named `export` holds only the files to ship. `docker build --target export --output type=local,dest=<dir>` writes them to the host. There is no runtime image.
- `build.sh` empties the output directory first, so a stale build cannot be mistaken for the new one.
- The e2e container is built with a build arg naming one file in the output directory, then installs or copies only that file. A stale file can never be picked up. It runs as an unprivileged numeric uid.
- Releases are a manual `workflow_dispatch` that takes a `tag` input and creates a draft release with checksums.

### Image output (services)

- The `final` stage is a runtime image: `FROM scratch` (or the smallest base that runs), the CA bundle, numeric `USER 65532:65532`, a `HEALTHCHECK` that calls the binary's own health flag, OCI labels from the build args, and the LICENSE under `/licenses`.
- The `build` stage uses `FROM --platform=${BUILDPLATFORM}` with `TARGETOS` and `TARGETARCH`, so it runs natively and cross-compiles.
- E2E runs the just-built image with Docker Compose: `pull_policy: never`, the image name set by an environment variable, dependencies gated by `depends_on: condition: service_healthy` (no sleeps), and teardown in an `EXIT` trap in `build.sh`.
- CI builds and tests, then pushes that exact tested image in a publish job gated to push events.

## Publishing checklist

Check every item before calling a pipeline done:

- [ ] Publish only on push events to protected branches, or on manual dispatch. Never on `pull_request`. Put the `if:` on the publish job itself.
- [ ] No `${{ ... }}` expression (branch name, tag, input) inside a `run:` body. Pass it through `env:` and read it as a shell variable.
- [ ] Validate a tag input against `^v[0-9]+\.[0-9]+\.[0-9]+$` before using it.
- [ ] Top-level `permissions: contents: read`. Grant `packages: write` or `contents: write` only on the job that needs it.
- [ ] `persist-credentials: false` on every checkout that does not push.
- [ ] Pin tooling base images to version plus digest (`image:1.2.3@sha256:<digest>`). Pin action majors. Pin installed tool versions; never `@latest`.
- [ ] Releases are started by hand and land as drafts. Verify the built binary reports the tag before packaging.
- [ ] Run `docker compose config --quiet` on compose files in CI. Add path filters to triggers when the repo has non-build content.
- [ ] Failed tests block publication: the publish steps come after `build.sh` in the same job.

## Implementation workflow

1. Inspect what exists: build entrypoints (`build.sh`, `Makefile`, `Dockerfile`), CI and CD workflows, and how tests are orchestrated.
2. Pick the output shape, then copy the matching reference files.
3. Move the quality gates into the Dockerfile's `build` stage. Follow `rules/docker.md` for stage names, build args, and labels.
4. Make `build.sh` the one entrypoint. Follow `rules/shell/shell.md`.
5. Reduce CI to checkout, then `build.sh`. Add the publish job (image shape) or the release workflow (artifact shape).
6. Walk the publishing checklist.
7. Validate: local and CI builds behave the same, a failing gate fails the build, and published tags match what was tested.

## Optional: separate CD workflow

Use the CI-to-CD handoff only when deployment must be a separate, separately approvable workflow. CI saves the tested image as an artifact, and a `workflow_run` workflow loads and pushes it. CD must never rebuild. The default for image output is the publish job in CI.

## Rules

1. Keep policy (which branch, tag, or approval publishes) apart from mechanism (the commands that do it).
2. Keep changes minimal. Preserve existing release intent; patch only what enforces the flow and the gates.
3. Preserve published documentation:
   - Before editing generated documentation or diagrams, inspect Git history and upstream or remote-tracking refs.
   - Never edit a published standalone document; preserve it and create the next snake_case version with synchronized `Version`, `Date`, and `Notes` metadata.
   - If publication status is uncertain, treat committed documents as published.
   - Canonical living configuration and documentation files that require fixed paths may be updated in place.

## References

Read these when you need a concrete shape to copy, not before:

- `references/example-artifact.Dockerfile`: read for the artifact shape; gated `build` stage plus the `scratch` `export` stage.
- `references/example-image.Dockerfile`: read for the image shape; gated `build` stage plus the `scratch` `final` runtime stage.
- `references/example-build-artifact.sh`: read for the artifact shape's `build.sh`; cleans the output directory, builds, runs e2e.
- `references/example-build-image.sh`: read for the image shape's `build.sh`; builds a tagged image, runs compose e2e with an `EXIT` trap.
- `references/example-e2e.Dockerfile`: read when writing the artifact shape's e2e container (single named artifact, numeric uid).
- `references/example-e2e-compose.yaml`: read when writing the image shape's e2e compose file (healthchecks, `service_healthy`, `pull_policy: never`).
- `references/example-ci.yaml`: read when writing the CI workflow, including the image shape's publish job and tag scheme.
- `references/example-release.yaml`: read when writing a manual, draft-only release workflow for the artifact shape.
- `references/example-cd.yaml`: read only for the optional separate CD workflow.
