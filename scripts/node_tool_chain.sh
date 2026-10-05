#!/usr/bin/env bash

set -euo pipefail

# One entry per tool; adding a tool is a one-line change.
NODE_TOOLS=(markdownlint-cli @mermaid-js/mermaid-cli)

validate_args() {
    if ! command -v npm >/dev/null 2>&1; then
        printf "ERROR: npm is required; see the install table in README.md\n" >&2
        return 1
    fi

    return 0
}

# The usual failure is an unwritable global prefix, so say how to fix it.
install_tool() {
    local name="${1}"

    printf "installing %s...\n" "${name}"
    if ! npm install -g "${name}"; then
        printf "ERROR: failed to install %s\n" "${name}" >&2
        printf "hint: if the npm global prefix is not writable, run: npm config set prefix ~/.local\n" >&2
        return 1
    fi

    printf "done\n"
    return 0
}

main() {
    local name

    if ! validate_args; then
        return 1
    fi

    for name in "${NODE_TOOLS[@]}"; do
        if ! install_tool "${name}"; then
            return 1
        fi
    done

    return 0
}

main "$@"
