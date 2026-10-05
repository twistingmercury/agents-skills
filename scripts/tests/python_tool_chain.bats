#!/usr/bin/env bats

load 'fake_tools'

setup() {
    SCRIPT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/python_tool_chain.sh"
    export FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
    export FAKE_LOG="${BATS_TEST_TMPDIR}/calls.log"
    : > "${FAKE_LOG}"
    make_fake_tool uv
}

@test "installs the six tools in order" {
    run_script

    [ "${status}" -eq 0 ]
    expected="tool install ruff
tool install mypy
tool install pytest
tool install bandit
tool install pyright
tool install sqlfluff"
    [ "$(cat "${FAKE_LOG}")" = "${expected}" ]
}

@test "never installs debugpy" {
    run_script

    [ "${status}" -eq 0 ]
    log_lacks 'debugpy'
}

@test "fails naming uv when uv is missing" {
    rm "${FAKE_BIN}/uv"

    run_script

    [ "${status}" -eq 1 ]
    output_has "ERROR: uv is required; see the install table in README.md"
}

@test "stops at the first failing install" {
    export FAIL_ON="mypy"

    run_script

    [ "${status}" -eq 1 ]
    output_has "ERROR: failed to install mypy"
    log_has 'ruff'
    log_lacks 'pytest'
    log_lacks 'sqlfluff'
}
