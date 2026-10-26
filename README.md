# Primal Defiance

Melty mashup prototype for **Dawn of Defiance** (host) + **Ancestors: The Humankind Odyssey** (companion).

## First playable slice
- Host: Dawn of Defiance
- Companion: Ancestors: The Humankind Odyssey
- Mode: single-player first release
- Core loop: gather/hunt/craft progression in a local Primal Defiance layer, with evolution-themed upgrades.
- First-minute goal: collect basic materials, craft a primitive tool, make a first hunt/kill, then unlock the first evolution-linked upgrade.
- No game assets are redistributed.

## Current status
The repository now contains the first **local bridge prototype** under `src/`.

### Prototype files
- `src/primal-defiance.ps1` — Windows PowerShell prototype UI. Detects Steam libraries, searches for the two owned games, stores local progression, and can launch the detected Dawn of Defiance executable.
- `src/Run-PrimalDefiance.cmd` — one-click Windows launcher for the prototype.

The prototype intentionally does **not** modify or redistribute either game. It is a development step toward the full Melty integration; it is not yet a verified Melty release.

## Next implementation stages
1. Run the prototype on the creator PC and verify installed-game detection.
2. Identify the correct Dawn of Defiance executable/launch path.
3. Determine a legitimate, read-only way to obtain usable progression information from the player's own Ancestors installation.
4. Add the actual host-game integration supported by the game's modding/runtime capabilities.
5. Build, package, test one-click launch, capture a real runtime screenshot/clip, and only then create a Melty release asset.
