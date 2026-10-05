# Routes, Enemies, and Rewards

## Route Model

The game is a side-scroller with route opportunities. A route may include high and low platforms, branching lanes, optional pickups, enemies, hazards, and reward clusters.

Route choice matters for both game feel and validation. If a high platform contains one reward cluster and a low route contains another, the server should understand that a player could not collect both in the same segment unless the content explicitly allows it.

Routes should be built from authored tiles selected by deterministic generation. Each tile declares entrance and exit connector rows, such as an entrance on Y row 2 and an exit on Y row 2. The generator connects only compatible tiles, allowing the game to create an endless-feeling route while keeping the structure reproducible for validation.

The current direction is documented in [Tile Map Generation](tile-map-generation.md).

## Tile-Based Generation

The server creates a run session with a map seed. The Godot client and backend use the same content version, tile library, generation algorithm, and seed to produce the same tile sequence.

This means route content is random-feeling but not unknowable. The backend can reconstruct or bound-check the generated route without trusting the client to describe the whole map.

Core assumptions:

- Tiles are authored content pieces, not arbitrary procedural geometry.
- The MVP tile height is 15 blocks.
- Tile width can vary.
- Tile seams are controlled by entrance and exit connector rows.
- Early connector rows should stay within a tight vertical band so generation remains reliable.
- Tile metadata should include reward groups, enemy spawns, required abilities, and exclusivity rules.
- The server owns the map seed for each run session.

## Reward Opportunities

Reward opportunities can include:

- Coin lines.
- Enemy drops.
- Bonus pickups.
- Special box rewards.
- Secret route completions.
- Ability shop unlock flags.
- Ability-created rewards.
- Route-completion bonuses.
- Rare drops from specific enemy types.

Each reward opportunity should eventually have enough metadata for validation:

- Route segment or content id.
- Position or time window.
- Required route, lane, or platform.
- Required player capability.
- Reward type and value.
- Unlock flag granted, if the reward enables a future shop purchase.
- Special box id and seeded reward, if the reward comes from a box.
- Whether it can be collected with nearby opportunities.

## Enemy Model

Enemies are both obstacles and reward sources. Enemy health, spawn timing, reward value, and route placement should be documented in data rather than hidden in scene logic.

Validation needs to know whether the player could defeat each enemy during a reporting window. That depends on player power, ability usage, enemy health, enemy availability, and elapsed time.

### Hallucination and Enemy Layers

The enemy population has a permanent biome layer and two mushroom-dependent overlay layers. These are part of the world's fiction and visual identity:

| Layer | Identity | Confirmed Example |
| --- | --- | --- |
| Real-world biome layer | Creatures grounded in the current biome. | Lava snails in a volcanic biome, which the Viking can bounce on or strike with normal melee. |
| Whacky World (hallucination layer) | Surreal monsters with impossible or absurd forms. | Walking stone triangles with eyes on the triangular face/body and clown shoes. |
| Demon World (demonic true layer) | Reveals the demons of the world. | Red demon imps flying in the air above the Viking. |

Real-world biome enemies are always present. Mushrooms reveal Whacky World or Demon World over the current biome. The two overlays can coexist with each other and the base population. They are simultaneous layers of the current scene; World+ remains the separate world-difficulty progression system.

Mushrooms are first found in challenge rooms, using the existing [Challenge Courses and Ability Unlocks](challenge-courses-and-ability-unlocks.md) system. The flow is: discover the room's mushroom -> unlock that type for future drops -> an eligible mushroom can spawn during runs -> taking the drop triggers its associated enemy overlay. Finding the type establishes drop eligibility; it does not imply the layer stays active permanently. Whether the first discovery also immediately activates an effect remains open.

Mushrooms are part of a broader system of discoverable, stackable world pickups that also includes flowers and other forms. Stacked effects can add enemies, multipliers, and special effects together. Repeating the same pickup adds its full duration to the remaining duration. Garden-grown and world-dropped versions are different items, so the same buff can be active from both with independent durations. Mushroom world identity is specifically Whacky World or Demon World; exact flower/other pickup effects remain to be designed. Track discovered pickup types separately from active effects and revealed overlays. The exact roster, sources/chances, numerical stacking, and duration values remain open. Earlier potion and balm stat-buff ideas remain valid.

Overlay enemies can damage the Viking, but their main design purpose is more mobs to kill and access to higher-grade materials. Their inclusion should support the existing fast farming loop. Exact enemy stats, material types/grades, drop chances, and recipe uses remain to be designed; do not assign an automatic grade hierarchy to each layer yet.

In the late game, an ascension unlock enables cultivation. Repeatedly using a mushroom or other growable item unlocks its seeds. With both unlocks, the player can grow stock and enable Auto use, which consumes another unit whenever the current effect runs out. This can keep its mushroom world active continuously for maximum gold farming. The cultivation upgrade and unlocked seeds survive ascension. Exact use thresholds, growth rates, offline behavior, and retention of unfinished use progress, stock, and active effects remain open.

Recommended content model: keep enemy layer separate from biome, combat role, and movement type. Basic pack mobs, sustained epic fights, and bosses are existing combat roles; an enemy is not automatically a boss or stronger simply because it belongs to the demonic layer. Individual stats, rewards, resistances, and roles for the example creatures remain to be designed.

The snail's bounce interaction is confirmed, but whether bouncing damages it, defeats it, or only provides a jump surface remains open. Its normal melee interaction follows the game's automatic frontal attack direction; the example does not by itself add another gear slot or settle weapon naming. Airborne imps are compatible with the existing aerial-enemy direction, but their attack patterns and specific vulnerabilities are not yet specified.

When active mushroom effects change, the rules must define what happens to revealed enemies, existing fights, and rewards. The base biome population remains available throughout. Recommended behavior is that an unrevealed enemy cannot unexpectedly damage or block the player. This is a proposal, not a confirmed collision or reward rule. Mushroom effect duration and any relationship to the unresolved potion/balm expiration rules remain open.

Layer-related generation and reward rules must be data-visible. Candidate enemy metadata includes layer, biome, required mushroom effect, combat role, movement type, valid attack interactions, and gold/material reward definitions. Mushroom data also needs its discovery condition, future-drop eligibility, and effect mapping. Track discovery, generated drops, collection/use, and effect changes in event order so a later mushroom cannot retroactively justify earlier kills from an unavailable overlay. Base spawns must remain available independently of mushroom state.

Cultivation-supported Auto use provides another activation source by consuming grown stock when the preceding application expires. Continuous overlay activity must be valid when backed by legitimate stock and renewal events; it does not require repeated random drops. Owning cultivation or seeds alone does not justify activations without consumable stock.

## Mutually Exclusive Rewards

Some rewards should be impossible to collect together. Examples:

- High-route coin line versus low-route enemy pack.
- Left lane chest versus right lane rune pickup.
- A timing window that closes before both options can be reached.

The server can validate these constraints more easily if content data marks reward groups as mutually exclusive.

## Content Authoring Notes

When routes are authored, designers should identify:

- Entrance and exit connector rows.
- Main path rewards.
- Optional skill rewards.
- Mutually exclusive reward groups.
- Enemies that define power checks.
- Each enemy's layer and reveal condition, independently of its combat role and biome.
- Rewards that require abilities.
- Rewards that are decorative versus progression-bearing.
- Whether the tile belongs to the main path, cave pool, cloud pool, underground pool, boss approach, or another route type.
- Secret route entrances, their trigger positions, target courses, and completion rewards.
- Special box positions, unlock requirements, and seeded reward tables.

## Open Questions

- Which mushrooms reveal each overlay, and does a mushroom reveal an entire layer or particular enemy families?
- Which flowers and other pickup types provide multipliers or special effects, and how do their numerical effects stack?
- Which challenge room grants each mushroom, where can its later drops spawn, and how often?
- Does the first discovery also trigger an effect, and how long do subsequent mushroom effects last?
- What happens to overlay enemies, active fights, and rewards when the corresponding mushroom effect ends?
- Which higher-grade materials does each overlay enemy drop, and at what chance?
- Do overlays include their own epic enemies or bosses as well as ordinary mobs?
- Does bouncing on a lava snail damage or defeat it, or only provide a jump surface?

- What final tile grid size should be used?
- Which seeded RNG algorithm should be shared by Godot and the backend?
- How should optional high-route rewards be represented when the main route remains completable?
- Are there lane changes, jumps, attacks, or ability casts that affect collection?
- Should route metadata live in Godot resources, backend content data, shared JSON, or a content build step that exports to both?
