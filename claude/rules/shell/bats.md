---
paths:
  - "**/*.bats"
---

# BATS tests

## Layout

- One file per script: `tests/bats/test-<script-name>.bats`, with `bats-support` and `bats-assert` vendored in `tests/bats/test_helper/`. A repo with existing BATS tests keeps its own layout and helpers.
- Order: shebang, `load` lines, globals, `setup`, `teardown`, helpers, then tests grouped happy path, error paths, edge cases.
- Test name: `"<component> <action> - <expected behavior>"`. One behavior per test.

## Black-box

- Execute the script with `run "${SCRIPT_PATH}"`; never `source` it. Assert only exit status, output, and file or Docker state checked from outside.
- Cover minimal and full valid input; missing input, invalid data, failed prerequisites; empty input, special characters, a repeated run.

## Assertions

- Use `bats-assert` (`assert_success`, `assert_failure`, `assert_output`, `assert_line`, `assert_equal`, `refute_*`), not bare `[ "${status}" -eq 0 ]`.
- Assert the exact exit code when the script defines one (`assert_failure 2`), and the error message with it.
- Match text with `--partial` or `--regexp`; `assert_line --index N` only when order is part of the contract.
- File state: `assert [ -f "${file}" ]`.
- A domain check is an `assert_<thing>` function that prints what differed and returns 1.

## Isolation

- All file state lives under `TEST_DIR`. Point the script there with exported env vars (`CONFIG_DIR`, `OUTPUT_DIR`, `HOME`).
- Do not save and restore env vars or the working directory: each test runs in its own process.
- Fixtures sit in `${BATS_TEST_DIRNAME}/fixtures`; `setup` copies them into `TEST_DIR`.
- Tests pass in any order and in parallel (`bats --jobs`).

## Docker

- Real Docker resources, no mocks. No availability checks or `skip` for `docker`, `jq`, `yq`.
- Name each resource `test-<kind>-$$`, exported as the variable the script reads (`VOLUME_NAME`, `CONTAINER_NAME`, `COMPOSE_PROJECT_NAME`).
- `teardown` removes every resource, including ones a test body created, before `rm -rf "${TEST_DIR}"`, each ending `2>/dev/null || true`: `docker rm -f`, `docker volume rm`, `docker network rm`, `docker rmi`, `docker compose -p "${COMPOSE_PROJECT_NAME}" down -v`.
- Wait for a container with a helper that polls `docker inspect` under a timeout (default 30s).

## Checks

- `bats` and `shellcheck` both run clean on the test files.
- A failure caused by the script is a script bug: report it, never weaken the test.
- Inside tests: `printf` not `echo`, `[ ]` not `[[ ]]`, `grep -E` not `-P`.

## Template

```bash
#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../scripts/backup.sh"

setup() {
    export TEST_DIR="${BATS_TEST_TMPDIR}/test-$$"
    export BACKUP_DIR="${TEST_DIR}/backups"
    mkdir -p "${BACKUP_DIR}"
}

teardown() {
    rm -rf "${TEST_DIR}"
}

@test "backup with missing volume - fails naming the volume" {
    export VOLUME_NAME="missing-$$"

    run "${SCRIPT_PATH}"

    assert_failure
    assert_output --partial "${VOLUME_NAME}"
}
```
