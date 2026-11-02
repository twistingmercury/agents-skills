---
name: scaffold-project
description: Use when the user wants to start, create, set up, scaffold, or stand up a new project, app, CLI, service, or repo, including requests like "set it up the way I usually do" or "use my template".
---

# Scaffold Project

New projects start from the owner's GitHub template repos, never from a
hand-built layout. Each template's README is the source of truth for its
setup; this skill picks the template and runs the same flow for all of them.

## Templates

| Template repo                     | Use it for                                     |
| --------------------------------- | ---------------------------------------------- |
| `twistingmercury/scaffold-go-cli` | Go command-line apps installed and run locally |

When no row fits the request, say so and ask the owner how to proceed. Don't
improvise a project layout.

Every template follows one contract: `scaffold_project.sh` at the repo root,
configured with environment variables listed in the README's **Usage**
section. It renders the template, proves the build works, and deletes itself.

## Flow

1. **Pick the template** from the table and read its README Usage section:
   `gh api repos/<template>/readme -H "Accept: application/vnd.github.raw"`.
2. **Confirm with the owner before creating anything**, in one message:
   - repo name and owner, visibility (default **private**), local path
   - every required variable's value. Propose values, don't silently guess:
     module path from the owner's usual pattern, `YOUR_NAME` from
     `git config user.name`.
3. **Create and clone** (creating a repo publishes it, so step 2 comes first):

   ```sh
   gh repo create <owner>/<name> --template <template> --private --clone
   ```

   If the clone is empty, GitHub is still copying: `gh repo clone <owner>/<name>`.
4. **Run the script** inside the clone with the confirmed variables. Leave
   `DELETE_GIT_DIR` and `GIT_INIT_DEVELOP` unset: the repo already has its own
   history and remote, and `DELETE_GIT_DIR=1` would destroy them.
5. **Run the next steps the script prints, exactly**, including their flags:

   ```sh
   git add -A && git commit -s -m "initial project setup"
   git tag -a -s v0.0.1 -m "initial project setup"
   ```

   If tag signing fails, report it and ask; don't silently drop `-s`.
6. **Push only if the request asked for it.**
   - If the owner's request already says to push this project, run
     `check-push-readiness`. If it passes, push the branch and the tag
     (`git push -u origin <default-branch>`, then `git push origin v0.0.1`).
     If it finds anything, stop and report it.
   - Otherwise stop after the tag and ask before pushing.

## Common Mistakes

| Mistake                                       | Fix                                                        |
| --------------------------------------------- | ---------------------------------------------------------- |
| Plain `git commit` / bare `git tag v0.0.1`    | Use the script's printed commands: `-s`, annotated, signed |
| Setting `DELETE_GIT_DIR=1` after `--template` | Leave it unset; it's only for a plain `git clone`          |
| Finishing by hand after the script fails      | Report the failure and the script's "finish by hand" steps |
| Rerunning the script after it rendered        | It refuses by design; follow its printed recovery steps    |
| Public repo by default                        | Private unless the owner says otherwise                    |

## Adding a template

Add a row to the table. The new template must follow the contract above;
anything template-specific belongs in its own README, not here.
