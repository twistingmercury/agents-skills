# Library documentation

When a task depends on a library, framework, SDK, CLI, or cloud service, fetch current documentation with Context7 (`mcp__context7__resolve-library-id`, then `mcp__context7__query-docs`) instead of relying on memory. This applies to writing new code, refactoring, and review, not only to direct questions. It takes precedence over any "do not use for" list in other Context7 rules. The repository's pinned versions and conventions take precedence. Before flagging an API as deprecated or misused during review, check its current documentation the same way.

Skip Context7 for questions that are not about a specific library or API, such as general programming concepts or business-logic debugging.
