---
name: ship
description: Save finished work to GitHub and merge it for the team. Use when someone says ship, save it, send it, or that a task is done.
---

1. Run `mise run format`. Stage only the files that belong to this task, then commit with a short lowercase message and no prefix ("shop menu", "fix egg hatch").
2. Run `git fetch origin` then `git rebase origin/main`. Resolve conflicts yourself only when both sides' intent is clear. Otherwise run `git rebase --abort` and explain in plain language who changed what.
3. Run `mise run check`. Fix any error and repeat.
4. If their test place is connected, playtest with `start_stop_play` and read `get_console_output`. Fix errors from this task.
5. Run `git push -u origin HEAD` then `gh pr create --fill`.
6. If the change touches saved player data (`src/core/playerData`), Robux purchases (`ProcessReceipt`, `ProductId`), or project setup (`.rogen.json`, `mise.toml`, `wally.toml`), stop here. Give them the pull request link to send to a programmer on the team.
7. Otherwise run `gh pr merge --squash --delete-branch`, then `git switch main` and `git pull --ff-only`.
8. Tell them in one or two plain sentences what is now in the game code. Merging does not put it in the Team place. That happens at `/release`.
