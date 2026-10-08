# Level flow

Purpose: move the player from level to level and biome to biome: level start, boss, advance, badges, World+ and portals.

## Rules

A surface level lasts about 5 minutes (decided 8 Oct).

1. **Level start.** The level builder plans the level from the level seed. The Viking starts at the `start` segment with full health. Checkpoint.
2. **Run.** Segments stream in; enemies, coins and boxes fill as they come.
3. **Boss.** At the `boss_arena` the boss fight runs (see [Enemies and spawning](enemies-and-spawning.md)).
4. **Win.** `BOSS_DEFEATED`. The Viking runs off the right edge, the next level starts. Checkpoint.
5. **Die during the run.** `PLAYER_DIED`. The Viking drops back in about a block ahead and the level carries on. Dying to the boss: open (C6); proposed, the area repeats from its start.
6. **Biome end.** After the last level of a biome, the next biome in play order starts and the biome's badge is earned.
7. **World end.** After the last biome, `WORLD_ADVANCED`: World+ level rises, badges clear, the first biome starts again with higher enemy stats and gold.
8. **Portals.** After a full clear, a portal can appear as a segment feature; entering sends the Viking to the start of a random other biome (`PORTAL_TAKEN`). No distance gold for the jump.

Placeholders: 3 levels per biome (W1), biome order Grassland, Dark Forest, Volcano Land, Frost Mountain (W2; the first build is Dark Forest only). World+ multiplies enemy health and gold by a factor per world level (to be set by simulation).

## Content data

`biomes.json`: `order`, `levels`, `boss`. `economy.json` (later): World+ multipliers.

## State and actions

`run.world_level`, `run.biome`, `run.level_index`; `progress.badges`. Actions: `BOSS_DEFEATED`, `PLAYER_DIED`, `WORLD_ADVANCED`, `PORTAL_TAKEN`, `CHECKPOINT_REACHED`.

## Godot

- `systems/level_flow.gd`: owns the sequence, asks the level builder for each level, swaps scenes, triggers checkpoints.
- Transitions are short fades; no confirmation screens.

## Acceptance

- First build: three Dark Forest levels in a row, each about 5 minutes and ending in the giant frog; dying drops the Viking back in a little ahead; beating the third earns the Dark Forest badge.

## Open

W1 levels per biome and biome levels, W2 order, World+ multipliers, portal frequency, S1 first ascension offer.
