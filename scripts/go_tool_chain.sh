#!/usr/bin/env bash

set -euo pipefail

# One entry per tool; adding a tool is a one-line change.
GO_TOOLS=(
    "golang.org/x/tools/cmd/goimports@latest"
    "golang.org/x/vuln/cmd/govulncheck@latest"
    "github.com/securego/gosec/v2/cmd/gosec@latest"
    "golang.org/x/tools/gopls@latest"
)

validate_args() {
    if ! command -v go >/dev/null 2>&1; then
        printf "ERROR: go is required; see the install table in README.md\n" >&2
        return 1
    fi

    return 0
}

# The tool name is the last path element before the @version suffix.
tool_name() {
    local tool_path="${1}"
    local without_version="${tool_path%@*}"

    printf "%s" "${without_version##*/}"
    return 0
}

install_tool() {
    local tool_path="${1}"
    local name
    name="$(tool_name "${tool_path}")"

    printf "installing %s...\n" "${name}"
    if ! go install "${tool_path}"; then
        printf "ERROR: failed to install %s\n" "${name}" >&2
        return 1
    fi

    printf "done\n"
    return 0
}

is_on_path() {
    local directory="${1}"

    case ":${PATH}:" in
        *":${directory}:"*) return 0 ;;
    esac

    return 1
}

note_gopath_bin() {
    local gopath_bin
    gopath_bin="$(go env GOPATH)/bin"

    if is_on_path "${gopath_bin}"; then
        return 0
    fi

    printf "NOTE: %s is not on your PATH; add it to use the installed tools\n" "${gopath_bin}"
    return 0
}

main() {
    local tool_path

    if ! validate_args; then
        return 1
    fi

    for tool_path in "${GO_TOOLS[@]}"; do
        if ! install_tool "${tool_path}"; then
            return 1
        fi
    done

    note_gopath_bin
    return 0
}

main "$@"
