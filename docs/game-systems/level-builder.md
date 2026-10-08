# Level builder

Purpose: build every surface level by chaining hand-made **segments** together, then fill them with enemies, coins and boxes. Segments do not all start and end at the same height, so the builder needs an algorithm that only joins segments that fit, keeps the route on screen, hits the right pacing, and always reaches the boss. Assault courses are not built this way: each course is one whole hand-made level (see [Courses](courses.md)).

Decided 8 Oct: the surface is built from hand-made segments; courses are whole hand-made levels. Everything else here is a proposal for review.

## Words

| Word | Meaning |
| --- | --- |
| Block | The grid unit. 1 block = 1 metre of run, so gold per metre counts blocks. Pixels per block are set by the art style. |
| Segment | A hand-made scene: 15 blocks tall, any width, one entry and one exit |
| Layer | One of four allowed floor heights at a seam: layer 0 is row 2, layer 1 row 5, layer 2 row 8, layer 3 row 11 |
| Beat | One step of the level plan, such as "enemy pack" or "elite" |
| Slot | A marked spot inside a segment where the spawner may put an enemy, a coin group or a box |

## Segments

### Authoring rules

- Height is always 15 blocks. Width is any whole number of blocks; 8 to 32 is typical.
- The floor at the left edge sits on the **entry layer**; the floor at the right edge sits on the **exit layer**. They can differ: a segment can climb or drop any number of layers inside itself.
- The main route through a segment must be passable with jump and auto-jump only, at base run speed. Sprint and later abilities may open extra rewards but never the only path.
- Jumps must stay inside the runner's limits: rise at most 3 blocks per jump, gaps at most 4 blocks wide at base speed (see [Runner](runner.md)).
- Pits are part of a segment. An ordinary pit is one the auto-jump clears. A cave-entrance pit is flagged and leads to a course.
- Nothing reward-bearing is placed directly in the scene. Enemies, coins and boxes go in **slots**, so the spawner decides what appears.

### Metadata

Each segment scene exports a metadata record to `content/segments/<biome>.json`:

| Field | Example | Meaning |
| --- | --- | --- |
| `id` | `df_climb_02` | Stable id |
| `biomes` | `["dark_forest"]` | Biomes whose art pack can dress it |
| `width` | 18 | Width in blocks |
| `entry_layer`, `exit_layer` | 0, 1 | Seam heights |
| `roles` | `["climb", "pack"]` | What beats it can fill |
| `difficulty` | 2 | 1 (gentle) to 5 (hard) |
| `weight` | 1.0 | Relative chance among valid candidates |
| `cooldown` | 3 | Segments before it may appear again |
| `slots` | see below | Spawn, coin and box slots |
| `flags` | `["cave_entrance"]` | Special features |

Roles: `start`, `run` (plain ground), `jump` (gaps or steps), `climb` (exit higher than entry), `drop` (exit lower), `pack` (room for a basic pack), `elite_arena` (flat run-up and space to stop and fight), `coins` (a coin line), `box` (an ingredient box slot), `rest` (calm after a fight), `cave_entrance`, `sky_access` (platforms that lead up to a sky course), `boss_approach`, `boss_arena`.

Slots:

| Slot kind | Holds | Notes |
| --- | --- | --- |
| `ground` | Basic or dimensional ground enemies | A pack fills several neighbouring ground slots |
| `air` | Flyers (imps, spirits) | Reachable by ranged attacks or a jump |
| `elite` | One elite | Only in `elite_arena` segments |
| `coin_line` | A coin group | Arc, line or staircase shape set in the scene |
| `box` | An ingredient or pickup box | Hit from below |
| `sky_coins` | A coin column for pit-fall respawns | Optional |

## The algorithm

The builder runs once at level start and produces a list of segment ids. It never instantiates anything; the run scene streams the segments in as the Viking approaches (two to three ahead, freed behind).

### Inputs

- Biome, World+ level, biome level within the world
- Level seed (see Seeds below)
- What is due: whether a course entrance should appear, which ingredients are unlocked
- Target length in metres (placeholder: 600 m, about 2 minutes at base speed)

### Pass 1: plan the beats

Build an ordered list of beats from a template, then let the seed vary the middle.

```text
start, run, run,
repeat until 85% of target length:
    pick next beat by the rhythm rules
boss_approach, boss_arena
```

Rhythm rules (placeholders to tune):

- Difficulty follows a curve along the level: easy for the first quarter, rising to the biome's cap near the boss.
- An `elite_arena` beat every 120 to 180 m, never in the first 100 m, always followed by a `rest` or `run` beat.
- A `pack` beat roughly every 30 to 50 m.
- A `coins` beat roughly every 40 m, more often right after a fight.
- A `box` beat once per 150 m if any ingredient is unlocked, at least one per level.
- A `cave_entrance` beat if a course is due, placed in the middle half of the level. A `sky_access` beat by the same rule for sky courses.
- No more than three `jump` or `climb` beats in a row.

### Pass 2: chain the segments

Walk the plan, keeping the current exit layer (start at layer 0).

For each beat:

1. **Candidates** are segments that have this beat's role, belong to the biome, have `entry_layer` equal to the current exit layer, are at or below the difficulty curve here, and are not on cooldown.
2. **Lookahead.** Drop any candidate whose exit layer cannot reach the remaining beats. A precomputed reachability table answers "from layer L, can I still reach a `boss_approach`, and every role still in the plan?"
3. **Drift control.** Multiply each candidate's weight by a layer bias that favours layers 0 and 1 and pushes back from layer 3. This keeps the route mostly low on screen with occasional high stretches.
4. **Pick** by weight with the level's terrain random number generator.
5. **No candidate?** Insert a connector: find the shortest path, over `climb`, `drop` and `run` segments, from the current layer to a layer where the beat's role exists, then place the beat. If no path exists, skip the beat and log it (the library linter below should make this impossible).

Then update the current exit layer and the cooldowns, and move to the next beat.

### Pass 3: check the level

- Length within 90 to 110 percent of the target.
- Starts with `start`, ends with `boss_approach` then `boss_arena`.
- Every required beat placed (box, course entrance if due).
- Elites spaced as the rules say.

If a check fails, rebuild with the next derived seed, up to 5 tries, then fall back to a safe fixed sequence for the biome. Fallbacks are logged so the library can be fixed.

### Pass 4 onwards: fill the slots

Filling runs per segment as it streams in, using its own random number generator seeded from the level seed, the segment's index and the pass name. Terrain and spawns never share a random stream, so changing spawn tables never changes the terrain.

| Pass | What it places | Rules |
| --- | --- | --- |
| Base enemies | Basic packs in `ground` slots | Biome's basic list; pack size 2 to 5, growing with difficulty |
| Elites | One elite in each `elite` slot | Biome's elite list |
| Dimensional enemies | Extra enemies from each active dimension | Read the active effects when the segment streams in; ground ones take free `ground` slots, flyers take `air` slots; density from the ingredient table |
| Coins | Coin groups in `coin_line` slots | Fill chance from the economy table; more after fights |
| Boxes | Ingredient boxes in `box` slots | Only unlocked ingredients found in this biome |
| Bosses | The biome boss in the `boss_arena` | Always |

Because dimensional enemies are chosen as each segment streams in, eating an ingredient mid-level affects the segments ahead, not the ones already on screen.

### Seeds

- The level seed is derived from the save: `hash(player_id, world_level, biome, level_index, attempt_counter)`.
- Proposed: after a death the level keeps the same terrain seed but rolls new spawns (open L1).
- All random numbers in the builder and spawner come from explicit `RandomNumberGenerator` objects seeded this way, never the global generator, so a level can be rebuilt exactly for debugging.

## Library linter and coverage tests

A tool (a Godot editor script plus a unit test) checks the segment library for each biome and fails the build if anything is missing.

Static checks:

- Every layer that any segment exits on has at least one segment entering on it.
- The layer graph is connected: from every layer you can reach every other layer through `climb`, `drop` and `run` segments.
- A `start` segment enters on layer 0. A `boss_approach` and `boss_arena` exist, and a connector path reaches them from every layer.
- Every role the beat plan uses exists in the biome, at layer 0 at least.
- Slots are valid: elite slots only in elite arenas, air slots above the floor, no slot outside the segment.
- Jumps are possible: an automated check walks each segment's main route with the runner's jump limits.

Generation checks (Monte Carlo):

- Build 10,000 levels per biome with random seeds and report: failed builds and fallbacks (target zero), layer histogram, role frequency, segment usage (segments never picked are flagged), length distribution, and elite spacing.

## Minimum library for Dark Forest

A first guess at the smallest library that passes the linter:

| Role | Count | Layers |
| --- | --- | --- |
| start | 1 | 0 to 0 |
| run | 6 | two on each of layers 0, 1, 2 |
| jump | 4 | layers 0 and 1 |
| climb | 3 | 0 to 1, 1 to 2, 0 to 2 |
| drop | 3 | 1 to 0, 2 to 1, 2 to 0 |
| pack | 4 | layers 0 and 1 |
| elite_arena | 2 | layer 0 and layer 1 |
| coins | 3 | layers 0, 1, 2 |
| box | 2 | layers 0 and 1 |
| rest | 2 | layer 0 and 1 |
| cave_entrance | 1 | layer 0 |
| boss_approach | 1 | layer 0 |
| boss_arena | 1 | layer 0 |

About 33 segments, many of them able to fill two roles. Layer 3 is left out of the first build.

## State and actions

- The builder reads `run` (biome, level index, world level) and `unlocks`, and active `effects` when filling slots. It does not change state.
- The runner dispatches `DISTANCE_TRAVELLED`; the spawner's enemies dispatch `ENEMY_KILLED`; coins dispatch `COIN_COLLECTED`.

## Godot

- `systems/level_builder.gd`: pure functions `plan_beats()`, `chain()`, `check()`; no scene access, fully unit-tested.
- `systems/spawner.gd`: fills slots for a segment instance when it streams in.
- `scenes/segments/<biome>/<id>.tscn`: each with an `Entry` and `Exit` marker and `Slot` nodes; an editor script exports metadata to JSON.
- `tools/segment_linter.gd`: the linter, also run from tests.

## Acceptance

- 10,000 Dark Forest builds with zero failures and zero fallbacks.
- Every level reaches the boss, never leaves layers 0 to 2, and has at least one box once an ingredient is unlocked.
- The same seed always gives the same segment list.
- Eating an ingredient mid-level adds its enemies to segments streamed in afterwards.

## Open

- L1. After a death: same terrain, new spawns (proposed), or a whole new level?
- L2. Level length: 600 m placeholder. Fixed per biome, or growing with biome level?
- L3. Four layers 3 blocks apart, or another spacing?
- L4. Should segments ever have two exits (a high and a low path), or is one route plus optional platforms enough?
- L5. How are courses chosen when an entrance is due (tier and biome rules are in [Courses and unlocks](../game-design/courses-and-unlocks.md)), and how often is one due?
- L6. Do pit-fall sky coins come from a segment slot, or a separate respawn pattern?
