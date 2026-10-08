# Level builder

Purpose: build every surface level (the normal ground run from start to boss) by chaining hand-made **segments** together, then fill them with enemies, coins and boxes. Segments do not all start and end at the same height, so the builder needs an algorithm that only joins segments that fit, keeps the route on screen, hits the right pacing, and always reaches the boss. Assault courses are not built this way: each course is one whole hand-made level (see [Courses](courses.md)).

Decided 8 Oct:

- The surface is built from hand-made segments; courses are whole hand-made levels.
- Seams can sit at **any row**; the builder matches them.
- **One route** through every segment. Higher platforms inside a segment can hold bonus coins or enemies, but there are no forks.
- A surface level is about **5 minutes** long, the same for every level (about 1,500 m at base speed).
- A **pit fall extends the level** so the boss is a full level's length away again, as if the level had restarted, with no visible restart.
- **Dying to the boss builds a brand-new level** (new seed, same biome and level number) and the Viking starts at its beginning.

Everything else here is a proposal for review.

## Words

| Word | Meaning |
| --- | --- |
| Block | The grid unit. 1 block = 1 metre of run, so gold per metre counts blocks. Pixels per block are set by the art style. |
| Row | A block row counted from the bottom of the 15-block-tall segment, 0 to 14 |
| Seam | Where one segment joins the next. Each segment has an **entry row** (floor height at its left edge) and an **exit row** (floor height at its right edge) |
| Beat | One step of the level plan, such as "enemy pack" or "elite" |
| Slot | A marked spot inside a segment where the spawner may put an enemy, a coin group or a box |
| Drop-in | How the Viking comes back after a death or a pit fall: falling from the top of the screen a little further ahead |

## Segments

### Authoring rules

- Height is always 15 blocks. Width is any whole number of blocks; 8 to 32 is typical.
- Entry and exit rows can be any row from 2 to 10 and can differ: a segment can climb or drop inside itself.
- The main route must be passable with jump and auto-jump only, at base run speed. Sprint and later abilities may open bonus platforms but never the only path.
- Jumps must stay inside the runner's limits: rise at most 3 blocks per jump, gaps at most 4 blocks wide at base speed (see [Runner](runner.md)).
- Pits are part of a segment. An ordinary pit is one the auto-jump clears. A cave-entrance pit is flagged and leads to a course.
- Nothing reward-bearing is placed directly in the scene. Enemies, coins and boxes go in **slots**, so the spawner decides what appears.
- To keep the library small, author mostly on rows 2, 5 and 8. Any row is allowed when a segment needs it; the linter makes sure it is covered.

### Metadata

Each segment scene exports a record to `content/segments/<biome>.json`:

| Field | Example | Meaning |
| --- | --- | --- |
| `id` | `df_climb_02` | Stable id |
| `biomes` | `["dark_forest"]` | Biomes whose art pack can dress it |
| `width` | 18 | Width in blocks |
| `entry_row`, `exit_row` | 2, 5 | Seam heights |
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

### Seam rule

Two segments can join when the next segment's entry row is close enough to the current exit row for the Viking to cross without help:

| Next entry compared with current exit | Allowed? | What happens |
| --- | --- | --- |
| Same row | Yes | Flat join |
| 1 row higher | Yes | The Viking walks up the step |
| 1 to 3 rows lower | Yes | The Viking steps or drops down |
| 2 or more rows higher, or 4 or more lower | No | Needs a `climb` or `drop` segment in between |

This tolerance is a proposal (L3). Setting it to "same row only" makes joins cleaner but needs a much bigger library.

## The algorithm

The builder runs once at level start and produces a list of segment ids. It never instantiates anything; the run scene streams the segments in as the Viking approaches (two to three ahead, freed behind).

### Inputs

- Biome, World+ level, biome level within the world
- Level seed (see Seeds below)
- What is due: whether a course entrance should appear, which ingredients are unlocked
- Target length: about 1,500 m (5 minutes at base speed)

### Pass 1: plan the beats

Build an ordered list of beats from a template, then let the seed vary the middle.

```text
start, run, run,
repeat until about 85% of the target length:
    pick the next beat by the rhythm rules
boss_approach, boss_arena
```

Rhythm rules (placeholders to tune):

- Difficulty follows a curve along the level: easy for the first quarter, rising to the biome's cap near the boss.
- An `elite_arena` beat every 120 to 180 m, never in the first 100 m, always followed by a `rest` or `run` beat.
- A `pack` beat roughly every 30 to 50 m.
- A `coins` beat roughly every 40 m, more often right after a fight.
- A `box` beat once per 150 m if any ingredient is unlocked, and at least one per level.
- A `cave_entrance` beat if a cave course is due, placed in the middle half of the level. A `sky_access` beat by the same rule for sky courses.
- No more than three `jump`, `climb` or `drop` beats in a row.

### Pass 2: chain the segments

Walk the plan, keeping the current exit row (the `start` segment exits on row 2).

For each beat:

1. **Candidates** are segments that have this beat's role, belong to the biome, pass the seam rule from the current exit row, are at or below the difficulty curve here, and are not on cooldown.
2. **Lookahead.** Drop any candidate whose exit row cannot reach the remaining beats. A reachability table, built once per biome from the library, answers "from row R, can I still reach a `boss_approach`, and every role left in the plan?"
3. **Drift control.** Multiply each candidate's weight by a row bias that favours rows 2 to 6 and pushes back above row 8. This keeps the route mostly low on screen with occasional high stretches, and never above row 10.
4. **Pick** by weight with the level's terrain random number generator.
5. **No candidate?** Insert connectors: search (breadth first) over `climb`, `drop` and `run` segments for the shortest path from the current row to a row where the beat's role exists, then place the beat. If no path exists, skip the beat and log it. The library linter should make this impossible.

Then update the current exit row and the cooldowns, and move to the next beat.

### Pass 3: check the level

- Length within 90 to 110 percent of the target.
- Starts with `start`, ends with `boss_approach` then `boss_arena`.
- Every required beat placed (box, course entrance if due).
- Elites spaced as the rules say; rows stay within 2 to 10.

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

### Drop-in pass

After a death or a pit fall the Viking drops in from the top of the screen a little further ahead (see [Runner](runner.md)). The drop-in pass decides what is in the air column he falls through:

- Sometimes nothing, sometimes a column of coins, sometimes one or two air enemies to hit on the way down (placeholder chances: 50 percent nothing, 35 percent coins, 15 percent enemies; dimensional flyers only if their dimension is active).
- It uses its own random stream, seeded from the level seed and a drop-in counter.

### Extension pass (after a pit fall)

A pit fall makes the level longer instead of restarting it.

1. Keep every segment already instantiated: the one the Viking is in and the two or three streamed ahead.
2. Throw away the rest of the planned list, including the boss approach and arena.
3. Run Pass 1 again with the full target length, as if the level had just started: the difficulty curve starts from easy again and the elite spacing rules restart. There is no `start` beat; the plan opens with `run` beats.
4. Keep what is still due: if a course entrance or a box was planned but not yet passed, it goes back into the new plan.
5. Run Pass 2 from the exit row of the last kept segment, with cooldowns carried over, so the join is seamless.
6. Run Pass 3 on the new remainder.

The extension uses its own seed (the level seed plus an extension counter), so the result is reproducible. The HUD's distance-to-boss jumps back to a full level.

There is no limit on extensions. A player who keeps jumping into pits on purpose keeps farming the level; the server's gold bound still caps what they can earn per second.

### Rebuild (after dying to the boss)

Losing to the boss throws the whole level away and runs every pass again with a new seed (the visit counter goes up by one). Same biome, same level number, same target length. The Viking starts at the new level's `start` segment.

### Seeds

- The level seed is derived from the save: `hash(player_id, world_level, biome, level_index, visit_counter)`. The visit counter rises each time the level is rebuilt after a boss death.
- Extensions use `hash(level_seed, extension_counter)`.
- An ordinary death does not rebuild or extend the level; the run continues from the drop-in point (C7 asks whether it should extend).
- All random numbers in the builder and spawner come from explicit `RandomNumberGenerator` objects seeded this way, never the global generator, so a level can be rebuilt exactly for debugging.

## Library linter and coverage tests

A tool (a Godot editor script plus a unit test) checks the segment library for each biome and fails the build if anything is missing.

Static checks:

- Every exit row used by any segment has at least one segment it can join under the seam rule.
- The row graph is connected: from every used row in 2 to 10 you can reach every other through `climb`, `drop` and `run` segments.
- A `start` segment exists. A `boss_approach` and a `boss_arena` exist, and a connector path reaches them from every used row.
- Every role the beat plan uses exists in the biome, at row 2 at least.
- Slots are valid: elite slots only in elite arenas, air slots above the floor, no slot outside the segment.
- Jumps are possible: an automated check walks each segment's main route with the runner's jump limits.

Generation checks (Monte Carlo):

- Build 10,000 levels per biome with random seeds and report: failed builds and fallbacks (target zero), row histogram, role frequency, segment usage (segments never picked are flagged), length distribution and elite spacing.

## Minimum library for Dark Forest

A first guess at the smallest library that passes the linter, authored on rows 2, 5 and 8:

| Role | Count | Rows (entry to exit) |
| --- | --- | --- |
| start | 1 | 2 to 2 |
| run | 6 | two each on 2, 5 and 8 |
| jump | 4 | on 2 and on 5 |
| climb | 3 | 2 to 5, 5 to 8, 2 to 8 |
| drop | 3 | 5 to 2, 8 to 5, 8 to 2 |
| pack | 4 | on 2 and on 5 |
| elite_arena | 2 | on 2 and on 5 |
| coins | 3 | on 2, 5 and 8 |
| box | 2 | on 2 and on 5 |
| rest | 2 | on 2 and on 5 |
| cave_entrance | 1 | on 2 |
| boss_approach | 1 | 2 to 2 |
| boss_arena | 1 | 2 to 2 |

About 33 segments, many of them able to fill two roles. A 1,500 m level uses roughly 80 to 100 segments, so cooldowns and weights matter: the Monte Carlo report should show no segment repeating more often than every 8 segments.

## State and actions

- The builder reads `run` (biome, level index, world level) and `unlocks`, and active `effects` when filling slots. It does not change state.
- The runner dispatches `DISTANCE_TRAVELLED`; enemies dispatch `ENEMY_KILLED`; coins dispatch `COIN_COLLECTED`.

## Godot

- `systems/level_builder.gd`: pure functions `plan_beats()`, `chain()`, `check()`; no scene access, fully unit-tested.
- `systems/spawner.gd`: fills a segment instance's slots when it streams in, and builds drop-in columns.
- `scenes/segments/<biome>/<id>.tscn`: each with `Entry` and `Exit` markers and `Slot` nodes; an editor script exports metadata to JSON.
- `tools/segment_linter.gd`: the linter, also run from tests.

## Acceptance

- 10,000 Dark Forest builds with zero failures and zero fallbacks.
- Every level reaches the boss, keeps the floor between rows 2 and 10, takes about 5 minutes at base speed, and has at least one box once an ingredient is unlocked.
- After a pit fall, the remaining distance to the boss is a full level length, and the join between kept and new segments passes the seam rule.
- After a boss death, the new level differs from the old one and starts at its beginning.
- The same seed always gives the same segment list.
- Eating an ingredient mid-level adds its enemies to segments streamed in afterwards.

## Open

- L3. Seam tolerance: up 1, down 3 (proposed), or exact match only?
- L5. How often is a course due, and how is it chosen (tier and biome rules are in [Courses and unlocks](../game-design/courses-and-unlocks.md))?
- C7. Does an ordinary enemy death also extend the level? [No]
