# Primal Defiance

A Windows mashup prototype for **Dawn of Defiance** (host) + **Ancestors: The Humankind Odyssey** (companion), with an original survival, senses, evolution, and tribe-management layer.

## Release Candidate status

**Release Candidate 1 is ready for one final local test before Melty publishing.**

The repository now has a unified launcher that detects both owned Steam games, opens the Primal Defiance Tribe Alpha layer, and can launch Dawn of Defiance. Melty requires a release to run successfully on the creator's PC before it can pass its audit and go live.

## Current playable systems

- Survival: food, stamina, water, materials, crafting, hunting, exploration, day/night progression
- Primal senses: sight, hearing, scent, and focused sensing
- Evolution: Primal Adaptation, Keen Senses, Tribal Memory
- Tribe: recruitment, personalities, roles, health, loyalty, skills, morale
- Relationships: bonding and individual tribal memories
- Group hunting and camp improvement
- Persistent local Tribe Alpha browser state
- Steam AppID/appmanifest detection for custom Steam library locations
- Dawn of Defiance launch support

## Windows test

1. Download the repository ZIP from GitHub.
2. Extract it.
3. Open `src`.
4. Double-click `Run-PrimalDefiance.cmd`.
5. Confirm the launcher reports **Dawn of Defiance: FOUND**, **Ancestors: FOUND**, and **Primal Defiance layer: FOUND — Tribe Alpha**.
6. Click **Start Primal Defiance**.
7. In the Tribe Alpha screen, test: Focus senses → Gather → Craft → Search for survivor → Change role → Bond → Group hunt → Care for tribe → Improve camp → Tell a story → End day.
8. Confirm Dawn of Defiance still launches from the launcher.

## Melty publishing

Do not include copies of either game or copyrighted game assets in the repository. The prototype only detects the player's own installations and launches the owned host game.

After the exact Release Candidate above passes locally, use Melty's **Publish** flow. Melty scans uploads and audits the source before release; a release must first run successfully on the creator's PC.

## Files

- `src/primal-defiance.ps1` — unified Windows bridge/launcher
- `src/Run-PrimalDefiance.cmd` — one-click launcher
- `src/prototype-v4.html` — Tribe Alpha playable layer
- `src/tribe-simulation.js` — reusable tribe simulation module
- `sheets/` — mashup and preflight notes
- `docs/` — project documentation

## Important scope

This is an original gameplay/progression layer inspired by survival and evolution concepts. It does not redistribute either game, copy game assets, or claim to reproduce the original games' proprietary systems.
