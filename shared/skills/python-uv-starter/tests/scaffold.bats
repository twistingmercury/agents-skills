#!/usr/bin/env bats

setup() {
  SCAFFOLD="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/scripts/scaffold.sh"
  TARGET="${BATS_TEST_TMPDIR}/proj"
  mkdir -p "${TARGET}"
  cd "${TARGET}"
}

@test "renders the full project into an empty directory" {
  run bash "${SCAFFOLD}" --project-name my-tool --description "Does a thing"

  [ "${status}" -eq 0 ]
  [ -f pyproject.toml ]
  [ -f src/my_tool/main.py ]
  [ -f src/my_tool/cli.py ]
  [ -f src/my_tool/__init__.py ]
  [ -f tests/test_main.py ]
  [ -f .github/workflows/my-tool-ci.yaml ]
  [ -f deploy/.gitkeep ]
  [ -x build/build.sh ]
}

@test "leaves no tokens or .tmpl suffixes behind" {
  run bash "${SCAFFOLD}" --project-name my-tool

  [ "${status}" -eq 0 ]
  run grep -rl '{{' .
  [ "${status}" -eq 1 ]
  run find . -name '*.tmpl'
  [ -z "${output}" ]
}

@test "substitutes values containing sed and bash metacharacters literally" {
  run bash "${SCAFFOLD}" --project-name my-tool --description 'A & B / C \ D'

  [ "${status}" -eq 0 ]
  grep -qF 'description = "A & B / C \ D"' pyproject.toml
}

@test "derives package name and honors python version" {
  run bash "${SCAFFOLD}" --project-name data-pump --python-version 3.13

  [ "${status}" -eq 0 ]
  grep -qF 'data-pump = "data_pump.main:main"' pyproject.toml
  grep -qF 'requires-python = ">=3.13"' pyproject.toml
  grep -qF 'uv:python3.13-bookworm-slim' build/Dockerfile
}

@test "allows agent metadata directories" {
  mkdir .git .claude

  run bash "${SCAFFOLD}" --project-name my-tool

  [ "${status}" -eq 0 ]
  [ -d .git ]
}

@test "refuses a non-empty directory and writes nothing" {
  touch notes.txt

  run bash "${SCAFFOLD}" --project-name my-tool

  [ "${status}" -ne 0 ]
  [[ "${output}" == *"notes.txt"* ]]
  [ ! -e pyproject.toml ]
}

@test "requires a project name" {
  run bash "${SCAFFOLD}"

  [ "${status}" -ne 0 ]
  [[ "${output}" == *"--project-name"* ]]
}

@test "rejects invalid names and descriptions" {
  run bash "${SCAFFOLD}" --project-name My_Tool
  [ "${status}" -ne 0 ]

  run bash "${SCAFFOLD}" --project-name ok --package-name bad-pkg
  [ "${status}" -ne 0 ]

  run bash "${SCAFFOLD}" --project-name ok --python-version 12
  [ "${status}" -ne 0 ]

  run bash "${SCAFFOLD}" --project-name ok --description 'has "quotes"'
  [ "${status}" -ne 0 ]
  [ ! -e pyproject.toml ]
}
