#!/usr/bin/env bash
# Renders assets/project into the current directory, which must be empty
# apart from VCS and agent metadata.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="${SKILL_DIR}/assets/project"
ALLOWED_ENTRIES=(.git .claude .codex .agents)

PROJECT_NAME=""
PACKAGE_NAME=""
DISPLAY_NAME=""
DESCRIPTION="A new Python project"
PYTHON_VERSION="3.12"

usage() {
  cat <<'EOF'
Usage: scaffold.sh --project-name <name> [options]

  --project-name <name>     Distribution and CLI name (lowercase, hyphens allowed). Required.
  --package-name <name>     Import package name (default: project name with - replaced by _).
  --display-name <text>     Human-readable title for README and CI (default: project name).
  --description <text>      One-line project description.
  --python-version <3.N>    Minimum Python version (default: 3.12).
EOF
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --project-name) PROJECT_NAME="${2:-}"; shift 2 ;;
      --package-name) PACKAGE_NAME="${2:-}"; shift 2 ;;
      --display-name) DISPLAY_NAME="${2:-}"; shift 2 ;;
      --description) DESCRIPTION="${2:-}"; shift 2 ;;
      --python-version) PYTHON_VERSION="${2:-}"; shift 2 ;;
      -h | --help) usage; exit 0 ;;
      *) usage >&2; die "unknown option: $1" ;;
    esac
  done

  [[ -n "${PROJECT_NAME}" ]] || { usage >&2; die "--project-name is required"; }
  PACKAGE_NAME="${PACKAGE_NAME:-${PROJECT_NAME//-/_}}"
  DISPLAY_NAME="${DISPLAY_NAME:-${PROJECT_NAME}}"
}

validate_args() {
  [[ "${PROJECT_NAME}" =~ ^[a-z][a-z0-9-]*$ ]] || die "project name must match ^[a-z][a-z0-9-]*\$: ${PROJECT_NAME}"
  [[ "${PACKAGE_NAME}" =~ ^[a-z][a-z0-9_]*$ ]] || die "package name must match ^[a-z][a-z0-9_]*\$: ${PACKAGE_NAME}"
  [[ "${PYTHON_VERSION}" =~ ^3\.[0-9]+$ ]] || die "python version must look like 3.N: ${PYTHON_VERSION}"

  # Values land inside TOML/YAML strings, so quotes and newlines would break them.
  local text
  for text in "${DISPLAY_NAME}" "${DESCRIPTION}"; do
    [[ "${text}" != *'"'* && "${text}" != *$'\n'* ]] || die "display name and description cannot contain double quotes or newlines"
  done
}

is_allowed_entry() {
  local entry="$1" allowed
  for allowed in "${ALLOWED_ENTRIES[@]}"; do
    [[ "${entry}" == "${allowed}" ]] && return 0
  done

  return 1
}

# Refuses to render over anything a user might care about.
require_empty_target() {
  local path name
  shopt -s dotglob nullglob
  for path in ./*; do
    name="${path#./}"
    is_allowed_entry "${name}" && [[ ! -L "${path}" ]] && continue
    die "target directory is not empty; blocking entry: ${name}"
  done
  shopt -u dotglob nullglob
}

substitute_tokens() {
  local text="$1"
  # Quoted replacements keep bash 5.2+ from treating & as the matched text.
  text="${text//"{{PROJECT_NAME}}"/"${PROJECT_NAME}"}"
  text="${text//"{{PACKAGE_NAME}}"/"${PACKAGE_NAME}"}"
  text="${text//"{{DISPLAY_NAME}}"/"${DISPLAY_NAME}"}"
  text="${text//"{{DESCRIPTION}}"/"${DESCRIPTION}"}"
  text="${text//"{{PYTHON_VERSION}}"/"${PYTHON_VERSION}"}"
  printf '%s' "${text}"
}

render_file() {
  local src="$1" relative dest content
  relative="${src#"${TEMPLATE_DIR}/"}"
  dest="$(substitute_tokens "${relative%.tmpl}")"
  mkdir -p "$(dirname "${dest}")"

  if [[ ! -s "${src}" ]]; then
    : >"${dest}"
    return
  fi

  # Command substitution strips trailing newlines; templates end with exactly one.
  content="$(<"${src}")"
  printf '%s\n' "$(substitute_tokens "${content}")" >"${dest}"
}

render_project() {
  local src
  while IFS= read -r -d '' src; do
    render_file "${src}"
  done < <(find "${TEMPLATE_DIR}" -type f -name '*.tmpl' -print0)

  chmod +x build/build.sh
}

main() {
  parse_args "$@"
  validate_args
  require_empty_target
  render_project
  printf 'Scaffolded %s in %s\n' "${PROJECT_NAME}" "$(pwd -P)"
}

main "$@"
