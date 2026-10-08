# Dark Forest proof

A playable proof of the Dark Forest MVP loop, built 8 October 2026 in `vaporwave-vikings-idle/`: hand-made segments chained into endless levels, coins and vine plants on the floor, the moss golem that stops the Viking, death and drop-ins, the giant frog at the end of every level, the Triple Jump Cave and the spirit leaf dimension, all driven through the Store with a device save. Everything on screen is a placeholder shape; the artist replaces the look.

## The segments

All are 48 blocks wide and enter and exit on row 2 (decided 8 Oct). Sizes inside them were picked by Claude and are easy to change. Each carries *slots* that the spawner fills: coin lines, ground enemy blocks, an elite (or boss) block, air slots for dimensional flyers and a box slot.

| Id | Layout | Role |
| --- | --- | --- |
| `proof_flat` | Flat ground, two coin lines, a pack of three vine plants | Also the `start` segment |
| `proof_pit` | One pit, blocks 22 to 25; coins over the pit; box slot | |
| `proof_platform` | One floating platform, blocks 21 to 27, top at row 5; coins on it | |
| `proof_platforms_2` | Two platforms at row 5, coins on both and a floor line; box slot | |
| `proof_pits_2` | Two pits, blocks 14 to 17 and 31 to 34 | |
| `proof_elite_arena` | Flat, coins at the start, the moss golem at block 28 | Weight 0.6, cooldown 3 so it stays rare |
| `proof_cave_entrance` | Flat with a pit at 22 to 25 that is the cave mouth | Placed at 30 to 60 percent of the level while a course is due |
| `proof_boss_approach` | Long coin line, box slot, no enemies | Always second to last |
| `proof_boss_arena` | The giant frog at block 30 | Always last |

Platforms are one-way: the Viking jumps up through them and lands on top. Pits are 3 blocks wide so auto-jump always clears them; an early tap drops the Viking in.

## What it proves

- The level builder chains segments by seam row with weights and cooldowns, reserves the boss tail, places the cave entrance when a course is due, and passes 10,000 random levels with no failures.
- Segments stream in ahead of the Viking and are freed behind him; the spawner fills each one from its slots and a seeded stream, so the same level always has the same coins and enemies.
- **Start at 0 gold.** Coins lie along the floor from the first screen; distance pays 1 gold per metre; the sword swings automatically at anything in reach and kills pay the enemy's gold.
- **Vine plants** chip health but cannot kill (health floors at 1). **The moss golem** holds the Viking at its stop line and hits him there; a weak Viking dies, a healthy one kills it and runs on.
- **Death** plays a short pause, restores health, drops the Viking back in from the sky a block ahead and extends the level by a full length, exactly like a pit fall. Nothing is lost.
- **The giant frog** waits in the last segment. A Viking far too weak (time to kill more than 3 times his time to die) is eaten at once and a brand-new level is built for the same level number. A strong one kills it, and running past it starts the next level and fires a checkpoint.
- **The Triple Jump Cave** (`df_cave_a1`): while the course is due, one segment carries the cave mouth. Auto-jump clears it like any pit, so the player *chooses* the cave by tapping early into it. Underground, auto-jump is off and three 3-block pits need three taps; one fall shows "You fell!" with Try again or Back to the surface; reaching the far side unlocks the spirit leaf and drops the Viking back onto the surface past the cave.
- **The spirit leaf**: eating one (from a box, which only appears once the leaf is unlocked) tints the whole world, fills air slots with forest spirits for 60 seconds, then wears off. A mixed leaf lasts until the level ends.
- **Sprint**: the button appears once Legs reach level 1, runs 1.5x for 3 seconds, then shows its 20-second cooldown.
- HUD: gold and gold per metre, health bar, active effects, biome and level, metres to the boss, the next slot unlock, and a 3-second toast for events.
- Portrait and landscape layouts, the Store, the device save and the gear shop as before.

## Files

| Path | What |
| --- | --- |
| `tools/gen_proof_segments.py` | Generates the nine segment scenes and `content/segments/proof.json` from a short table, slots included |
| `scenes/segments/proof/*.tscn`, `content/segments/proof.json` | The generated segments and their metadata |
| `scenes/courses/df_cave_a1.tscn` | The Triple Jump Cave: floor at row 2, three pits, `Start` and `End` markers |
| `content/*.json` | Viking, economy, gear, enemies, biomes, ingredients, courses |
| `systems/level_builder.gd`, `tools/segment_linter.gd` | The builder and linter |
| `systems/spawner.gd` | Fills a segment's slots; builds drop-in columns |
| `systems/enemy.gd`, `scenes/enemies/enemy.tscn` | One enemy script for basics, elites, bosses and flyers, sized by role |
| `systems/coin.gd`, `systems/ingredient_box.gd`, `scenes/pickups/*` | Pickups that dispatch to the Store |
| `systems/viking.gd`, `scenes/viking/viking.tscn` | Auto-run, tap jump, auto-jump, sprint, automatic sword, stop lines, death, drop-in |
| `systems/run.gd`, `scenes/run/run.tscn` | The run: levels, streaming, camera, boss, death, extension, courses, HUD, tint |
| `autoload/store.gd`, `autoload/save.gd`, `state/*` | The Store, save, actions, initial state, selectors and the `wallet`, `gear`, `run` and `effects` reducers |
| `systems/layout.gd`, `systems/menu_panel.gd`, `scenes/ui/menu_panel.tscn` | Layout and the menu panel |
| `tests/run_tests.gd`, `tests/run_tests.tscn` | 169 headless tests |
| `tests/shots.gd`, `tests/shots.tscn` | Screenshot tour (needs a window) |

## Running it

- **Play:** open the `vaporwave-vikings-idle` folder in Godot 4.6 and press Play. Tap, click or press Space to jump; tap early into the marked cave pit to enter the course.
- **Portrait:** run with `--resolution 480x960`, or resize the window taller than wide.
- **Tests:** `godot --headless --path . res://tests/run_tests.tscn`. All 169 pass on Godot 4.6 stable: library and linter checks, the seam rule, determinism, 10,000 random levels, extension, an idle Viking collecting coins and killing vine plants, pit falls, the golem stopping and killing then dying, the frog eating a weak Viking and dying to a strong one with the next level starting, the cave entered, failed, retried and completed, the spirit leaf effect and spirits, boxes, both layouts, every reducer and selector, and the save round trip.
- **Screenshots:** `xvfb-run godot --path . --resolution 960x480 --rendering-driver opengl3 res://tests/shots.tscn -- /some/dir`.

## Not in the proof

The batch builder and sync, artefacts, wands, pickups, away gold, the Village and ascension. Vine plant and golem numbers are first guesses (E2).

## Physics numbers used

Run speed 5 blocks per second; 32 pixels per block (placeholder until the art style); jump velocity 14 blocks per second and gravity 28 blocks per second squared. That gives a jump about 3.5 blocks high and 5 blocks long, lasting 1 second.
