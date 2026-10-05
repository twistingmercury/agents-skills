---
paths:
  - "**/Dockerfile"
  - "**/Dockerfile.*"
  - "**/*.dockerfile"
---

# Dockerfiles

## Stages

- Always multi-stage: a stage named `build`, then a runtime stage named `final` that holds only the artifact and the CA bundle.
- `final` uses the smallest base that runs the artifact; a static binary gets `scratch`.
- A build that only exports files (binaries, wheels) has no runtime image: it ends in a `scratch` stage named `export` instead of `final`. A test runner with nothing to separate may be a single stage named `final`.
- Pin base images to a version tag, and tooling images to the version plus its digest (`image:1.2.3@sha256:<digest>`); never `latest` or a bare variant such as `golang:alpine`.
- Install packages before declaring the build-metadata `ARG`s: `BUILD_DATE` changes on every build and invalidates each `RUN` after it.

## Build metadata

- Three build args, always named `BUILD_VER`, `BUILD_COMMIT`, `BUILD_DATE`; redeclare them in every stage that uses them.
- Compile them into the artifact and stamp them on `final` as the OCI labels `org.opencontainers.image.version`, `.revision`, and `.created`.

## Runtime and security

- Run as non-root with numeric `USER 65532:65532`; `scratch` has no `/etc/passwd` to resolve a name. Omit it only when the process needs root.
- No secrets and no environment values in the image. Declare each runtime setting in `final` as an empty `ENV NAME=""`; the value arrives at run time.
- `EXPOSE` only the ports the process listens on.
