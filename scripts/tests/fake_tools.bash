# Helpers shared by the tool chain tests: a fake base tool that logs its
# arguments instead of installing anything.

# Build ${FAKE_BIN}/<name>. It appends its arguments to ${FAKE_LOG}, prints
# ${FAKE_GOPATH} for "env GOPATH", and exits 1 when its arguments contain
# ${FAIL_ON}.
make_fake_tool() {
    local tool_name="${1}"

    mkdir -p "${FAKE_BIN}"
    printf '#!%s\n' "$(command -v bash)" > "${FAKE_BIN}/${tool_name}"
    cat >> "${FAKE_BIN}/${tool_name}" <<'BODY'
if [ "${1:-}" = "env" ]; then
    printf '%s\n' "${FAKE_GOPATH:-}"
    exit 0
fi

printf '%s\n' "$*" >> "${FAKE_LOG}"
case "$*" in
    *"${FAIL_ON:-@@never@@}"*) exit 1 ;;
esac
exit 0
BODY
    chmod +x "${FAKE_BIN}/${tool_name}"
}

# Run ${SCRIPT} with PATH limited to ${SCRIPT_PATH_DIRS} (default: the fake
# bin only), so nothing real can be reached. PATH is changed for the script
# alone; the test body keeps its own tools.
run_script() {
    PATH="${SCRIPT_PATH_DIRS:-${FAKE_BIN}}" run "$(command -v bash)" "${SCRIPT}"
}

# Assert that ${output} contains the fixed string.
output_has() {
    printf '%s\n' "${output:-}" | grep -qF -- "${1}"
}

# Assert that the fake tool's log contains the fixed string.
log_has() {
    grep -qF -- "${1}" "${FAKE_LOG}"
}

# Assert that the fake tool's log lacks the fixed string. A bare "!" would
# not fail a bats test.
log_lacks() {
    if grep -qF -- "${1}" "${FAKE_LOG}"; then
        printf 'log unexpectedly contains: %s\n' "${1}" >&2
        return 1
    fi

    return 0
}

# Assert that ${output} lacks the fixed string.
output_lacks() {
    if output_has "${1}"; then
        printf 'output unexpectedly contains: %s\n' "${1}" >&2
        return 1
    fi

    return 0
}
