---
name: release
description: Put the latest merged code into the shared Team place. Use only when someone asks to release, or to update the Team place with the latest code.
disable-model-invocation: true
---

1. Run `git switch main` then `git pull --ff-only`. Stop any running `mise run dev` first, since it uses the same port.
2. Run `mise run open:team`, then start `mise run release` in the background.
3. Tell them: "Tell the team a release is happening. In the Team place, click Connect in the Rojo plugin. Check the list only shows scripts and packages, then Accept."
4. Use `search_game_tree` on the Team place to confirm `ReplicatedStorage.shared` and `ServerScriptService.server` updated and `ReplicatedStorage.assets` is still there.
5. Stop the release task and tell them to click Disconnect in Rojo. This must not stay connected.
6. Run `git tag release-<yyyymmdd-hhmm>` then `git push origin --tags`.
7. Ask them to playtest, then use File > Publish to Roblox when they are happy. Never publish for them.
