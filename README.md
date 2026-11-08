# FiveBlox game template

## First time on a PC

Paste this into PowerShell, then follow the questions:

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/fivebloxstudios/game-template/main/setup.ps1 | iex"
```

Choose **1** to join a game, **2** to create a new one, or **3** to move a game you already have onto this workflow. Log in with your own GitHub account when the browser opens. Run it again whenever you join another game.

Moving an existing game is done once, by one person. Add a sub place for each teammate in the game's Asset Manager, choose **3**, then type `/migrate` in Claude Code and follow along.

## Every day

Open the game's folder in Claude Code.

| Say | What happens |
|---|---|
| `/start` | Gets the latest code, starts a task, opens your test place. |
| Anything, in plain words | Claude does the work and tests it in your Studio. |
| `/ship` | Checks the work and merges it for everyone. |
| `/release` | One person puts the latest code into the Team place. |

## The one rule

**Build the map and UI in the Team place. Test code in your own test place.** Anything you build in your test place gets thrown away.

If Rojo says it can't connect to the Team place, it's doing its job. That block protects everyone's work.
