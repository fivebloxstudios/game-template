---
name: start
description: Start a work session on this game. Use when someone says start, let's begin, or names a new thing to work on and no task branch is active yet.
---

1. Run `git status`. If there is unfinished work on a task branch, tell the person and ask whether to continue it. If so, skip to step 4.
2. Run `git switch main` then `git pull --ff-only`.
3. Ask what they want to work on, unless they already said. Create `<github-login>/<short-task-name>` with `git switch -c`. Get the login from `gh api user --jq .login`.
4. Start `mise run dev` in the background, unless port 34872 is already in use.
5. Run `mise run open`.
6. Tell them: "When Studio opens, click Connect in the Rojo plugin, then Accept." Use `list_roblox_studios` to confirm their test place (`MY_PLACE_ID`) is open.

If the task is building the map, UI or models and needs no code, skip the branch and Rojo. Run `mise run open:team` and build in the Team place.
