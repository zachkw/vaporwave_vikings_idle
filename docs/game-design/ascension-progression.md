# Ascension Progression

This document defines the first ascension model.

Ascension is the prestige layer. The player sacrifices run-level progress, earns ascension points, and spends those points on permanent upgrades that make future runs stronger.

World+ advances difficulty within the current run and preserves current gold, gear levels, and ability ownership. The player pushes through world levels until the Chest and Viking Axe progression affordable in their current wealth bracket reaches a practical combat ceiling, then ascends and repeats with permanent ascension benefits. World+ advancement itself does not perform an ascension reset or award ascension points. The exact balance that produces this ceiling remains to be tuned; no hard gear-level cap has been specified.

## First Ascension and World+ Pacing

The first ascension should be offered after a few play sessions, when the player beats World+1. Keep this exact world label until the world-numbering display is finalized. Reaching that milestone offers the option to ascend; it does not force the reset.

World+ advances automatically when the current world's level sequence is cleared. Higher-world gold rewards are intended to make this automatic push worthwhile. Gold, gear, and abilities carry forward until the player chooses to ascend. The first offer and automatic World+ transition must coexist without turning world advancement into a manual choice. Eligibility for later ascensions and exact session length remain to be tuned.

## MVP Goal

The MVP should include a complete but simple ascension loop:

```text
Earn gold -> clear World+1 and receive the first ascension offer -> ascend and bank pending points -> restart stronger; spend banked points whenever desired
```

The goal is not perfect long-term balance yet. The goal is to prove that reset-and-return feels good.

## Reference Pattern

Idle Slayer's public strategy guidance describes ascension as a broad CpS progression layer. It references an Ascension CpS bonus based on total Slayer Points, roughly `+1% CpS per Slayer Point`, with later upgrades modifying that total.

Reference:

- [Idle Slayer Ascension Strategy](https://idleslayer.fandom.com/wiki/Ascension_Strategy)

For our MVP, use the same broad idea but make it simpler: ascension points buy one repeatable upgrade that increases global gold/CPS by `+5%` per level.

## What Resets

Default MVP ascension reset:

- Current run gold.
- Gear levels.
- Gear milestone upgrades.
- Normal shop upgrades.
- All discovered special ability ownership, including speed boost, throwing axes, and fireballs, except where a purchased ascension retention unlock explicitly preserves an ability.
- Magnet unlock state.
- Secret route completion flags.
- Current World+ world level, zone progress, and boss clear state, restarting the run's world progression.

The player keeps:

- Account identity.
- Total ascension points earned.
- Unspent ascension points.
- Purchased ascension upgrade levels.
- Unlocked cultivation seeds.
- Abilities covered by purchased ascension retention unlocks.
- Other content unlocks only where an explicit permanent rule applies.

The confirmed ability rule is reset by default: discovered abilities must be earned again after ascension unless an ascension unlock keeps them unlocked. Retention upgrades are part of the intended progression. Their roster, costs, prerequisites, and inclusion in the first playable build remain open. Keeping an ability unlocked does not yet specify whether purchased improvements to that ability also carry over.

Biome ingredients, potion/balm inventory, and their effects need their own ascension rules once the consumable lifecycle is clarified. Do not infer those rules from ability retention.

Cultivation is confirmed as an ascension unlock and follows the permanent-upgrade rules. Its seeds are earned separately by repeatedly using each growable item, and unlocked seeds survive ascension. Whether unfinished per-item use counts, crops, resources, stock, active effects, and Auto use preferences survive ascension remains open.

## Ascension Points

Ascension points are based on total gold earned across the account lifetime. Each successive point requires a larger gold increment, and that requirement keeps increasing indefinitely. Ascension does not restart the requirement or lifetime earned-gold progress. Spending wallet gold on gear does not reduce that progress, and spending points does not make later points cheaper. The exact starting requirement and growth curve remain to be tuned.

Keep two balances distinct:

- Pending points earned through gold progression, previewed during the run and cashed in on ascension.
- Banked unspent points, credited on ascension and available to spend whenever the player chooses, including during a later active run.

Spending banked points does not require another ascension. Ascension must credit pending points once, preserve previously unspent points, and mark the claimed progress so it cannot be cashed in again. Lifetime earned-gold progress, including progress toward the next point, stays on the account through the reset.

Recommended bookkeeping: derive total point entitlement from the configured lifetime gold thresholds, then subtract all points previously banked to obtain pending points. Use the total ever banked, not the current unspent balance, so buying upgrades cannot make spent points claimable again.

The earlier square-root formula and example gold thresholds were provisional and are superseded as the specification. Use the final configured increment curve once designed. Which reward categories count as earned gold, including return and ad rewards, remains to be explicitly defined.

## MVP Ascension Upgrade

The MVP has one repeatable ascension upgrade:

| Upgrade | Cost | Effect |
| --- | ---: | --- |
| Global Gold Training | 1 ascension point per level initially. | `+5%` global gold/CPS per level. |

First formula:

```text
ascension_gold_multiplier = 1 + ascension_upgrade_level * 0.05
```

Example:

| Upgrade Level | Multiplier |
| ---: | ---: |
| 0 | 1.00x |
| 1 | 1.05x |
| 5 | 1.25x |
| 10 | 1.50x |
| 20 | 2.00x |

The cost can become more expensive later, but a flat cost is acceptable for the first MVP if it helps us test the loop quickly.

## Biome-Start Portal Upgrade

An ascension upgrade increases the chance of finding a portal at the start of a biome. It has five levels, each adding 20 percentage points:

| Upgrade Level | Starting-Portal Chance |
| ---: | ---: |
| 1 | 20% |
| 2 | 40% |
| 3 | 60% |
| 4 | 80% |
| 5 | 100% |

At level 5, an eligible biome start always provides a portal. The portal remains optional to use and still leads to another random biome. This chance is separate from ordinary random travel encounters along the route. Upgrade costs and prerequisites remain open, including whether it changes the normal all-levels-cleared requirement. The first build's inclusion of this upgrade is unscoped.

World+ advances automatically through world levels within the same run, preserving gold, gear levels, and abilities while presenting the sequence to clear again with more valuable gold rewards. Within each world level, content also gets a little harder through gentler progression. World+ and within-world growth need separate state and tuning. Ascension is the separate chosen run reset, first offered on beating World+1 after a few sessions. Portal eligibility and the handling of within-world biome levels across transitions still need explicit rules.

## Cultivation Unlock

Ascension unlocks growing mushrooms and similar items in the late game. This may use one general cultivation upgrade, permanent per-item upgrades named "[Mushroom Name] Garden", or a combination; the structure remains open. Each item's seeds are unlocked through repeated use of that item. Growing requires the appropriate ascension unlock and seed requirement, with their exact relationship to individual garden upgrades still to be designed.

This progression supports continuously active mushroom worlds for maximum gold farming. A simple Auto use toggle consumes another unit from stock whenever the current effect expires. The cultivation upgrade and unlocked seeds survive ascension. Upgrade cost and prerequisites, seed-use thresholds, crop mechanics, and retention of unfinished use progress, crops, stock, and active effects remain open. Whether seed progress can accumulate before cultivation is bought also remains to be decided.

The user is considering either a village with gardens, breweries, and similar production buildings or a simpler list of named permanent ascension upgrades. Neither presentation is selected. Do not require building placement or a village-management loop for the confirmed cultivation and Auto use progression. See [Progression and Economy](progression-and-economy.md).

## Future Automation Upgrades

Closed-app progression initially earns gold only. Later upgrades may automate activities such as boss progression or discoveries; ascension is the likely home for these unlocks, but that placement and the exact capabilities are not yet final. Automation is outside the current single-upgrade MVP and must be explicitly earned before it affects time-away progression.

## Reward Formula Placement

Ascension should multiply after gear.

Candidate reward formula:

```text
final_gold =
  base_gold
  * gear_multiplier_for_reward_source
  * global_gear_gold_multiplier
  * ascension_gold_multiplier
  * temporary_multipliers
```

Gear bonuses may target a specific source, such as coins, enemy rewards, or gold per metre, or apply globally as with the helmet. Ascension remains a separately identifiable global bonus. This means gear remains the main run-level engine, while ascension makes every new run accelerate. The formula above is a candidate; exact stacking rules are still to be defined.

## Validation Notes

The backend should own ascension.

It should validate:

- The run session exists.
- Gold counted toward points comes from accepted earned-gold events under the configured eligibility and increment rules.
- The first ascension offer is supported by a World+1 clear.
- Pending points match the configured increasing lifetime increment curve and are credited to the unspent bank exactly once per ascension; previously banked points cannot be claimed again.
- Lifetime earned-gold progress and the next-point requirement survive ascension and point spending.
- Run-level state is reset correctly.
- Permanent ascension upgrade levels are preserved.
- Only abilities covered by purchased retention unlocks remain available after the reset; other discovered abilities reset.
- Upgrade costs are paid from banked points, which can be spent outside the ascension/reset transaction.

The client can preview ascension rewards, but the backend commits them.

## Open Questions

- What starting gold increment and growth curve should the endlessly increasing lifetime point requirements use?
- Which gold reward categories count toward lifetime point progress?
- What eligibility applies to later ascensions after the first World+1 offer?
- Should the first ascension upgrade cost remain flat or scale?
- Which abilities or powerup-type unlocks does each retention upgrade preserve, and at what cost?
- Does an ability retention upgrade preserve only availability or also ability improvement levels?
- How are within-world biome levels and portal eligibility handled on World+ advancement and ascension?
- What upgrade-cost and enemy-scaling curves make the Chest/Axe ceiling a satisfying reason to ascend?
- What are the five starting-portal upgrade prices and prerequisites?
