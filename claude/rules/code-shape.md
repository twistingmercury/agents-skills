# Code shape

These rules apply to code in every language. Language rules add the language-specific details.

- **Never-nester.** Handle errors and edge cases first and return early; keep the happy path at the left margin. Move non-trivial loop and `case` bodies into named functions.
- **Blank line after every `if` block**, except before the enclosing block's closing brace or an `else`.
- **Named callbacks.** A callback longer than a line or two becomes a named function, not an inline literal.
- **One job per function.** When a function grows long, split it along its seams.
- **Modern standard library.** Prefer current built-ins and stdlib helpers over hand-written equivalents.
- **Comments explain why.** State the reason code exists or has its shape. If code needs a comment to say *what* it does, rewrite the code.
- **Bare minimum.** Build only what the task needs; ask before adding abstractions, layers, or dependencies.
- **Fix, don't suppress.** Never silence linters or security scanners with inline suppressions (`#nosec`, `//nolint`, `# noqa`, `// eslint-disable`); fix the code.
