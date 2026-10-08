# Proof segments

A first playable proof of the level builder: five simple segments, chained into endless levels, with a placeholder Viking and a parallax background. Built 8 October 2026 in `vaporwave-vikings-idle/`.

## The five segments

All are 48 blocks wide and enter and exit on row 2 (decided 8 Oct). Sizes inside them were picked by Claude and are easy to change.

| Id | Layout |
| --- | --- |
| `proof_flat` | Flat ground. Also the `start` segment |
| `proof_pit` | One pit, blocks 22 to 25 (3 wide) |
| `proof_platform` | One floating platform, blocks 21 to 27, top at row 5 |
| `proof_platforms_2` | Two platforms, blocks 12 to 18 and 30 to 36, both at row 5 |
| `proof_pits_2` | Two pits, blocks 14 to 17 and 31 to 34 |

Platforms are one-way: the Viking jumps up through them and lands on top. Pits are 3 blocks wide so auto-jump always clears them; an early tap drops the Viking in.

## What it proves

- The level builder chains segments by seam row, with weights, a cooldown so nothing repeats back to back, and a full-length check (1,536 m per level against a 1,500 m target).
- Segments stream in ahead of the Viking and are freed behind him.
- Auto-jump clears every pit; an early tap drops him in.
- A pit fall drops him back in from the sky just past the pit and extends the level by a full length.
- At the end of a level the next one is built and joined on seamlessly.
- The background has five layers scrolling at different speeds.
- Portrait and landscape layouts: in portrait the game fills the top half and the menu panel docks below; in landscape the game fills the screen and a Menu button slides the same panel in as a drawer from the right, over the game, without moving the camera. The camera always fits the 15-block height to the game view.
- A Gear tab that reads `content/gear.json`: rows appear as their gold-held bracket is reached (Sword, Chest and Helmet at start, Legs at 100 gold, then a hint for the next locked slot), level 1 costs scale Sword 1, Chest 10, Helmet 100, Legs 250, and the cost rises linearly. Buy buttons go green or red against the gold earned by running. Other tabs are stubs.

## Files

| Path | What |
| --- | --- |
| `tools/gen_proof_segments.py` | Generates the five segment scenes and `content/segments/proof.json` from a short table. Edit the table and re-run to change sizes |
| `scenes/segments/proof/*.tscn` | The generated segment scenes |
| `content/segments/proof.json` | Segment metadata the builder reads |
| `content/viking.json`, `content/economy.json` | Run speed, jump physics, level length |
| `systems/level_builder.gd` | The builder: seam rule, chaining, checks, extension, fallback |
| `tools/segment_linter.gd` | Library linter |
| `systems/viking.gd`, `scenes/viking/viking.tscn` | Placeholder Viking: auto-run, tap jump, auto-jump, pit-fall signal, drop-in |
| `systems/run.gd`, `scenes/run/run.tscn` | The run: builds levels, streams segments, camera, HUD, drop-ins and extension |
| `systems/parallax_placeholder.gd`, `scenes/backgrounds/proof_background.tscn` | Placeholder parallax background |
| `systems/layout.gd` | Portrait or landscape detection, game rect, panel docking and the drawer |
| `systems/menu_panel.gd`, `scenes/ui/menu_panel.tscn` | The menu panel: nav bar, tabs, placeholder gear rows |
| `content/gear.json` | Gear slots: brackets, level costs, stats |
| `tests/run_tests.gd` | 71 headless tests |

## Running it

- **Play:** open the `vaporwave-vikings-idle` folder in Godot 4.6 and press Play. Tap, click or press Space to jump.
- **Portrait:** run with `--resolution 480x960`, or resize the window taller than wide; the layout switches live.
- **Tests:** from that folder, `godot --headless --path . --script res://tests/run_tests.gd`. All 71 pass on Godot 4.6 stable: library and linter checks, the seam rule, determinism, 10,000 random levels with no failures, extension, physics simulations of an idle Viking, a pit fall and an early tap, both layouts and the drawer, and the placeholder gear purchases.

The base viewport is 480 by 480 with `canvas_items` stretch, so UI is designed at about 480 units across in either orientation and scales up on phones.

## Not in the proof

The `Store` autoload and actions (the run and the panel keep their own counters for now), enemies, coins, boxes, the boss, and saving. Those come next, following the [first build](first-build.md) order.

## Physics numbers used

Run speed 5 blocks per second; 32 pixels per block (placeholder until the art style); jump velocity 14 blocks per second and gravity 28 blocks per second squared. That gives a jump about 3.5 blocks high and 5 blocks long, lasting 1 second.
