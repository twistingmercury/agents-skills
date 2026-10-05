#!/usr/bin/env bash

set -euo pipefail

# One entry per tool; adding a tool is a one-line change. debugpy is left out
# on purpose: it stays a per-project dependency.
PYTHON_TOOLS=(ruff mypy pytest bandit pyright sqlfluff)

validate_args() {
    if ! command -v uv >/dev/null 2>&1; then
        printf "ERROR: uv is required; see the install table in README.md\n" >&2
        return 1
    fi

    return 0
}

# A plain "uv tool install" on an installed tool is a no-op that exits 0, so
# re-runs are safe without --force.
install_tool() {
    local name="${1}"

    printf "installing %s...\n" "${name}"
    if ! uv tool install "${name}"; then
        printf "ERROR: failed to install %s\n" "${name}" >&2
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

    for name in "${PYTHON_TOOLS[@]}"; do
        if ! install_tool "${name}"; then
            return 1
        fi
    done

    return 0
}

main "$@"
