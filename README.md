# Primal Defiance

A Windows mashup prototype for **Dawn of Defiance** (host) + **Ancestors: The Humankind Odyssey** (companion), with an original survival, senses, evolution, and tribe-management layer.

## Integration milestone

**Companion Overlay Alpha is now implemented.** The launcher can run an external Primal Defiance overlay beside Dawn of Defiance. This is the first in-game-facing integration step: the Primal Defiance layer can remain visible while the host game is running.

The overlay is deliberately external. It does not inject into, patch, modify, or read the host game's memory or assets. It currently displays original sense reports and bridge progression and can open the full Tribe Alpha interface with a hotkey.

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
- External companion overlay beside the host game

## Windows test

1. Download the repository ZIP from GitHub.
2. Extract it.
3. Open `src`.
4. Double-click `Run-PrimalDefiance.cmd`.
5. Confirm the launcher reports **Dawn of Defiance: FOUND**, **Ancestors: FOUND**, **Primal Defiance layer: FOUND — Tribe Alpha**, and **Companion overlay: FOUND**.
6. Click **Start with Companion Overlay**.
7. Dawn of Defiance should launch with a small Primal Defiance panel in the upper-right corner.
8. Press **F8** to hide/show the overlay. Press **F9** to open the full Tribe Alpha interface.
9. In the Tribe Alpha screen, test: Focus senses → Gather → Craft → Search for survivor → Change role → Bond → Group hunt → Care for tribe → Improve camp → Tell a story → End day.
10. Confirm Dawn of Defiance still launches normally and remains unmodified.

## Melty publishing

Do not include copies of either game or copyrighted game assets in the repository. The prototype only detects the player's own installations and launches the owned host game.

Do not publish this integration milestone to Melty yet. First run the exact ZIP locally and capture a screenshot showing Dawn of Defiance running with the external Primal Defiance overlay. Once that test passes, the next stage is to investigate legitimate, documented host-game modding/runtime hooks for deeper world interaction.

## Files

- `src/primal-defiance.ps1` — unified Windows bridge/launcher
- `src/primal-overlay.ps1` — external companion overlay
- `src/Run-PrimalDefiance.cmd` — one-click launcher
- `src/prototype-v4.html` — Tribe Alpha playable layer
- `src/tribe-simulation.js` — reusable tribe simulation module
- `sheets/` — mashup and preflight notes
- `docs/` — project documentation

## Important scope

This is an original gameplay/progression layer inspired by survival and evolution concepts. It does not redistribute either game, copy game assets, inject into the host process, or claim to reproduce the original games' proprietary systems.
