#!/usr/bin/env bats

load 'fake_tools'

setup() {
    SCRIPT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/node_tool_chain.sh"
    export FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
    export FAKE_LOG="${BATS_TEST_TMPDIR}/calls.log"
    : > "${FAKE_LOG}"
    make_fake_tool npm
}

@test "installs the two tools in order" {
    run_script

    [ "${status}" -eq 0 ]
    expected="install -g markdownlint-cli
install -g @mermaid-js/mermaid-cli"
    [ "$(cat "${FAKE_LOG}")" = "${expected}" ]
}

@test "fails naming npm when npm is missing" {
    rm "${FAKE_BIN}/npm"

    run_script

    [ "${status}" -eq 1 ]
    output_has "ERROR: npm is required; see the install table in README.md"
}

@test "names the failing tool and hints at the npm prefix" {
    export FAIL_ON="markdownlint-cli"

    run_script

    [ "${status}" -eq 1 ]
    output_has "ERROR: failed to install markdownlint-cli"
    output_has "npm config set prefix ~/.local"
    log_lacks 'mermaid'
}
