# Secrets

- Never read, print, log, or write an API key or other credential that lives in a host environment variable.
- Never run `env`, `printenv`, `set`, or `export -p`; they dump every secret in the environment.
- Use fake values in tests and examples.
