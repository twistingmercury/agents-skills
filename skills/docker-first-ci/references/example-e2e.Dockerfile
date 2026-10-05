# Artifact shape: the e2e runner installs the one artifact that was just built.
# Build it with the repo root as context, and give it its own
# tests/e2e/Dockerfile.dockerignore that lets dist/ in; the build Dockerfile's
# .dockerignore keeps dist/ out of that build's context.

# A test runner is a single stage; there is nothing to separate from it.
FROM alpine:3.22.1 AS final

RUN apk add --no-cache bash

# build/build.sh passes the exact file it just built, relative to dist/. Naming
# one file means a stale artifact left in dist/ can never be tested. The check
# runs first because an empty value would make COPY take the whole directory.
ARG ARTIFACT
RUN test -n "${ARTIFACT}" || { echo "ARTIFACT build arg is required" >&2; exit 1; }
COPY --chmod=0755 dist/${ARTIFACT} /usr/local/bin/example-tool

COPY --chmod=0755 tests/e2e/ /e2e/

WORKDIR /e2e

# Numeric id, so the suite runs unprivileged like a real user of the tool.
USER 65532:65532

CMD ["bash", "/e2e/run.sh"]
