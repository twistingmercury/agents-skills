#!/usr/bin/env bash

set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SCRIPTS}/../.." && pwd)}"

RULE_SOURCE="${RULE_SOURCE:-${PROJ_ROOT}/claude/rules}"
RULES_DIR="${RULES_DIR:-${HOME}/.claude/rules}"
# RULES_DIR="${PROJ_ROOT}/.local/rules" #test target

main() {
	if [ ! -d "$RULES_DIR" ]; then
		printf "creating dir %s...\n" "$RULES_DIR"
		mkdir -p "$RULES_DIR"
	fi

	local -a installed
	mapfile -t installed < <(find "${RULES_DIR}" -mindepth 1 -maxdepth 1)

	for installedRule in "${installed[@]}"; do
		if [ -L "$installedRule" ] && [ ! -e "$installedRule" ]; then
			rm -f "$installedRule"
		fi
	done

	# Rules are top-level files as well as subject folders, so no -type d here.
	local -a rules
	mapfile -t rules < <(find "$RULE_SOURCE" -mindepth 1 -maxdepth 1)

	if ((${#rules[@]} == 0)); then
		printf "Error: no rule definitions were found in the directory %s\n" "$RULE_SOURCE"
		return 1
	fi

	for rule in "${rules[@]}"; do
		local name dst
		name="$(basename "$rule")"
		dst="${RULES_DIR}/${name}"

		rm -rf "$dst"
		cp -R "$rule" "$dst"
	done

	printf "Success: all rules installed.\n"
}

main "$@"
