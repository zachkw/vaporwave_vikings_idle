# Tile Map Generation

This document defines the first direction for world and route generation. The game will use authored tiles that are assembled deterministically during a run.

The important idea is that the route can feel endless and varied, but it must still be reproducible. The Godot client and backend should be able to generate the same route from the same server-issued seed, content version, and tile library.

## Design Goal

The map system should support:

- Endless left-to-right running.
- Authored platforming and reward moments.
- Random-feeling route variety.
- Controlled difficulty and reward pacing.
- Server validation through deterministic generation.
- Future branching routes, caves, clouds, underground paths, and challenge courses.

The generator should not invent arbitrary geometry. It should choose from a library of authored tiles that declare how they connect.

## Tile Unit

Tiles are authored content pieces with a fixed height and variable width.

Working MVP assumptions:

- Tile height is 15 blocks.
- Tile width can vary by tile, such as 10, 16, 20, or 32 blocks.
- Authoring coordinates are block-grid coordinates.
- Implementation can convert blocks to pixels, such as 16 by 16 pixels per block.
- Distance validation can use block distance or converted pixel distance, as long as client and backend use the same unit.

The exact pixel size of a block can change once art direction is clearer. The level design contract should stay stable: tiles expose width, height, connector rows, rewards, enemies, boxes, and exits in deterministic data.

A tile contains:

- Terrain.
- Platforms.
- Coins and reward groups.
- Enemy spawn points.
- Special boxes.
- Optional hazards.
- Optional entrances to special routes.
- One entrance connector for MVP.
- One exit connector for MVP.

The tile size should be large enough to contain a readable gameplay beat, but small enough that generation can create variety without needing huge authored scenes.

## Connector Model

Each tile declares where the player enters and exits.

For the MVP, each tile has one entry connector and one exit connector. A connector is a floor-surface Y row at the tile seam. For example, a tile might have an entrance at row 2 and an exit at row 2. That means the player enters and exits while running on a floor surface at row 2.

The generator can connect a tile only to another tile with a compatible entrance.

Example:

```text
Tile A exits at Y row 2.
Tile B enters at Y row 2.
Tile A can connect to Tile B.
```

The player is not necessarily standing inside the row. The row represents the connection contract, such as the walking surface height at the seam between tiles.

Tiles can support height changes even if the first tile set mostly uses flat connections.

Example:

```text
Tile A enters at Y row 2.
Tile A exits at Y row 7.
The next tile must enter at Y row 7.
```

This does not transform the camera or world height. It simply means the tile ends with the main floor higher on the screen, and the next tile must start at that same height.

## Vertical Range

The full tile height does not need to be used for connector rows.

The authored tile set should keep connection rows within a controlled vertical band so generation remains reliable. For example, with a 15-block tile height, early tiles might use connector rows 2 through 10.

This keeps the map from drifting too high or too low and prevents the generator from getting trapped in rare connector states.

The MVP can start even tighter, such as mostly row 2 to row 2 connections, then widen the band once the runner feel is proven.

Later worlds can widen the allowed vertical band as movement abilities expand.

## Tile Metadata

Each authored tile should eventually have metadata similar to:

| Field | Purpose |
| --- | --- |
| `tile_id` | Stable content id for the tile. |
| `content_version` | Version of the tile data. |
| `width_blocks` | Tile width in authoring blocks. |
| `height_blocks` | MVP value: 15. |
| `world_tags` | Which worlds, biomes, or themes can use it. |
| `tile_pool` | Generation pool, such as main, secret speed, secret magnet, boss approach, or boss. |
| `tile_role` | Gameplay role, such as ground, coin line, enemy, blocker, special box, or boss. |
| `difficulty_band` | When the tile is allowed to appear. |
| `entry_y` | MVP entry floor-surface row. |
| `exit_y` | MVP exit floor-surface row. |
| `required_abilities` | Abilities needed to complete or fully collect the tile. |
| `reward_groups` | Coins, enemies, pickups, and mutually exclusive groups. |
| `special_boxes` | Hit-from-below boxes, reward table ids, and seeded reward references. |
| `secret_connections` | Optional entrances to cloud levels, caves, underground paths, or other challenge routes. |
| `weight` | Relative selection weight in compatible pools. |
| `cooldown` | Optional spacing rule to prevent repetition. |
| `special_flags` | Cave entrance, cloud route, boss approach, horde tile, etc. |

The Godot client can use this metadata to build the route. The backend can use the same metadata to replay or validate the route.

Enemy spawns need layer and mushroom-effect reveal metadata for the real-world biome, hallucination, and demonic true layers. Base biome spawns remain available at all times. Hallucination and demonic spawns are additional overlays selected by the mushrooms taken and can coexist. Generation context must include active mushroom effects as well as world and biome levels; do not use a single selected layer that replaces the base population. Exact mushroom mappings, spawn densities, and effect durations remain open. Layer transitions must reproduce the same eligible spawns and stable reward identities on the client and server; the seed alone is insufficient without the relevant progression and modifier state.

The discoverable pickup family includes mushrooms, flowers, and other forms. Drop eligibility is established by discovering the type. Keep discovered-type flags separate from active effects: generating and taking a later eligible drop triggers its effect. Mushrooms specifically reveal Whacky World or Demon World, while the wider effect system can stack enemy additions, multipliers, and special effects. Expose discovery conditions, eligible drop sources, probabilities, stable drop identities, effect mappings, and stacking rules in shared content once designed. Overlay enemies also need higher-grade material reward tables; exact items and probabilities remain open.

Mushroom discovery conditions belong to the existing challenge-room/course content. Map the room's configured discovery reward to its mushroom type's future-drop unlock. A later mushroom spawn must use the accepted unlock state. This source is confirmed for mushrooms; flower and other pickup discovery sources remain unassigned.

## Deterministic Generation

Each run session should have a map seed issued by the server.

The server creates the run session and returns:

- Run session id.
- Content version.
- Map seed.
- Starting world or route context.
- Any generation parameters needed for that run.

The client and backend must use the same deterministic generation algorithm. Given the same content version, seed, current tile index, and player progression state, they should choose the same tiles in the same order.

This means the project should avoid relying on engine-specific random behavior. Godot and Node.js should share a documented pseudo-random algorithm and consume random numbers in exactly the same order.

## Generation Flow

A basic generation pass can work like this:

1. Start with a known starting tile and starting connector row.
2. Read the current exit connector.
3. Build a list of candidate tiles with compatible entrance connectors.
4. Filter candidates by tile pool, world, difficulty, required abilities, route type, and content rules.
5. Apply weights and spacing rules.
6. Use the seeded RNG to choose the next tile.
7. Place the tile immediately to the right of the previous tile.
8. Add the tile's width to cumulative route distance.
9. Record or derive the tile index, selected tile id, and cumulative X range.
10. Repeat as the player runs.

Boss insertion can override normal weighted selection. For example, if the boss threshold is 1,000 tiles or a fixed route distance, the generator can place a boss approach tile and then a boss tile after the threshold is crossed.

The route is generated progressively, but it remains deterministic. The backend does not need to receive every tile from the client if it can reproduce the same sequence itself.

## Rewards and Validation

Tile generation is directly tied to validation.

If the backend knows the seed, tile library, generation algorithm, and player's starting state, it can reconstruct the same route the client saw. It can then validate reported rewards against the generated tiles.

This helps answer:

- Which coins existed in the segment?
- Which enemies existed in the segment?
- Which rewards were mutually exclusive?
- Which route choices were possible?
- Which rewards required specific abilities?
- Which boss, blocker, or challenge entrance appeared?
- Whether the reported gold was within possible bounds.

Reward-bearing objects should belong to tile metadata rather than being hidden only in Godot scene behavior.

## Client and Server Contract

The server owns the seed. The client consumes the seed.

The run session should store:

- Map seed.
- Content version.
- Generation algorithm version.
- Starting world or route id.
- Starting tile index.
- Starting connector row.
- Starting cumulative X position.
- Boss threshold for the current zone.
- Player state snapshot at run start.

Progress reports should include enough information for the server to align with the client, such as:

- Run session id.
- Report sequence number.
- Elapsed time.
- Tile index range and route distance covered.
- Reported pickups, kills, and rewards.
- Ability usage.
- Any route choices that affect mutually exclusive rewards.

The server can then replay or bound-check the same tile range.

## Secret Level Connections

Some tiles can contain optional entrances to secret routes. These are not normal left-to-right seam connectors. They are authored entry points inside the tile, such as cloud blocks above the main path or a cave entrance below a platform.

A cloud entrance is the simplest example. The player jumps above the normal route, reaches the entrance, and transitions into a cloud challenge course. That course may require more precise jump timing than the main route.

Secret connections should declare:

- Stable connection id.
- Route type, such as cloud, cave, underground, or portal.
- Entry position or trigger area.
- Required abilities to reach the entrance, if any.
- Target course id or tile pool.
- Completion reward.
- Return rule, if the course returns to the main route.

Challenge course completion grants its special ability immediately. For example, a cloud course can grant run-level double jump ownership, making it usable without a gold purchase. The backend must validate the completion event and the resulting ownership grant.

More detail lives in [Challenge Courses and Ability Unlocks](challenge-courses-and-ability-unlocks.md).

## Special Boxes

Some tiles can contain hit-from-below boxes inspired by Mario-style question blocks.

Special boxes should be authored as tile objects:

- Stable box id.
- Position in block coordinates.
- Trigger type, such as headbutt from below.
- Unlock requirement, if any.
- Reward table or seeded reward id.
- Whether reward is instantly collected.

For MVP, magnetism is the first special-box reward. Once the player completes the magnet secret route and unlocks magnetism, tiles with eligible special boxes can start appearing. When the player hits the box, the magnet powerup pops out and is instantly picked up.

The reward should be determinable from the seed. The backend does not need to know that the player was frame-perfect, but it should be able to validate that the box existed, the reward was possible, and the player did not claim more box rewards than the generated route allowed.

The broader progression includes optional portal travel after all levels have been cleared. The earlier randomly appearing teleport-box encounter supplies route opportunities. A five-level ascension upgrade separately provides a biome-start portal chance of 20%, 40%, 60%, 80%, or 100%. Activation sends the player to another randomly selected biome, with no destination choice. Metadata should expose eligibility, whether this is a route or biome-start opportunity, the purchased upgrade level, stable event/visit identity, eligible other-biome pool, and transition rule. Ordinary event frequency, destination weights, arrival position, and eligibility across resets remain open. Keep portal eligibility separate from the magnet-box unlock.

Generation context carries both the World+ world level and the biome's progression level within that world. The latter supports gentler difficulty increases within a world level, with higher biome levels yielding more gold. Exact scaling curves and advancement triggers remain open; a new visit does not automatically increase either level. Starting-portal appearance and destination should be reproducible for the same event, including at the guaranteed fifth upgrade level. Respawn and chained-portal entry rules remain open.

A validated teleport should establish the destination's generation context and a new level visit without counting the skipped space as travelled metres. Existing queued actions retain their original level and seed context for reconciliation.

Recommended validation contract: resolve one reproducible random outcome per consumed event using authoritative content/seed rules. Retrying or reconnecting must not reroll the same box's destination.

## Branching and Special Routes

The first version can be a single forward route. Later versions can add branches.

Branches can still use the same connector model:

- A tile can expose a main exit and an optional high exit.
- A cave entrance can transition into a cave tile pool.
- A cloud route can transition into a cloud tile pool.
- An underground path can transition into an underground tile pool.
- A boss approach can transition into a fixed or semi-fixed boss tile.

When branches affect rewards, the branch choice should be recorded or inferable for validation.

For MVP, do not use multiple seam exits. Optional high routes can exist inside a tile as reward opportunities, but the tile still has one main exit and one main entry. The low/main route must always be completable without advanced abilities.

## Authoring Constraints

Good tiles should be designed with clear contracts:

- The player can always traverse from entrance to at least one exit with the expected abilities.
- The main route can always be completed without optional advanced abilities.
- Reward groups are named and placed intentionally.
- Mutually exclusive rewards are marked.
- Required abilities are explicit.
- Enemy spawns are data-visible.
- The tile does not require impossible timing at the speed band where it appears.
- The exit row keeps the generator inside the allowed vertical range.

Tiles can still have flavor and surprises, but progression-bearing content must be visible to the data model.

## Prototype Scope

The first prototype should use a tiny tile library:

- One start tile.
- A few flat tiles with coins.
- A few jump tiles with raised coin lines.
- A few platform tiles with enemies.
- One simple connector height, such as row 2.
- One or two alternate connector heights after basic generation works.
- One blocking enemy tile.
- One boss approach or end tile.
- One special box tile after magnetism is unlocked.

The first technical milestone is simple: client and backend can independently generate the same tile id sequence from the same seed.

## Open Questions

- Should implementation distance use blocks or pixels as the canonical server unit?
- What connector rows should be allowed in the first zone beyond the MVP row 2 baseline?
- Which seeded RNG algorithm should be shared between Godot and Node.js?
- Should tile definitions live in Godot resources, shared JSON, or a content build step that exports to both?
- How much of a generated route should be stored versus derived on demand?
- What should the MVP boss threshold be: tile count or cumulative distance?
- Can upgrades change generation during a run, or only between generated segments?
