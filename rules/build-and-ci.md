# Builds, CI, and Docker hygiene

- **Local equals CI.** Design build scripts for an ephemeral clean runner; they give the same result locally.
- **CI calls scripts and tools directly.** Every tool runs from a Docker image pinned to a version tag and digest; nothing is installed on the runner. Workflows and docs never depend on the Makefile, which is a local convenience.
- **Builds are never cached.** Use `docker build --no-cache --pull`; no cache in build scripts or CI.
- **Clean up exactly what a run created.** Use a unique compose project, `down -v --remove-orphans --rmi local`, and throwaway tags removed by exact name. Never `docker system prune`, `docker builder prune`, or `docker volume prune`.
- **Leave unknown containers alone.** If one appears mid-session, ask before touching it.
