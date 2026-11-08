# game-template

A FiveBlox Studios Roblox game. Several people work on it at once, each on their own PC with their own Studio and Claude Code. Some of them are not programmers, so explain things in plain language, run the git commands yourself, and never ask them to resolve a merge conflict.

## Two places, two jobs

| | Team place (`TEAM_PLACE_ID`) | Test place (`MY_PLACE_ID`, one per person) |
|---|---|---|
| Used for | Map, UI, models, assets. Everyone at once through Team Create. | Trying code from this person's branch. |
| Rojo | Blocked, except during `/release`. | Connected while working. |
| Saved how | Team Create and Roblox version history. | Disposable. Anything built here is lost at the next copy. |

Code lives in git, under `src/`. Everything else lives in the Team place.

Rojo must never stay connected to the Team place. It overwrites the shared session and deletes whatever it owns that the local checkout doesn't have, for everyone in the session. `servePlaceIds` in `.rogen.json` enforces this.

## Studio MCP rules

- Each PC talks to its own Studio. Before any tool that changes something, call `list_roblox_studios` and pass the `studio_id` whose place ID matches the place you mean. `.env` holds `MY_PLACE_ID`, `mise.toml` holds `TEAM_PLACE_ID`.
- Never edit scripts through Studio. Change the files in `src/` and let Rojo sync them. `multi_edit` is denied for this reason.
- In the Team place, other people are editing live. Only touch what the task needs, check nobody else is working on that object, and never delete or restructure a shared folder without asking.
- Never click or trigger Publish to Roblox.

## Getting new world work into a test place

The test place does not update by itself. When code needs newer map or UI, ask the person to: open the Team place, File > Save to File As, open that file, File > Publish to Roblox As, and pick their own test place. Then run `/start` again.

## Git

- `/start` begins a task, `/ship` merges it, `/release` puts `main` into the Team place.
- One short-lived branch per task, `<github-login>/<task>`. Merge the same day when possible, since long branches are what cause conflicts.
- Commits are made as the person at this PC. Never change `user.name` or `user.email`.
- Before changing `.rogen.json` or moving top-level `src` folders, check what the generated `default.project.json` will stop mounting.

## Layout (rogen)

`src/` is routed by filename: `X.server.luau` goes to `ServerScriptService.server/...`, `X.client.luau` to `StarterPlayerScripts.client/...`, everything else to `ReplicatedStorage.shared/...`. Wally mounts `ReplicatedStorage.packages` and `ServerScriptService.packages`.

- `src/platform/`: generic utilities (Observers, RemoteWrapper, util).
- `src/core/`: game-wide code (Remotes, player data).
- `src/features/<name>/`: one folder per feature. Keeping work in separate feature folders is what lets people work at the same time.

Scripts and shared modules land in different services, so `.server` and `.client` files require shared modules with `@game/ReplicatedStorage/shared/...`. `./` only works between files that end up in the same place.

Studio-only content lives in `ReplicatedStorage.assets` (lowercase) and is referenced directly from code. Never round-trip assets through `.rbxm`, because InstanceHandle attributes are dropped silently.

## Code conventions

- `const` for every binding that is never reassigned, including `const function`. `local` only when mutated. Tabs. Strict mode comes from `.luaurc`, so no `--!strict` headers.
- File order: services, blank line, requires (packages, shared utils, feature modules, relative last), blank line, constants (`SCREAMING_CASE` for tunables, PascalCase for instance refs).
- Full names: `wanderer`, `deltaTime`, `offsetX`, never `w`, `dt`, `dx`. Abbreviate only names that would be 20+ characters.
- PascalCase for scripts and table modules, camelCase for single-function modules, `xAtom` for atoms, lowercase folders.
- Lifecycles use the Observers utilities. Callbacks return a cleanup function or `nil`. Janitor for complex lifecycles, named `xMaid`.
- State lives in Charm atoms, with modules split into `actions` (immutable, `table.clone` down the path) and `selectors`. charm-sync replicates it.
- Guard clauses and early returns. `WaitForChild(name, timeout)` followed by an `IsA` check.
- Declare every remote in `core/Remotes.luau` through RemoteWrapper with a GreenTea schema. Server handlers still validate by hand: types, NaN and inf, the player's `Loaded` attribute.
- CollectionService tags for entities. Attributes for data.
- Settings modules stay minimal: only the few values worth tuning.
- Avoid clutter such as per-folder `init.meta.json` files.

Meet the spec with as little maintenance burden as possible. Reuse and simplify, and raise it with a programmer on the team before adding anything that needs a lot of bespoke code.
