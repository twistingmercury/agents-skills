#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

OUTPUT_DIR="${OUTPUT_DIR:-${PROJ_ROOT}/dist}"
# The one file under OUTPUT_DIR that the e2e container installs and tests.
ARTIFACT="${ARTIFACT:-amd64/linux/example-tool}"
E2E_IMAGE="${E2E_IMAGE:-example-tool-e2e:local}"

BUILD_VER="${BUILD_VER:-$(git -C "${PROJ_ROOT}" describe --tags --abbrev=0 2>/dev/null || printf "dev")}"
BUILD_COMMIT="${BUILD_COMMIT:-$(git -C "${PROJ_ROOT}" rev-parse --short HEAD 2>/dev/null || printf "unknown")}"
BUILD_DATE="${BUILD_DATE:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

validate_args() {
    if [ -z "${OUTPUT_DIR}" ]; then
        printf "ERROR: OUTPUT_DIR must not be empty\n" >&2
        return 1
    fi

    return 0
}

# The export only adds files, so an old build left in place could be mistaken
# for the new one. Start from an empty directory every time.
clean_output() {
    if ! rm -rf "${OUTPUT_DIR}"; then
        printf "ERROR: could not remove %s\n" "${OUTPUT_DIR}" >&2
        return 1
    fi

    if ! mkdir -p "${OUTPUT_DIR}"; then
        printf "ERROR: could not create %s\n" "${OUTPUT_DIR}" >&2
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
        --target export \
        --output "type=local,dest=${OUTPUT_DIR}" \
        "${PROJ_ROOT}"; then
        printf "ERROR: the build failed; fix the failing gate\n" >&2
        return 1
    fi

    return 0
}

e2e_tests() {
    if [ ! -f "${OUTPUT_DIR}/${ARTIFACT}" ]; then
        printf "ERROR: the build did not produce %s/%s\n" "${OUTPUT_DIR}" "${ARTIFACT}" >&2
        return 1
    fi

    if ! docker build \
        --file "${PROJ_ROOT}/tests/e2e/Dockerfile" \
        --build-arg ARTIFACT="${ARTIFACT}" \
        --tag "${E2E_IMAGE}" \
        "${PROJ_ROOT}"; then
        printf "ERROR: could not build the e2e image\n" >&2
        return 1
    fi

    if ! docker run --rm "${E2E_IMAGE}"; then
        printf "ERROR: the e2e tests failed\n" >&2
        return 1
    fi

    return 0
}

main() {
    if ! validate_args; then
        return 1
    fi

    if ! clean_output; then
        return 1
    fi

    if ! build; then
        return 1
    fi

    if ! e2e_tests; then
        return 1
    fi

    return 0
}

main "$@"
