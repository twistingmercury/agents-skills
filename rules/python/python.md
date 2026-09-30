---
paths:
  - "**/*.py"
---

# Python

## Style

- Type-hint every function signature; annotate variables only where it helps.
- Model structured data with `dataclasses` or Pydantic models.
- Use `pathlib`, not `os.path`, for filesystem work.

## Errors

- Catch specific exception types; never a bare `except:`.
- Give domain errors their own exception hierarchy.
- Re-raise with `raise ... from ...` so the exception chain survives.

## Tests

- Use `pytest`: fixtures for setup and teardown, `@pytest.mark.parametrize` for input variations.
- Tests live in a top-level `tests/` directory.
- While developing, `pytest -x` stops at the first failure and `--tb=short` keeps failure output short.

## Project

- Prefer `uv`, `ruff`, and `pytest` for tooling.
- `pyproject.toml` is the single source of project metadata.
- Distributable packages use the `src/` layout.

## Checks

- If the project defines its own gates (Makefile targets, `CLAUDE.md` commands, a Docker build), run those instead of this list.
- Otherwise, after any change to Python code, run in this order: `ruff format .`, `ruff check --fix .`, `mypy .`, `pytest`, `bandit -r . -q`.
- Fix every finding before calling the work done.
