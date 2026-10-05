# Abilities and Powerups

This document defines the first ability and powerup model.

Special abilities become owned and usable immediately when discovered or earned from their boss/world reward. No initial shop purchase is required. Powerups are temporary effects found during play; discovering a powerup type can enable its future drops.

All discovered special abilities reset on ascension by default. Purchased ascension retention unlocks can keep covered abilities unlocked across ascensions. The retained roster, prices, and treatment of ability improvement levels remain open.

## MVP Scope

The MVP has two special systems:

- Speed boost.
- Magnetism.

Speed boost is an ability. Magnetism starts as a powerup drop.

## Special Upgrades Outside the Wealth Ladder

Wealth milestones make core wealth upgrades available for purchase. The player must buy level 1 before gaining an item's effects, then can purchase further levels. Special abilities come from bosses and discoveries in the game world and become usable immediately, without a separate purchase. The specific reward sources still need to be assigned.

The current special-upgrade ideas include:

- Throwing axes / Francisca Axe.
- Fireballs.
- A short sprint activated with a button, corresponding to the speed boost ability.
- Sapphire, ruby, and emerald coins.

These ideas extend the design; the first playable build's selection beyond speed boost and magnetism still needs to be scoped.

The specific attack behaviors below are provisional examples for the light-control direction, not a finalized combat specification. They can be refined during prototyping.

### Light Combat Controls

Attacks use simple range, position, targeting, and input-trigger rules rather than individual attack buttons:

| Attack | Trigger and Targeting |
| --- | --- |
| Melee swing | Automatically attacks immediately in front of the Viking. The existing core damage item is Viking Axe; the user's sword-swing example describes the same frontal melee role, not a separately confirmed weapon. |
| Throwing axes | Automatically target aerial mobs above the Viking when the attack is available and its targeting conditions are met. |
| Fireballs | Pressing jump while airborne triggers three fireballs in an arc once the ability is available. |

The player influences position and timing while attacks follow their own rules. Exact ranges, attack cadence, projectile behavior, and repeat-trigger limits remain tunable. A provisionally accepted interaction is that airborne jump input fires the volley and also produces a second jump only when double jump is owned. The previously specified sprint button remains a separate short movement burst.

### Thrown-Axe Combat

Francisca Axe belongs off the main wealth ladder. It increases thrown-axe damage and gold earned from thrown axes by a percentage. The current example automatically targets aerial mobs above the Viking. Discovering the ability grants immediate use. The specific reward source, range/cadence, and related-gold attribution remain open.

### Fireballs

Fireballs become usable immediately when discovered or earned from a boss. The current example fires three projectiles in an arc on airborne jump input, with an extra jump only if double jump is owned. This remains provisional. The specific reward source, cooldown or per-airtime limit, projectile angles and range, and damage scaling remain open.

### Gem Coins

Gem coins are special pickup upgrades with these stated values:

| Coin | Stated Gold Value |
| --- | ---: |
| Sapphire | 2g |
| Ruby | 3g |
| Emerald | 4g |

Whether these are base values before modifiers, which bosses or world discoveries unlock each type, and whether gems replace ordinary coins or appear alongside them remain open. Their introduction should add a visible progression reward outside the routine income-upgrade ladder.

## Ability vs Powerup

Ability:

- Has an unlock requirement.
- Becomes usable immediately on discovery or the relevant content reward; later upgrade rules are a separate design decision.
- Can be activated by the player or used according to ability rules.
- Can have cooldown, duration, and upgrade levels.

Powerup:

- Appears during play as a pickup or drop.
- Has a temporary effect.
- Usually does not require a shop purchase each time.
- Has spawn/drop rules that validation can check.

## Speed Boost

Speed boost is the first MVP ability.

Unlock flow:

```text
Complete speed secret route -> gain speed boost immediately -> use speed boost during runs
```

MVP behavior:

- Temporarily increases run speed.
- Activated by a player button for a short sprint.
- May increase reward rate indirectly by covering more route.
- Can help the player reach coins, enemies, or route opportunities faster.
- Should have cooldown and duration values.

Candidate first values:

| Field | Value |
| --- | ---: |
| Duration | 3 seconds |
| Cooldown | 20 seconds |
| Speed multiplier | 1.5x |

These are placeholders for feel testing.

## Magnetism

Magnetism is the first MVP powerup.

Unlock flow:

```text
Complete magnet secret route -> unlock magnet special boxes -> magnet boxes can appear during runs
```

MVP behavior:

- Pulls nearby coins toward the player.
- Lasts for a short duration.
- Appears from special boxes once unlocked.
- Is instantly picked up when the player headbutts the box.
- Does not need to be manually activated in the first version.

Candidate first values:

| Field | Value |
| --- | ---: |
| Duration | 5 seconds |
| Pickup radius | Prototype-dependent |
| Box appearance | Seeded chance from eligible special-box tiles |

The box appearance chance is intentionally rough. It should be data-driven so the backend can validate whether magnetism was possible in a segment.

## Discoverable, Stackable World Pickups

These pickups can be mushrooms, flowers, and other world objects, with the accessible feel of Mario-style pickups. Discovering a type unlocks it as a possible future drop. Collecting or taking a subsequent spawned pickup activates its effect. Keep discovered/drop-unlocked state separate from active effects; discovery alone does not imply a permanent active effect. Whether the first discovery also activates the effect remains open.

Mushrooms are discovered in the existing challenge rooms/courses. The room's mushroom reward unlocks future drops of that type. Which room grants each type remains open; flower and other pickup discovery sources are not yet assigned. See [Challenge Courses and Ability Unlocks](challenge-courses-and-ability-unlocks.md).

Pickup effects can stack, providing more enemies, multipliers, and special effects together. Collecting another copy of the same active item adds that pickup's full duration to the remaining duration; it does not merely reset the timer to its base duration. For example, 8 remaining duration units plus a pickup granting 20 units gives 28 remaining units. These numbers are illustrative, and the duration unit/value is defined per item.

Garden-grown and world-dropped versions are distinct items. Their copies of the same buff can run together with separate duration state. A world drop while the garden buff is active grants its own copy of that buff; further copies of the world item extend the world item's duration. They do not replace or extend the garden item. Exact numerical combination rules for overlapping buffs, any duration caps, and specific flower effects remain open.

Mushrooms specifically reveal Whacky World or Demon World. Whacky World is the surreal hallucination enemy overlay; Demon World is the demonic true overlay. These are layers over the current biome, and both can be active together. Real biome enemies are always present. Extra-layer enemies can damage the Viking, but mainly provide more targets and access to higher-grade materials. The broader multiplier/special-effect system can coexist with these mushroom effects. Exact types, sources, spawn chances, durations, and ascension rules remain open. See [Routes, Enemies, and Rewards](routes-enemies-and-rewards.md).

## Late-Game Cultivated Effects

Ascension unlocks enable late-game cultivation of mushrooms and similar items. Repeated use of an item unlocks its seeds; growing requires the appropriate cultivation/garden and seed requirements. Whether these appear as village buildings or simple permanent named garden upgrades remains open, as does the general-versus-per-item unlock structure. Cultivation allows corresponding mushroom world effects to stay active continuously for maximum gold farming, with extra enemies always available and both overlays able to coexist. Discovery/drop eligibility, use progress, seed unlocks, ordinary active pickups, and cultivation-supported availability are distinct states.

The player enables a simple Auto use toggle for a consumable. Whenever its current effect expires, another unit is consumed from stock to renew it. A garden item's expiry and stock use are independent of the corresponding world-drop item's duration. Their buffs can coexist. Exact seed-use thresholds, crops, growth rates, harvesting, durations, and offline behavior remain open. The cultivation ascension upgrade and unlocked seeds survive ascension; unfinished use progress, stock, active effects, and toggle retention remain unresolved. See [Progression and Economy](progression-and-economy.md).

## Ownership and Purchase States

Speed boost should use the ability unlock state model:

- `hidden`
- `locked`
- `owned`
- `upgraded`

Discovery or the relevant boss/course reward moves a special ability directly to `owned`. Any future paid improvements are distinct from initial acquisition. Wealth items instead progress from `locked` to `available_for_purchase` at their wealth bracket, then to `owned` when level 1 is purchased. Bracket entry itself grants no item effect.

Magnetism can use a simpler state for MVP:

- `locked`
- `box_unlocked`

Later, magnetism can become an upgradeable ability or shop-upgraded powerup.

## Validation Notes

The backend should validate:

- Speed boost ownership is supported by a valid speed-route completion or an owned ascension retention unlock.
- Speed boost activation is possible only when owned.
- Speed boost activation respects cooldown and duration.
- Magnet special boxes only occur after the magnet route unlock flag exists.
- Magnet activation is possible only after a generated box was hit.
- Magnet duration and coin collection boost remain within possible bounds.
- Special attacks have the required boss/world reward or ascension retention unlock and resulting ownership state.
- Attack rewards fit the finalized targeting, range, timing, and trigger rules. The current three-fireball example is provisional until the attack specification is fixed.

The client can show effects immediately, but durable rewards must fit backend validation.

## Open Questions

- Which ascension retention unlock preserves each ability, and does retention include improvement levels?

- Which boss or world discovery grants each special upgrade?
- What limits repeat fireball volleys, and does the provisional interaction with double jump feel good in playtesting?
- What ranges and attack cadences should frontal melee and automatic aerial axes use?
- Are gem values applied before coin/global multipliers, and how do gems appear among regular coins?
- How often should eligible special-box tiles appear after magnetism is unlocked?
- Should magnetism later become a shop-upgraded ability?
- Should speed boost affect validation by increasing possible route distance per segment?
