---
name: issue-writer
description: Writes or updates an issue in the project's tracker from a fixed Context / The Work / Expected Result template. Use when filing a bug, enhancement, or deferred finding, or when asked to open, write, or update an issue.
---

# Issue Writer Skill

Create or update an issue on the issue tracking system using the following format. Each `>` line is a placeholder: replace it with the real content and drop the `>` marker.

```markdown
## Context

> The circumstances that caused this issue to surface. What is the problem being faced that
> this enhancement or fix will address?

## The Work

> Describe what needs to be done. Identify key areas where code, script, and/or documentation changes need to be made.

## Expected Result

> Describe any expectations of correctness and "doneness", such as all unit tests pass, end-to-end tests pass, docs are updated, tests are updated, etc.
```

## Rules

- The issue body starts at `## Context`; the surrounding code fence is not part of it.
- Use `gh issue create` or `gh issue edit` and pass the body with `--body-file`. If the repo has no GitHub remote, ask which tracker to use.
- Write a short, imperative title under about 70 characters. Keep it out of the body.
- To update an issue, rewrite its body in this format, keeping any existing details that still apply.
- If you were not explicitly told to create or update an issue, show the draft and ask before posting.
- Use only labels that already exist (`gh label list`), or none. Don't assign anyone unless asked.
- Mark unverified claims as unverified. Write "Unknown" instead of guessing or leaving a section empty. Never include secrets or tokens.
- End the body with `🤖 Generated with [Claude Code](https://claude.com/claude-code)`, following the attribution rules in CLAUDE.md.
