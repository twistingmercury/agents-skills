---
paths:
  - "**/*.sh"
  - "**/*.bash"
---

# Shell scripts

## Structure

- Executables follow the skeleton's section order.
- Header is `#!/usr/bin/env bash` then `set -euo pipefail`.
- Configure through named environment variables with `${VAR:-default}`; no flag parsing.
- `main` calls `validate_args` first, then only orchestrates: call a step, check it with `if ! step; then`.
- Functions `return`, never `exit`; the status of `main` is the exit code.
- Libraries are sourced only: no shebang, `set`, `SCRIPT_DIR`, `PROJ_ROOT`, or `main`, and sourcing runs nothing. Open with `# Library:`, `# Description:`, `# Usage:` comment lines.
- Prefix every library function with the file name, hyphens to underscores: `file-helpers.sh` defines `file_helpers::exists`.
- Name files in lowercase `snake_case` or `hyphen-case`.

## Naming and quoting

- Globals `SCREAMING_SNAKE_CASE`, locals `snake_case`, constants `readonly`.
- Expand every variable as `"${var}"`, braces and quotes, including `"${1}"`.
- Declare locals at the top of the function, parameters first: `local file_path="${1}"`.
- Declare, then assign command output: `local count`, then `count=$(...)`.
- Descriptive names (`input_file`, `line_count`); no single letters or abbreviations.
- Indent 4 spaces; define functions as `name() {`.

## Portability

- Bash shebang, POSIX constructs: `printf` never `echo`, `$(...)` never backticks, `[ ]` with `=` never `[[ ]]` or `==`. `local`, `source`, and `::` names are fine; arrays only when nothing portable works.
- Target macOS (BSD) and Linux (GNU): `grep -E` never `-P`; `find` always with `-type`; no `readlink -f` or GNU-only `date`; keep `sed` simple or use `awk`.
- Fall back across flavors: `stat -f%z "${file}" 2>/dev/null || stat -c%s "${file}"` (mtime: `-f%m`, `-c%Y`); `mktemp -d 2>/dev/null || mktemp -d -t 'prefix'`.
- Strip BSD `wc` padding: `wc -l < "${file}" | tr -d ' '`.
- Branch on `uname -s` (`Darwin*`, `Linux*`) only when no fallback exists; fail on anything else.

## Guards and functions

- One condition per guard `if`; never join guards with `&&` or `||`.
- A guard prints `ERROR: <what failed>` with the offending value to stderr, then `return 1`.
- Under `-u`, guards test `"${VAR:-}"`.
- No `cmd && a || b` chains as control flow; write an `if`.
- No `else` or `elif` after a branch that returns; write consecutive `if` blocks.
- No command substitution inside a test: assign to a named local, then test it.
- Put a multi-part condition in an `is_*` function whose last line is a bare `[ ... ]`.
- Other functions end with explicit `return 0`.
- Return data on stdout with `printf "%s"`; messages never share that stream.
- Take only parameters the function uses. Interchangeable functions share one signature and are picked by a variable holding the name: `"${BACKUP_IMPL:-backup_local}" "${source_dir}" "${backup_dir}"`.

## Recipes

- Temp dir: the `mktemp -d` fallback above, path in a global, `trap cleanup EXIT`; never hardcode `/tmp`.
- Lock: a script-specific lock file holding `$$`; wait at most `MAX_WAIT` (default 30) seconds; remove a stale lock when `kill -0` on its PID fails; release only your own PID, from `trap cleanup EXIT`.
- Retry: `retry_command <max_attempts> <delay> <cmd...>` runs `"$@"`; double the delay each attempt, capped at 60 seconds; retry only transient failures (curl exits 6, 7, 28, 52, 56); capture status with `"$@" || exit_code=$?`.

## Checks

- `bash -n <file>` and `shellcheck <file>` both pass.
- Run the script with representative inputs.

## Skeleton

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

# sources
# source "${SCRIPT_DIR}/lib/file-helpers.sh"

# global var declarations
OUTPUT_DIR="${OUTPUT_DIR:-${PROJ_ROOT}/output}"

validate_args() {
    if [ -z "${INPUT_FILE:-}" ]; then
        printf "ERROR: INPUT_FILE is required\n" >&2
        return 1
    fi

    return 0
}

# internal functions

main() {
    if ! validate_args; then
        return 1
    fi

    return 0
}

main "$@"
```
