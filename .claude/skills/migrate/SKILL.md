---
name: migrate
description: Move an existing published Roblox game's code out of Studio and onto this workflow. Run once per game, by one person.
disable-model-invocation: true
---

Move the game's scripts into `src/` without changing what the game does. The real game is not touched until Stage 5, and it stays recoverable through Roblox version history after that. Explain each stage in plain language, and stop at every "Ask" until the person answers.

## The rules for this whole job

- Preserve behaviour. Change only what the move requires: file locations and the paths used to find other scripts. No refactoring, renaming or restyling. Old code keeps its style, and the Code conventions in `CLAUDE.md` apply to new code only.
- Never change DataStore names, keys, or the shape of saved data.
- Code from `ServerScriptService` or `ServerStorage` must stay on the server. Name those modules `XServer.luau`. A plain `.luau` file goes to `ReplicatedStorage`, where exploiters can read it.
- Before any Studio tool that changes something, call `list_roblox_studios` and pass the `studio_id` matching the place you mean.

## Stage 1: Prepare

1. Confirm `.env` has `MY_PLACE_ID`, that `TEAM_PLACE_ID` in `mise.toml` is the existing game's start place, and that `git status` is clean. Create the branch `<github-login>/migrate`.
2. Ask them to tell the team: "From now until the switch, don't edit any scripts in the game. Building the map and UI is still fine."
3. Create the `.migration` folder (it's not in git) and run `mise run open:team`. Ask them to turn on Team Create if it's off, commit any open script drafts, then use File > Save to File As to save the place as `.migration/place.rbxl` in this project.

## Stage 2: Export

1. Run `mise x github:lune-org/lune@0.11.1 -- lune run ./.claude/skills/migrate/export-place.luau`.
2. If it reports collisions, stop. Explain which existing objects use those names and ask how to rename them in the game first.
3. Read `.migration/manifest.json`. Each script has a status:
   - `move`: goes into `src/`.
   - `review`: read the reason and the code, then choose `move` or `stay`. Record the choice in the manifest.
   - `stay`: remains in Studio as part of the world, such as scripts inside models, tools and GUIs.
4. With read-only `execute_luau` in the Team place, list every Script and LocalScript with `Enabled == false`. Set any the manifest has as `move` to `review`, so disabled code doesn't start running.
5. Tell them the counts in plain words and how you plan to group the code into features. Ask if that sounds right.

## Stage 3: Move the code

1. Move every `move` script from `.migration/export` into `src/`, keeping nested modules together with `init.luau`:
   - `src/features/<name>/` for game features, `src/core/` for game-wide code, `src/platform/` for generic libraries.
   - Scripts end in `.server.luau` or `.client.luau`. Shared modules are plain `.luau`. Server-only modules are `XServer.luau`, client-only modules are `XClient.luau`.
2. Update every way one moved script finds another: `script.Parent.X`, `game.ReplicatedStorage.Modules.X`, `GetService` plus `WaitForChild` chains, and variables holding those. `.server` and `.client` files reach shared modules with `@game/ReplicatedStorage/shared/...`.
3. Paths to things that aren't scripts stay as they are, because those objects remain in the game. If a moved script used `script.Parent` to reach a non-script object, keep that script as `stay` instead.
4. Add `moduleForwards` to the manifest: every moved ModuleScript that a `stay` script requires, with its new location. Search the `stay` files in the export to find these.
5. Set `languageMode` to `nonstrict` in `.luaurc`, because old code was not written for strict mode.
6. Run `mise run format` and `mise run check`. Fix real errors. If selene only objects to old style, set that lint to `allow` in `selene.toml`.

## Stage 4: Rehearse in the test place

1. Ask them to open `.migration/place.rbxl`, use File > Publish to Roblox As, pick their own test place, then reopen it with `mise run open`.
2. In the test place, remove the old copies with `execute_luau`: delete each `move` script, except `moduleForwards` entries. Replace each of those with one line, `return require(<new location>)`, using `ScriptEditorService:UpdateSourceAsync` if setting `Source` fails. Leave `stay` scripts alone. This matters because the old and new code would otherwise both run.
3. Start `mise run dev` in the background. Tell them: "Click Connect in Rojo, then Accept."
4. Playtest with `start_stop_play` and read `get_console_output`. Fix every new error.
5. Warn them that test places share saved data with the live game, then ask them to play through the main features and report anything different from the real game. Don't continue until they say it matches.

## Stage 5: Switch the real game

1. Stop `mise run dev`. Add this to `CLAUDE.md`, filling in the list from the manifest:

   ```markdown
   ## Migrated game

   - Test places share DataStores with the live game. Never write test code that changes other players' data or leaderboards.
   - Older code keeps its original style. When a task touches a script listed here, move it into `src/` first.

   Scripts still in Studio: <paths of the stay scripts>
   ```

2. Commit, push and open a pull request. Ask a programmer on the team to approve it, then merge it and update `main`.
3. Ask: "Is the team ready for me to switch the real game? Nothing reaches players until you publish." Wait for a clear yes.
4. Run `mise run open:team`. Ask them to note the current version number in File > Version History, which is the way back.
5. In the Team place, compare each `move` script's `#Source` with `sourceLength` in the manifest. If any differ, someone edited it after the export. Stop and bring that change into `src/` first.
6. Apply the same removal as Stage 4 step 2, then run `mise run release` in the background. Tell them: "Click Connect in Rojo, check the list only shows scripts and packages, then Accept."
7. Confirm the new code arrived and the world is intact with `search_game_tree`. Stop the release task and tell them to click Disconnect.
8. Ask them to playtest in the Team place, then publish with File > Publish to Roblox when happy. Never publish for them.

## Stage 6: Finish

1. On a new branch, run `git rm -r .claude/skills/migrate`, then ship it. Delete the `.migration` folder.
2. Tell them it's done and what's left: teammates run the setup command and choose Join, then copy the Team place into their test place. The scripts still in Studio will move over time.
