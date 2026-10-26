# Implementation notes

Dawn of Defiance is an Unreal Engine game and its official FAQ says it did not ship with native mod support. Current public information also shows the game has continued to update, including an Unreal Engine 5.7 update, so runtime compatibility must be tested against the exact installed build before publishing.

Ancestors has a community-documented Unreal Engine 4.20 pak-patching route and a recently published open-source modding toolkit documenting its evolution tree. A Melty mashup named Evolution Odyssey already demonstrates the companion pattern of reading real Ancestors evolution data from the player's installation without redistributing game assets.

The intended technical direction is therefore:
1. Keep Dawn of Defiance as the host.
2. Use the least invasive validated UE5 mod-loading/injection route available on the target build.
3. Add a small runtime bridge that reads a normalized evolution-data export from the player's Ancestors installation.
4. Convert a small number of real evolution branches into host-game progression gates.
5. Package only original bridge/mod code and configuration; never package original game assets.

This note intentionally does not claim that the Dawn of Defiance runtime hook has been validated. The final implementation requires a local build/test pass.
