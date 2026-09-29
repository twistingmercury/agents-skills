---
name: python-uv-starter
description: Use when standing up a new, empty Python project (CLI or package) in the current directory with uv, src/ layout, pytest, ruff, a Makefile, a Docker-first wheel build, and GitHub Actions CI. Not for modifying an existing Python project.
---

# Python uv Starter

Scaffolds the current directory as a minimal Python CLI project in the
`agentic_loop_runner` layout. It's deterministic: every file comes from
`assets/project/` via `scripts/scaffold.sh`. Don't hand-write the files.

## Generated layout

| Path | Purpose |
| --- | --- |
| `pyproject.toml` | setuptools backend, `dev` group (pytest, ruff), `[project.scripts]` entry point |
| `src/<package>/main.py`, `cli.py` | `main(argv=None)` entry point; argparse lives in `cli.py` |
| `tests/test_main.py`, `test_cli.py` | Passing pytest stubs |
| `Makefile` | `help`, `test`, `analyze`, `build`, `install`, `uninstall` |
| `build/Dockerfile`, `build/build.sh` | Formats, lints, tests, then exports the wheel to `dist/` |
| `.github/workflows/<project>-ci.yaml` | Runs `build/build.sh` on `develop`/`main` |
| `.editorconfig`, `.gitignore`, `.dockerignore`, `README.md`, `CHANGELOG.md` | Repo hygiene |
| `deploy/`, `scripts/`, `docs/` | Empty placeholders (`.gitkeep`) |

## Steps

1. **Pick names.** Ask for the project name if the user didn't give one.
   `--project-name` is the distribution and CLI name (lowercase, hyphens
   allowed). The rest is optional; pass a flag only when the user supplied the
   value. Defaults: package = name with `-` → `_`, display name = name,
   description = "A new Python project", Python floor = 3.12.
2. **Check the target.** Run from the directory that becomes the repo root.
   It may only hold `.git`, `.claude`, `.codex`, or `.agents`. The script
   checks this itself and refuses anything else before writing. On refusal,
   report the blocking entry and ask the user whether to move it or choose
   another directory. Never delete it or render somewhere else yourself.
3. **Render.** Run the script through bash, using this skill's absolute path:

   ```sh
   bash /absolute/path/to/python-uv-starter/scripts/scaffold.sh \
     --project-name <name> \
     [--package-name <snake_name>] \
     [--display-name "<Title>"] \
     [--description "<one line, no double quotes>"] \
     [--python-version 3.12]
   ```

4. **Verify** from the project root, checking exit codes. Run `make test`. It
   syncs, formats, lints, runs pytest, and creates `uv.lock`, which the Docker
   build needs. If `docker info` succeeds, run `bash build/build.sh` too. If it
   doesn't, say so and don't claim the build passes. Locally uv may pick any
   interpreter ≥ the floor; the Docker build pins the floor version.
5. **Hand off.** Summarize the layout and the commands (`uv run <name>`,
   `make test`, `make build`).

Don't `git init`, commit, push, or add runtime dependencies unless the user
asks for it.

## Common mistakes

- Running the script with a bare path. Always use `bash scripts/scaffold.sh`,
  since installers can drop the executable bit.
- Skipping `make test` before `build/build.sh`. The Dockerfile uses
  `uv sync --frozen`, which fails without `uv.lock`.
- Using `dist/<project-name>-*.whl` with a hyphenated name. Wheels use the
  underscored package name. The Makefile already handles this.
