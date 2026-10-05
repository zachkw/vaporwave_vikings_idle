# Level Design

This document defines how playable level content is structured.

Tile generation explains how the route is assembled. Level design explains what the player experiences inside that route: zone structure, tile roles, enemy placement, secret routes, reward pacing, and boss gates.

## Design Goal

Levels should feel like endless runner routes with authored moments.

The player should see:

- A readable main route.
- Coins placed to invite jumps.
- Enemies placed as gold sources and damage checks.
- Blocking mobs that slow progress when damage is low.
- Secret route entrances that reward attention and skill.
- A boss that caps the zone.

The route can be generated, but the individual beats should be designed.

## MVP Zone

The MVP has one zone.

The zone should prove:

- Running feels good.
- Jumping feels useful.
- Coins are satisfying to collect.
- Gear purchases visibly improve income.
- Gear damage visibly improves enemy clear speed.
- Secret routes grant immediately usable special abilities or unlock powerup types.
- A boss can gate progress.
- The backend can validate route, rewards, combat, and progression.

The MVP zone does not need multiple biomes, a world map, or long-term route variety.

## Scale and Coordinates

The working MVP tile height is 15 blocks.

Design coordinates should use block-grid positions:

- X is horizontal distance across generated tiles.
- Y is vertical block row.
- Tile widths can vary.
- Tile height stays 15 blocks for MVP.
- Implementation can convert blocks to pixels, such as 16 by 16 pixels per block.

The first tile set can mostly use a simple row 2 entry and row 2 exit. The data model should still support tiles that enter at one Y row and exit at another, such as row 2 to row 7.

Changing exit height does not move the camera or transform the world. It means the tile ends with the main floor at a different vertical row, so the next tile must start at that row.

## MVP Tile Roles

The first tile set should be small but complete.

Minimum tile roles:

| Tile Role | Purpose |
| --- | --- |
| Start tile | Safe entry into the generated route. |
| Basic ground tile A | Simple running and baseline coin placement. |
| Basic ground tile B | Slight visual or reward variation. |
| Coin-line tile | Teaches jump timing for coins. |
| Simple jump tile | Teaches platforming without heavy punishment. |
| Enemy 1 tile | Places weak mobs as frequent gold. |
| Enemy 2 tile | Places tougher mobs as damage checks. |
| Blocker tile | Stops or slows the player until enough damage is dealt. |
| Special box tile | Contains a hit-from-below powerup box after magnetism is unlocked. |
| Speed secret entrance tile | Contains entrance to speed boost challenge route. |
| Magnet secret entrance tile | Contains entrance to magnet challenge route. |
| Boss approach tile | Signals the upcoming zone boss. |
| Boss tile | Contains the zone boss gate. |

Only two basic ground tiles are required to start route generation. The other roles can be added as the MVP grows.

## Tile Generation Relationship

The level should be assembled from authored tiles using deterministic generation.

Generation rules live in [Tile Map Generation](tile-map-generation.md). The level design layer should decide:

- Which tile roles are allowed in the MVP zone.
- How often reward tiles appear.
- How often enemy tiles appear.
- How early secret route entrances can appear.
- Whether boss tiles appear after distance, tile count, or progression.
- Which tiles are allowed before and after secret routes.

The backend should be able to reproduce the selected tile sequence from the server-issued map seed.

Tiles should be grouped into pools so common tiles appear often and special tiles appear less often.

Candidate MVP pools:

- Main basic.
- Main reward.
- Main enemy.
- Main blocker.
- Special box.
- Secret entrance.
- Boss approach.
- Boss.
- Speed secret route.
- Magnet secret route.

Each pool can use weights, cooldowns, and minimum-distance rules.

## Main Route Pacing

The main route should start simple.

Early route pacing:

1. Safe start tile.
2. Basic ground and coin-line tiles.
3. Weak enemy tile.
4. Jump tile.
5. Tougher enemy tile.
6. Gear pressure through a blocker.
7. Secret route entrance opportunities.
8. Boss approach.
9. Boss gate.

The exact order can be generated, but the first run should not feel chaotic. Early generated routes need guardrails so the player learns the systems in a sensible order.

The main route must always be completable without optional advanced abilities. High routes, upper coin lines, and bonus platforms can require better movement, but the low route should always keep the run moving.

This is not meant to be hard Mario-style platforming. The choice is light and reward-driven: take the safer low path, or jump toward the upper path for more coins, enemies, boxes, or route opportunities.

## Enemies

The broader enemy design has three layers: biome-grounded real-world creatures, surreal hallucination monsters, and the demonic true layer. Real biome enemies are always present. The mushrooms the player takes determine which extra layers overlay the biome, and both extra layers can appear together. Examples are volcanic lava snails that can be bounced on or hit with melee, walking stone triangles with eyes and clown shoes, and red flying demon imps. Exact mushroom-to-enemy mappings, effect duration, and detailed combat/reward rules remain open. Keep these layers distinct from basic/epic/boss roles when authoring content. See [Routes, Enemies, and Rewards](routes-enemies-and-rewards.md).

Mushrooms reveal Whacky World or Demon World over the current biome; both can coexist. Their first discovery comes from the existing challenge rooms/courses, unlocking future drops of that mushroom type. They belong to a broader family of discoverable pickups including flowers and other forms. Taking later drops activates their effects, which can stack to add enemies, multipliers, and special effects. Extra-layer enemies can damage the Viking, but mainly add targets to kill and access to higher-grade materials. Exact room-to-mushroom assignments, later drop sources, other pickup effects, stacking values, and material tables remain open.

The MVP has two regular enemies and one boss.

Which layers the first build demonstrates and which example creatures fill its roles remain unscoped; the three-layer direction does not automatically expand the initial enemy roster.

Enemy 1:

- Weak common mob.
- Appears in packs killed in one hit.
- Frequent gold reward.
- Teaches combat feedback.

Enemy 2:

- Larger epic enemy that stops the Viking for a fight.
- Better gold reward.
- Teaches damage scaling.

Boss:

- Larger than epic enemies and gates progression or content; currently planned as the end-of-zone gate in the MVP.
- Tests damage output, health, and toughness through combat.
- Awards a significant reward.
- Can be used as an ascension readiness signal if needed.

Epic enemies provide the stopping-and-fighting behavior previously described as blockers. Basic packs provide quick kills; epics and bosses provide sustained combat checks.

The broader combat design also includes aerial mobs above the Viking, targeted automatically by unlocked throwing axes. Frontal melee attacks automatically cover short range ahead; unlocked fireballs shoot three in an arc on jump input while airborne. Enemy positions and ranges should support these light, contextual attack rules. Aerial content's inclusion in the first two-enemy MVP set remains a scope decision.

The Viking can take damage and die. With no player input, running and combat continue; death quickly restarts the current level and movement resumes automatically. Accumulated gold and purchased upgrades persist, so repeated attempts continue to build wealth. Health regenerates gradually but generously out of combat, and resurrection restores full health. Gear provides health and defence upgrades so previously lethal encounters become survivable. Exact regeneration and defence formulas remain open.

Later levels offer higher gold rewards. Reaching them should reward strategic investment in damage and survival. How this multi-level progression fits the initial one-zone scope is still to be decided.

## Coins and Rewards

Coin placement should teach jumping.

Reward patterns:

- Ground coins for baseline collection.
- Jump arcs that guide timing.
- Higher coin lines that are easy to miss without jumping.
- Enemy rewards that make combat feel profitable.
- Secret route rewards that grant special abilities or powerup types.

Coins and enemy rewards should be data-visible for validation.

Some rewards can be visible before they are reachable. For example, a high coin line might require double jump or speed boost to collect efficiently. These should be marked with `required_abilities`, but they should never block route completion.

## Special Boxes

Special boxes are hit-from-below blocks that release a powerup.

For MVP:

- Special boxes begin appearing after magnetism is unlocked.
- The first box reward is magnetism.
- Hitting the box pops the powerup out.
- The player instantly picks up the powerup.
- The box and reward are determined by tile data and seed.

Boxes should be data-visible so validation can check that a box existed and that the claimed powerup was possible.

After all levels have been cleared, portals provide optional travel to another random biome. The earlier teleport-box event is the working route encounter for this travel system; its final presentation remains open. Portal eligibility is separate from magnetism. An ascension upgrade adds a portal at a biome's start with a chance of 20%, 40%, 60%, 80%, or 100% at its five levels. The player chooses whether to enter, not the destination. Ordinary route-event frequency, arrival location, and how eligibility interacts with resets remain open. See the repeat progression rules below.

## Secret Routes

The MVP has two secret routes.

Speed route:

- Entered from a special tile.
- Requires more precise jumping than the main route.
- Completion grants speed boost for immediate use without a shop purchase.

Magnet route:

- Entered from a different special tile.
- Can focus on coins, timing, or route discovery.
- Completion unlocks magnet special boxes.
- Magnet powerup pulls coins toward the player for a short duration.

Detailed secret route and ability unlock rules live in [Challenge Courses and Ability Unlocks](challenge-courses-and-ability-unlocks.md).

Secret route entrances should be random but controlled. For MVP, each secret route entrance should be guaranteed to appear after a minimum distance if the player has not completed it, but extra appearances can occur if the player gets lucky.

## Boss Gate

The boss should cap the MVP zone.

The first boss does not need complex attack patterns. It needs to test:

- Has the player bought enough gear?
- Does damage scaling matter?
- Can the Viking survive incoming damage long enough to win?
- Does the player understand the shop loop?
- Can the backend validate a boss clear?

The boss is a fight resolved through damage and survivability, not a separate countdown-based DPS challenge. If the Viking dies, the level restarts quickly, accumulated gold and purchased upgrades are retained, and automatic running resumes. Death should be a brief interruption rather than a significant penalty.

MVP boss placement should be threshold-based. After the generator passes a configured tile count or cumulative distance, the next appropriate tile should be the boss approach, followed by the boss tile.

Boss health resets fully on every new attempt. Defeating a level boss automatically advances to the next level. Route generation on death/restart is still to be decided: the level could reuse its route or generate another attempt from a new seed or seed position.

## Completing the Sequence and Replaying Levels

World+ advances automatically when the current world's level sequence is cleared, carrying the current build into the next world level to clear the sequence again. Higher-world gold rewards encourage this continued push. Within a given world level, content also becomes a little harder through gentler progression. These are two distinct difficulty scales, rather than a single endlessly repeating difficulty curve. Biomes have progression levels, and higher biome levels earn more gold. Exact world and biome difficulty/reward curves and the trigger for increasing a biome's level remain open. Do not assume every visit or teleport increases either level. Replays provide opportunities to gather resources and find special unlocks missed during earlier visits. The first optional ascension offer arrives on beating World+1, targeting a few play sessions.

Biome resources are used for potions, balms, and similar consumables. Both can increase damage and other stats. Balms produce glowing skin; potions can raise hallucinations, increasing enemies seen or encountered and multipliers. Resource distribution and collection rules remain open. Consumable duration and distance-based consumption still need clarification; see [Progression and Economy](progression-and-economy.md).

Clearing the full sequence makes portal travel available. Its purpose is to let the player revisit content and farm resources instead of only repeating losses against a stronger final boss. The player may enter an available portal or ignore it; the destination is another random biome, with no destination selection. The earlier random route-event appearance remains distinct from the ascension upgrade's biome-start opportunity.

The biome-start portal upgrade has five levels, adding 20 percentage points of appearance chance per level: 20%, 40%, 60%, 80%, then 100%. At maximum level, an eligible biome start always has a portal. This changes appearance probability, not destination selection. Exact upgrade costs, ordinary route-event frequency, destination weighting, and arrival location remain open. Whether a respawn or portal arrival creates another starting-portal opportunity also needs a rule.

World+ advances the world level within the same run and requires clearing the sequence again while keeping current gold, gear levels, and ability ownership. Players eventually reach a practical ceiling set by the Chest and Viking Axe strength affordable in their wealth bracket. They can then ascend, reset run progression, and repeat with permanent ascension benefits. Exact ceiling balance remains open; a hard gear-level cap is not specified. Whether portal eligibility is carried into a new world level or must be re-earned is still open, separately from eligibility after ascension. Do not assume the starting-portal upgrade bypasses these prerequisites.

The number of levels in the first build remains a scope decision. World+ progression, gentler difficulty growth within a world level, and increased gold at higher biome levels are confirmed directions; numerical tuning remains open. World level, biome progression level, full-clear history, and current visit identity should be distinct so teleporting does not implicitly advance difficulty or grant first-clear rewards again.

The UI shows a badge for each biome beaten in the current World+ world level. A newly entered world level has its own biome-clear set; previous-world clears do not earn its badges. Repeated clears of an already beaten biome do not add duplicate badges. The rule for when a multi-level biome counts as beaten, if biomes contain multiple levels, still needs to be defined. Badge artwork, placement, and unbeaten placeholders remain open.

## Validation Requirements

Level content should expose enough data for validation:

- Tile id.
- Tile role.
- Tile pool.
- Tile width.
- Cumulative X range.
- Connector rows.
- Coin group ids.
- Special box ids and rewards.
- Enemy spawn ids.
- Enemy layer and mushroom reveal conditions, with base biome enemies always available and overlay eligibility derived from active mushroom effects.
- Enemy health and rewards.
- Enemy damage and attack timing, plus player health, toughness, recovery, and respawn rules once defined.
- Blocker ids.
- Secret route entrance ids.
- Secret route target ids.
- Boss id.
- Mutually exclusive reward groups.
- Required abilities for optional rewards.
- World level, biome progression level, and their enemy-strength and gold-reward modifiers.
- Level-clear prerequisites, owned starting-portal upgrade level, and eligible destinations for portal events.

If a reward changes progression, the backend needs to know it existed and was plausible.

## Open Questions

- Should the boss appear after a fixed tile count or when the player reaches a gold/damage threshold?
- Should the boss threshold be measured in tile count, block distance, or both?
- What minimum distance should guarantee each secret route entrance?
- Should the MVP route be deterministic but tutorial-like for the first run?
- Should boss failure always generate a fresh route, or can it reuse the same seed for another attempt?
- How many levels should the first build include to demonstrate automatic advancement and replays?
- How often do ordinary route portals appear, how are other biomes weighted, and where does the player arrive?
- What advances biome levels within a world level, and what difficulty and gold-growth curves apply at each scale?
- How should the first ascension offer appear alongside automatic advancement after clearing World+1?
- What enemy and upgrade-cost curves establish the Chest/Axe progression ceiling before ascension?
- Does portal eligibility survive World+ advancement, ascension, both, or neither?
- Do respawns and portal arrivals count as fresh biome starts for the five-level portal upgrade?
- Should blocker tiles be rare special checks or regular pacing beats?
