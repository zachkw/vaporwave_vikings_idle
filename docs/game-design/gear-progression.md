# Gear Progression

This document defines the core gear progression model.

Gear is the bread-and-butter gold sink. Other upgrades can be more interesting, more specific, or more unlock-driven, but gear is the thing players should buy constantly across a run.

## Design Goal

The gear system should support:

- Simple repeatable purchases.
- Hundreds of levels per gear piece over time.
- A clear idle-style progression ladder.
- Three clear opening choices: Viking Axe for damage, Chest for survival, and Helmet for gold.
- Later gear unlocks at wealth brackets, with an approximate long-term endpoint around `10^30` gold rather than a fixed piece count.
- Global gold bonuses and bonuses for specific reward sources or attacks.
- A damage increase that helps clear enemies, blockers, and bosses faster.
- Health and defence upgrades that make sustained epic and boss fights survivable.
- Wealth-based gear unlocks so each new piece becomes a meaningful milestone.
- Later room for special gear effects without complicating the MVP.

The gear system should feel like a reliable engine: spend gold, get stronger, earn faster, push farther, repeat.

## Naming Direction

Gear pieces have distinct stat roles. Stable numbered identifiers can remain useful internally, but the displayed equipment should communicate what the player is buying.

Use stable data identifiers and named stat roles. The opening set is Viking Axe, Chest, and Helmet. After those essentials, the main wealth ladder largely supplies repeatable income upgrades: gold per metre, all-source gold, coin value, and monster-kill gold. Gloves are an example of the latter. Repeated effects on different pieces are intentional; every new wealth-bracket item does not need a new mechanic.

Gameplay-changing upgrades such as Francisca throwing axes belong off the main wealth ladder and come from bosses or discoveries in the game world. Discovered special abilities are immediately usable, with no initial purchase. Wealth-bracket items only become purchasable at their milestone; level 1 must be bought before their effects apply. Specific special reward sources and provisional attack examples are covered in [Abilities and Powerups](abilities-and-powerups.md).

## Reference Pattern

Idle Slayer is the main reference for the first-pass structure.

Useful patterns from public Idle Slayer references:

- Equipment is purchased from the shop and has repeatable levels.
- Equipment increases coin-per-second style income.
- The most recently unlocked equipment often becomes the best target for income growth.
- Equipment has milestone upgrades around level 10, then later level intervals.
- Some upgrades are unlocked by reaching specific equipment levels.
- Ascension adds broad CpS bonuses on top of run-level equipment.

References:

- [Idle Slayer Equipment](https://idleslayer.fandom.com/wiki/Equipment)
- [Idle Slayer Equipment Strategy](https://idleslayer.fandom.com/wiki/Equipment_Strategy)
- [Idle Slayer Upgrades](https://idleslayer.fandom.com/wiki/Upgrades)
- [Idle Slayer Ascension Strategy](https://idleslayer.fandom.com/wiki/Ascension_Strategy)

We are using these as design references, not as exact copied content. Vaporwave Vikings, Idle adds gear-driven damage because combat blockers and bosses are part of the runner loop.

## Opening Gear and Later Unlocks

The opening progression has three core pieces. Whether all three are available immediately or introduced through the earliest unlocks is still open. The first playable slice should prove the choice between damage, survival, and income; the number of later wealth-bracket items included in that slice remains a scope decision.

The earlier equal-gold-and-damage output table and prior-piece-level unlocks are superseded. Gear has distinct combat and income roles, and new pieces unlock as the player's wealth increases.

The earlier five-piece cost table is superseded pending tuning for this opening set and the wealth ladder. Unlock thresholds and purchase prices are separate content values. Wealth milestones use gold currently held in the wallet, not earnings since ascension or lifetime earnings. Entering a bracket grants purchase eligibility, not ownership or a free level; the player must buy the first level. Whether an unpurchased item remains available after spending below its threshold is still open. Purchased levels and their bonuses are retained when gold is spent.

Confirmed stat roles:

| Piece | Role |
| --- | --- |
| Chest | Increases toughness and health. |
| Viking Axe | Increases damage of axe swings. |
| Helmet | Increases gold from all sources by a percentage. |

Later gear roles:

| Piece | Role |
| --- | --- |
| Gloves | Increase gold from killing monsters. |

Francisca Axe is a special upgrade off the main wealth ladder and becomes usable immediately on discovery. Its example effect is increased thrown-axe damage and related gold, with automatic targeting of aerial mobs above the Viking. Specific reward source, final attack behavior, range/cadence, and gold attribution remain open.

Earlier examples for further progression are Hunting Axe (enemy-kill gold), Golden Amulet / necklace (coin value only), and shoulder pads (passive gold generation). Overlapping effects are allowed. These do not add extra choices to the initial three-piece set.

The example shoulder-pad bonus of `+10%` is illustrative, not a committed per-level value. Gear can increase reward values or their multipliers. Exact amounts, stacking rules, and boss/enemy reward categories still need to be defined.

Gold per metre is one of the intended income bonuses on the wealth ladder. Whether passive gold also includes a separate time-based source remains open.

Later levels provide higher gold rewards. Combat and survival upgrades help reach those levels, while gold-focused gear improves current income. Purchase choices should reflect that tradeoff rather than making the newest piece universally best.

## Wealth-Bracket Progression

New gear should arrive at increasing wealth brackets:

- Begin with close brackets, roughly one order of magnitude apart (`10x`, or a `+1` increase in the base-10 exponent).
- Gradually widen the spacing toward three orders of magnitude (`1,000x`, or `+3` in the exponent).
- Continue at roughly that later cadence toward `10^30` gold or a similarly large tuning target.
- Introduce the three essential pieces early, then add income-focused items across later brackets.
- Reuse effects across different pieces to extend the ladder without requiring a unique mechanic for every unlock.
- Place gameplay-changing upgrades such as throwing axes, fireballs, sprint, and gem coins outside the routine wealth-bracket ladder.

The exact exponent sequence, transition point, starting thresholds, and final piece count remain to be tuned. This bracket spacing controls discovery of new gear; it is separate from the repeat-purchase cost curve for levelling an existing piece.

The central spending choice remains: buy Viking Axe damage, Chest survival, or Helmet income to earn enough power to beat the boss and reach richer levels. Because milestones use gold currently held, spending before reaching the next bracket competes with saving for it. Later income pieces expand that progression, while special unlocks add new ways to play.

World+ keeps the current run's gold, gear levels, and abilities while increasing world difficulty. The player's current wealth bracket limits affordable Chest and Viking Axe progression, eventually producing a practical ceiling that encourages ascension and another run. Exact cost/stat/enemy curves remain open; this does not specify a hard gear-level cap or a new equipment-tier system.

All purchased gear bonuses remain active together; there is no equipment-slot selection or replacement requirement. Repeated purchases level up the same item rather than creating separate inventory copies. Level 100 Gloves means 100 purchased levels of Gloves, with each successive level costing more. This confirms persistent bonuses during normal play; ascension reset rules remain a separate design decision.

## Cost Formula

Each successive level costs more than the previous one. The exact growth rate remains a tuning choice; the current candidate curve is:

```text
next_level_cost = base_cost * 1.15 ^ current_level
```

Where:

- `base_cost` is the cost of level 1.
- `current_level` is the number of levels already purchased.
- `next_level_cost` is rounded to a readable integer or notation value.

Bulk purchase total:

```text
bulk_cost(level, count) =
  base_cost * (1.15 ^ level) * ((1.15 ^ count - 1) / (1.15 - 1))
```

This lets the shop support buy 1, buy 10, buy 50, and max affordable without summing every level one at a time.

## Gear Output Formula

Each gear piece contributes to its assigned stats, reward sources, and attack types. A contribution can be zero: a gold-only necklace does not also grant damage. Keep global income bonuses separate from coin, monster-kill, thrown-axe-attributed, and passive income bonuses. Repeated effects from different pieces are allowed, but their stacking formula remains open. A possible formula shape is shown below; exact stat scaling, stacking, health, and defence conversion remain to be defined.

```text
gear_gold_power[source] =
  sum(gear_level[i] * gold_power_per_level[i][source] * milestone_multiplier[i])

gear_damage_power =
  sum(gear_level[i] * damage_power_per_level[i] * milestone_multiplier[i])
```

For MVP, the milestone multiplier starts at `1` and increases when the player buys milestone upgrades for that gear piece.

## Milestone Upgrades

Gear milestone upgrades are separate shop purchases unlocked by reaching gear levels.

MVP milestone rhythm:

- Level 10 unlocks the first milestone upgrade.
- Level 50 unlocks the second milestone upgrade.
- Level 100 unlocks the third milestone upgrade.
- Later milestones can continue every 50 levels.

For the MVP, milestone upgrades can use a simple `+100%` to that gear piece's output.

Illustrative example for a piece with coin-value power (not a final assignment for Gear 1):

```text
Gear 1 level 100
Gear 1 base coin-value power per level = 0.1
Milestone upgrades bought at 10, 50, and 100
Each milestone gives +100%

gear_1_multiplier = 1 + 1 + 1 + 1 = 4
gear_1_coin_power = 100 * 0.1 * 4 = 40
```

Milestones should be purchased with gold, not granted automatically, unless we decide later that automatic milestones feel better.

## Global and Source-Specific Gold Bonuses

Gear can increase all gold income or target a particular source, according to the piece's explicit stat role:

- Helmet increases gold from all sources.
- Gloves increase gold from monster kills.
- Later wealth-bracket items can increase gold per metre.
- Hunting Axe increases gold earned from killing enemies.
- Golden Amulet increases the value of collected coins.
- Shoulder pads increase passive gold generation.

Off the main ladder, Francisca improves thrown-axe damage and gold attributed to those attacks. It uses the same explicit modifier rules when evaluating a reward, even though it is unlocked through a separate progression path.

Later levels have higher base rewards; gear bonuses apply to the appropriate source at the current level. Whether enemy-gold bonuses include bosses, and how challenge rewards are classified, remain open.

Candidate multiplier representation:

```text
gear_multiplier[source] = 1 + gear_gold_power[source] * gear_gold_scale[source]

final_gold[source] =
  base_gold_for_level_and_source
  * gear_multiplier[source]
  * global_gear_gold_multiplier
  * ascension_gold_multiplier
  * applicable_temporary_multipliers
```

This is a proposed representation, not a final stacking rule. Gear may modify base reward values or percentages; flat additions, additive percentage bonuses, and multiplicative effects need explicit rules before implementation. Global gear bonuses, source-specific gear bonuses, and the existing global ascension bonus remain separately identifiable. Thrown-axe rewards need an attribution rule when multiple attack types damage the same monster; matching several bonuses must not create duplicate base rewards. The basis for passive generation is also unresolved.

## Damage

Our main addition to the Idle Slayer-style gear model is damage.

Candidate MVP formula:

```text
damage_multiplier = 1 + gear_damage_power * gear_damage_scale
damage_per_second = base_damage_per_second * damage_multiplier
```

For the first prototype, `gear_damage_scale` can be small if direct equality makes blockers melt too quickly.

Enemy kill time:

```text
time_to_kill = enemy_health / damage_per_second
```

This creates a direct link between gear and route pace. If damage is low, blockers hold the player in place. If damage is high, blockers become short pauses or disappear almost immediately.

## Blocking Mobs and Efficiency

Blocking mobs are the clearest reason gear needs damage.

If a player reaches a blocker with too little damage, they spend longer attacking it and lose forward movement, route rewards, and gold per minute. The Viking can also take damage and die if survivability is insufficient. Death quickly restarts the current level while retaining gold and purchased upgrades, so farming continues across attempts.

Gear upgrades support surviving previously lethal encounters as well as killing faster. Chest gear provides health and defence; the exact defensive values and formulas remain to be defined. Health regenerates gradually but generously out of combat, and resurrection restores full health. Boss health fully resets between attempts, so repeated deaths cannot substitute for sufficient combat stats.

Gear therefore has two kinds of value:

- Direct value: stronger rewards from the income sources a piece improves.
- Indirect value: combat and survival upgrades improve route pace and open later levels with higher gold rewards.

The shop should make this obvious. If the player is stuck on blockers, buying gear should feel like the remedy.

## Ascension Relationship

Gear is run-level progression by default and resets on ascension.

Ascension bonuses sit on top of gear. They should not replace the gear loop; they make each new run reach the gear ladder faster.

Idle Slayer's public ascension strategy references a broad CpS bonus based on total Slayer Points, roughly `+1% CpS per Slayer Point`, with later upgrades modifying that total.

For our MVP, use one repeatable ascension upgrade:

```text
ascension_gold_multiplier = 1 + ascension_cps_upgrade_level * 0.05
```

Each level gives `+5%` global gold/CPS. This is intentionally simple and can stack forever for the first prototype.

## Shop UX

Gear should be easy to buy repeatedly.

The confirmed gear menu is a list of rows. Each row contains the gear icon, a description of its effects, the current level, and a right-aligned button that buys the next level and displays its cost. Include the item's name with the description so the row is easy to identify.

For an available gear item, the buy button is green when current gold covers the next-level cost, and red when it does not. Keep the cost visible in both states. Each successful purchase adds one level to that item, spends its current price, and immediately refreshes the level, next cost, and affordability of all visible rows. Level 0 uses the same button to buy level 1 once the item is available.

Recommended behavior: keep an unaffordable red button visible but disabled, with its unavailable state also exposed to accessibility tools. Compare the full currency values for affordability rather than rounded display notation. Wealth-locked items still follow their eligibility rules; their exact reveal/locked-row presentation remains open.

Expected shop features:

- Show the gear icon, name, effect description, and current level in each row.
- Show the next-level cost on the buy button at the right, using green/red affordability states.
- Show milestone upgrade availability.
- Make the opening choice explicit: damage (Viking Axe), survival (Chest), or income (Helmet).
- For later pieces, show the affected source or attack, such as monster gold, coin value, thrown-axe damage/rewards, or passive income.
- Show current contribution to damage.
- Show health and defence contributions where applicable.
- Show the next gear unlock requirement.
- The confirmed default is one next-level purchase per button press. Bulk modes such as buy 10, buy 50, and max affordable remain optional later enhancements; they are not required additions to this row layout.
- Make each piece's combat or income role clear so players can choose upgrades for their current obstacle.

The shop should let gear buying become a satisfying rhythm rather than tedious tapping.

## Reset Rules

Default assumption: gear levels and gear milestone upgrades are run-level progression and reset on ascension.

Ascension upgrades can later modify this:

- Start each run with Gear 1 level 10.
- Keep Gear 2 unlocked after ascension.
- Increase all gear stat contribution permanently.
- Reduce gear cost growth.
- Keep a percentage of gear levels.

These permanent effects should feel powerful because gear is the main gold sink.

## Data Model Direction

Each gear piece should be data-driven.

Candidate fields:

| Field | Purpose |
| --- | --- |
| `gear_id` | Stable id, such as `gear_001`. |
| `display_name` | Player-facing name, if assigned. |
| `order_index` | Position in the gear ladder. |
| `unlock_requirement` | Milestone threshold measured against gold currently held. |
| `base_cost` | Cost for first level. |
| `cost_growth_rate` | Candidate value: `1.15`; increasing costs are confirmed, exact rate is tunable. |
| `level` | Current run-level purchase count. |
| `gold_power_per_level` | Candidate map of income contributions by source or attack attribution. Exact modifier representation is TBD. |
| `global_gold_bonus_per_level` | Candidate field for pieces such as helmets that increase all gold sources. Stacking rules are TBD. |
| `damage_power_per_level` | Damage contribution keyed by attack type, such as axe swings or thrown axes. Exact representation is TBD. |
| `health_power_per_level` | Health contribution from pieces with that role; conversion formula TBD. |
| `defence_power_per_level` | Defence contribution from pieces with that role; mitigation formula TBD. |
| `milestone_unlocks` | Level-gated purchases that multiply this gear piece. |
| `tier_labels` | Optional labels based on level bands. |

The backend should compute costs and validate purchases from this data. The client can preview costs and stats, but the server owns the final purchase result.

## Prototype Scope

The first prototype should implement:

- Three opening pieces: Viking Axe, Chest, and Helmet.
- Further gear made available through increasing current-wallet gold thresholds, with a paid first level.
- All owned gear bonuses active together; repeat purchases increase the item's level.
- Increasing level costs, provisionally scaling with `1.15 ^ current_level`.
- Gear income bonuses by reward source from levels and milestone upgrades.
- Gear damage power from levels and milestone upgrades.
- Global gold modifiers and separate source/attack calculations for later pieces as those enter scope.
- Damage multiplier from gear.
- Health and defence upgrades on appropriate pieces.
- A simple blocker whose stall time changes visibly with damage.
- Row-based gear menu with icon, effect description, current level, and right-aligned next-level buy button displaying its cost in green when affordable or red when not. Milestone presentation remains a separate detail.

The first implementation does not need rare gear, inventory drops, randomized stats, crafting, sockets, or gear affixes.

## Open Questions

- What starting costs and stat gains make the three opening choices compelling?
- Should gear milestone upgrades be automatic, purchased separately, or unlocked for purchase?
- Are all three opening pieces immediately available, or introduced through early wealth unlocks?
- What exact wealth brackets transition from `10x` to `1,000x`, and how much of the ladder belongs in the first playable build?
- Once a wallet milestone is reached, does an unpurchased item remain available if spending lowers the balance below the threshold?
- Which pieces combine combat stats with source-specific income bonuses?
- Is there a time-based passive income source in addition to gold per metre?
- Which boss/world event grants thrown axes, and how is their gold attributed when attacks overlap?
- How do flat value increases and percentage bonuses stack, and which enemy bonuses apply to bosses?
- What should `gear_damage_scale` be?
- What health scaling and defence formula should gear use?
- How quickly should the first later item unlock after the opening trio?
- How much gear progress should ascension reset by default?
- Should gear level achievements exist in the MVP, or wait until later?
