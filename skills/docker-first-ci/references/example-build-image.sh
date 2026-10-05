#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

IMAGE_NAME="${IMAGE_NAME:-ghcr.io/example-org/example-service}"
E2E_COMPOSE_FILE="${E2E_COMPOSE_FILE:-${PROJ_ROOT}/tests/docker-compose.yaml}"

BUILD_VER="${BUILD_VER:-$(git -C "${PROJ_ROOT}" describe --tags --abbrev=0 2>/dev/null || printf "dev")}"
BUILD_COMMIT="${BUILD_COMMIT:-$(git -C "${PROJ_ROOT}" rev-parse --short HEAD 2>/dev/null || printf "unknown")}"
BUILD_DATE="${BUILD_DATE:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
IMAGE_TAG="${IMAGE_TAG:-${BUILD_VER}}"

validate_args() {
    if [ -z "${IMAGE_TAG}" ]; then
        printf "ERROR: IMAGE_TAG must not be empty\n" >&2
        return 1
    fi

    return 0
}

build() {
    # --no-cache and --pull make every gate run against fresh layers and the
    # latest base image; a cached pass could hide a new vulnerability.
    if ! docker build --rm --no-cache --pull --progress=plain \
        --file "${SCRIPT_DIR}/Dockerfile" \
        --build-arg BUILD_VER="${BUILD_VER}" \
        --build-arg BUILD_COMMIT="${BUILD_COMMIT}" \
        --build-arg BUILD_DATE="${BUILD_DATE}" \
        --target final \
        --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
        "${PROJ_ROOT}"; then
        printf "ERROR: the build failed; fix the failing gate\n" >&2
        return 1
    fi

    return 0
}

# Runs on every exit, pass or fail, so no containers or volumes are left behind.
cleanup() {
    docker compose -f "${E2E_COMPOSE_FILE}" down --volumes --remove-orphans >/dev/null 2>&1 || true

    return 0
}

e2e_tests() {
    # The compose file reads this, so the tests run the image just built.
    export EXAMPLE_SERVICE_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

    # Dependencies are gated by service_healthy in the compose file; no sleeps.
    if ! docker compose -f "${E2E_COMPOSE_FILE}" up --build --exit-code-from e2e_tests e2e_tests; then
        printf "ERROR: the e2e tests failed\n" >&2
        return 1
    fi

    return 0
}

main() {
    if ! validate_args; then
        return 1
    fi

    trap cleanup EXIT

    if ! build; then
        return 1
    fi

    if ! e2e_tests; then
        return 1
    fi

    return 0
}

main "$@"
