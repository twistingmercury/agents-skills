#!/usr/bin/env bats

load 'fake_tools'

setup() {
    SCRIPT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/go_tool_chain.sh"
    export FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
    export FAKE_LOG="${BATS_TEST_TMPDIR}/calls.log"
    export FAKE_GOPATH="${BATS_TEST_TMPDIR}/gopath"
    : > "${FAKE_LOG}"
    make_fake_tool go
}

@test "installs the four tools in order" {
    run_script

    [ "${status}" -eq 0 ]
    expected="install golang.org/x/tools/cmd/goimports@latest
install golang.org/x/vuln/cmd/govulncheck@latest
install github.com/securego/gosec/v2/cmd/gosec@latest
install golang.org/x/tools/gopls@latest"
    [ "$(cat "${FAKE_LOG}")" = "${expected}" ]
}

@test "prints one installing and done line per tool" {
    run_script

    [ "${status}" -eq 0 ]
    output_has 'installing goimports...'
    [ "$(printf '%s\n' "${output}" | grep -cx 'done')" -eq 4 ]
}

@test "fails naming go when go is missing" {
    rm "${FAKE_BIN}/go"

    run_script

    [ "${status}" -eq 1 ]
    output_has "ERROR: go is required; see the install table in README.md"
}

@test "stops at the first failing install" {
    export FAIL_ON="govulncheck"

    run_script

    [ "${status}" -eq 1 ]
    output_has "ERROR: failed to install govulncheck"
    log_has 'goimports'
    log_lacks 'gosec'
    log_lacks 'gopls'
}

@test "notes the GOPATH bin directory when it is not on PATH" {
    run_script

    [ "${status}" -eq 0 ]
    output_has "${FAKE_GOPATH}/bin"
    output_has "not on your PATH"
}

@test "stays quiet about GOPATH when its bin directory is on PATH" {
    export SCRIPT_PATH_DIRS="${FAKE_GOPATH}/bin:${FAKE_BIN}"

    run_script

    [ "${status}" -eq 0 ]
    output_lacks "not on your PATH"
}
