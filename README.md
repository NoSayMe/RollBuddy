# RollBuddy

RollBuddy is a simple World of Warcraft addon for a rolling game with your group.

This project is intentionally small and beginner-friendly. The current version includes:
- core addon setup and initialization
- utility helpers
- game data/state operations
- UI windows
- slash command routing
- start button for broadcasting a configurable game info message to `/y`, `/1`, or both

## Project structure

All addon files are inside the `RollBuddy/` folder:

- `RollBuddy.toc` — load order and addon metadata
- `Core.lua` — addon bootstrap, defaults, and initialization
- `Utils.lua` — shared helper utilities
- `Data.lua` — runtime round state and range CRUD operations
- `UI.lua` — main/settings window creation and refresh logic
- `Commands.lua` — slash command parsing and dispatch table
