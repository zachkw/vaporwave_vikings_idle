# Core Gameplay Overview

This document is the primary gameplay overview for Vaporwave Vikings, Idle. It captures the main player experience before the design is split into deeper documents for economy math, enemy tuning, route authoring, shop structure, validation, and Godot implementation.

The goal is to keep the core game readable as a single idea: a Viking runs endlessly through side-scrolling worlds, earns gold through movement, coins, enemies, and bosses, spends that gold on upgrades, pushes farther through increasingly valuable content, then eventually ascends for permanent account power.

The short-term build target is defined in [MVP Scope](../production/mvp-scope.md).

## High-Level Game

Vaporwave Vikings, Idle is an auto-running side-scroller with idle RPG progression.

The player controls a Viking who constantly runs from left to right. The player does not directly steer every step, but they influence the run through jumps, timing, route choices, active abilities, upgrade purchases, and long-term build decisions. The action layer should feel light, readable, and satisfying. The idle layer should create fast compounding growth, frequent upgrades, and eventually enormous numbers.

The experience combines:

- Endless left-to-right running.
- Jumping and platforming to reach better rewards.
- Fast combat against common enemies.
- Occasional blocking enemies that stop progress until defeated.
- Bosses that gate worlds or zones.
- Coins, enemy rewards, passive gold, and special route rewards.
- An always-available shop for gear, upgrades, abilities, and multipliers.
- Repeatable gear purchases that improve combat stats or particular income sources.
- World progression with branches, caves, clouds, challenge paths, and bosses.
- Ascension resets that convert run progress into permanent account upgrades.

## Player Fantasy

The player is building an increasingly absurd neon Viking engine.

At the start, the Viking is simple: run, jump, collect coins, punch enemies, buy basic upgrades. Over time, the Viking becomes a high-speed gold machine with stronger gear, more movement options, better routes, more valuable enemies, temporary powerups, and permanent ascension bonuses.

The moment-to-moment fantasy is active and kinetic. The long-term fantasy is compounding power.

## Core Loop

The core loop is:

1. The Viking auto-runs through a side-scrolling route.
2. The player jumps, times abilities, chooses routes, and collects rewards.
3. Coins, passive movement, enemies, special pickups, and bosses generate gold.
4. Gold is spent in the shop on gear, power, gold generation, abilities, and multipliers.
5. Upgrades let the player kill faster, collect more, reach better routes, and defeat stronger blockers and bosses.
6. The player clears worlds, unlocks more content, and pushes into higher reward tiers.
7. When growth slows or an ascension threshold is reached, the player ascends.
8. Ascension resets run-level progress in exchange for permanent power.
9. The next run starts stronger and reaches higher numbers faster.

This loop should work at multiple scales. A few seconds should produce visible rewards. A few minutes should produce purchases. A longer session should produce new content, bosses, challenge routes, or meaningful ascension progress.

## Moment-to-Moment Play

The Viking always moves forward. Player attention is focused on timing and opportunity, not manual walking.

During normal play, the player should be watching for:

- Coin lines that reward jumping at the right time.
- Higher platforms with extra enemies or better pickups.
- Low routes with safer but lower-value rewards.
- Enemy packs that convert damage into gold.
- Blocking enemies that test whether current power is high enough.
- Bosses that stop world progression until defeated.
- Temporary powerups that change the next stretch of play.
- Challenge entrances such as caves, clouds, or underground paths.

The player should feel like they are constantly making small, understandable decisions:

- Jump now for coins or stay low for enemies.
- Use a movement ability now or save it for a better route.
- Push toward the boss or farm current content for upgrades.
- Buy damage to clear blockers or buy gold multipliers to scale faster.
- Enter a challenge route or stay on the main path.

## Movement and Abilities

The first playable version should start with a simple control model:

- Auto-run from left to right.
- Single jump.
- Collision with ground, platforms, coins, enemies, and blockers.
- Basic reward collection.

Movement can then expand through unlockable abilities:

- Double jump.
- Jump dash.
- Air flip or aerial trick.
- Short burst speed.
- Coin magnet.
- Temporary flight or glide.
- Other route-specific traversal upgrades.

Special abilities become usable immediately when discovered or earned from bosses or world content. For example, a cloud challenge course can grant double jump directly. All discovered abilities reset on ascension unless a purchased ascension retention unlock keeps them unlocked. Wealth-bracket items instead become available for purchase and require a paid first level before providing any effect.

Abilities can exist in several categories:

- Core movement abilities that become part of regular play.
- Active abilities with cooldowns.
- Temporary powerups found during routes.
- Challenge rewards that last for the current run.
- Ascension upgrades that preserve or enhance selected abilities permanently.

The design should avoid giving the player too many buttons too early. Early play should be understandable, while later play can become more expressive as players unlock tools and learn the route language.

## Combat

Combat should be fast and readable. Most enemies are reward sources, not long tactical fights.

Monsters belong to three layers: biome-grounded real-world enemies, surreal hallucination enemies, and the demonic true layer. Real biome enemies are always present; the mushrooms the Viking takes determine which additional layers overlay them. Hallucination and demonic layers can coexist. Volcanic lava snails can be bounced on or struck with melee; walking stone triangles have eyes on their face/body and clown shoes; red demon imps fly above the Viking in the demonic layer. Exact mushroom mappings and effect durations remain open. These layers are separate from the combat roles below. Detailed direction lives in [Routes, Enemies, and Rewards](routes-enemies-and-rewards.md).

Discoverable world pickups include mushrooms, flowers, and other forms. Finding a type unlocks possible future drops, whose effects activate when taken and can stack to add enemies, multipliers, or special effects. Mushrooms specifically reveal Whacky World (the surreal hallucination layer) or Demon World (the demonic true layer); both can overlay the current biome together. These enemies can hurt the Viking, but mainly provide more mobs to kill and access to higher-grade materials. Discovery/drop eligibility and currently active effects are separate states. Exact flower/other pickup effects, numerical stacking, and durations remain open.

Collecting the same pickup again adds its full duration to that item's remaining duration. Garden-grown and world-dropped versions are different items: both can apply the same buff concurrently with separate durations. Numerical combination of those buffs remains to be tuned.

Cultivation is unlocked through ascension, and repeatedly using each mushroom or other growable item unlocks its seeds. The cultivation unlock and unlocked seeds survive ascension. Having both lets the player grow stock and enable a simple Auto use toggle, consuming another unit whenever that garden item's effect expires to maintain the extra enemy layers for gold farming. World pickups do not extend or replace its effect. Exact thresholds, growth rates, durations, and retention of unfinished use progress or stock remain open; see [Progression and Economy](progression-and-economy.md).

The late-game production unlocks may be presented as a village with gardens and breweries, or as simple permanent ascension entries such as "[Mushroom Name] Garden". Both remain options; the village interface and building-management mechanics are not yet committed.

Enemy roles:

- Basic mobs appear in packs and are killed in one hit, providing frequent gold without prolonged fights.
- Platform mobs encourage jumping onto optional paths.
- Dense enemy packs or hordes create high-reward moments.
- Larger epic enemies stop the Viking for a fight.
- Bosses are larger fights that gate progression or content; the exact gate is content-specific.
- Advanced enemies can be unlocked later through ascension or world progression.

Combat uses light controls with automatic or contextual attack rules. Current examples are automatic frontal melee, throwing axes targeting aerial mobs above, and three fireballs in an arc on airborne jump input. The provisionally accepted fireball interaction adds a second jump only when double jump is owned. These examples are not a finalized combat specification: exact triggers, attack rates, ranges, and repeat limits remain open to playtesting.

The Viking has health, can take damage, and can die. Combat tests damage output and survivability, including health and defence. Health regenerates gradually but generously out of combat, and resurrection restores full health. Upgrades should eventually make previously lethal encounters survivable. Gear supplies defensive upgrades: a chest piece increases health and defence. Exact regeneration rates and defence formulas remain tuning decisions.

Boss health resets fully between attempts. Repeated deaths cannot chip away at a boss across attempts.

### Unattended Play, Death, and Respawn

With the game open and no player input, the Viking keeps running, fighting, and accumulating wealth. Death automatically restarts the current level after a brief resurrection, then running resumes immediately without a confirmation screen.

Death preserves accumulated gold and purchased upgrades. It is a small interruption to farming, not a progression reset; ascension remains the separate reset mechanic. Repeated deaths should still let the player accumulate wealth and buy the upgrades needed to survive.

The intended pace is fast, with quick resurrection and immediate movement. Exact respawn timing and time-to-first-upgrade, boss victory, and ascension remain tuning questions. This describes unattended play with the game open.

### Connectivity and Time Away

Normal active play requires internet. Routine progress checkpoints occur every two minutes to keep operating costs low. Intermittent signal, including underground journeys where the player can checkpoint at stops, should have approximately 1-2 minutes of tolerance. The proposed implementation adds that allowance after a checkpoint is due, permitting up to 3-4 minutes of provisional progress since the last successful checkpoint; the recommended two-minute retry allowance is not yet confirmed. Waiting behavior after the allowance expires remains open.

With the app closed, players earn gold only at a reduced rate, checked against real-world elapsed time when they return. Earnings are uncapped, with declining rates across 0-12, 12-24, 24-48, 48-168, and 168+ hours. Exact percentages remain open. Players do not automatically defeat bosses, advance levels, discover abilities, or purchase upgrades. Later automation upgrades, most likely through ascension, can expand those capabilities.

Opening the game and completing a server-validated return/reward claim resets the away-income schedule to the first band. No minimum active-play session is required; the previous absence is settled before the reset applies.

There are two independent return systems: a conventional daily login bonus with a consecutive-day streak, and an optional rewarded ad that doubles an individual banked away-gold payout. The daily bonus needs no ad; ad completion does not change the streak or double the daily reward. Exact daily rewards, cycle length, presentation, and ad integration remain open. Normal away gold remains available without watching an ad.

The important early question is not whether combat is deep. It is whether combat creates a satisfying economy rhythm:

- Weak enemies melt quickly.
- Stronger enemies reveal when the player needs upgrades.
- Blocking enemies create short power checks.
- Bosses create meaningful progression gates.

## Rewards

Gold is the primary reward and the main fuel for progression.

Gold can come from:

- Passive gold generated while running.
- Coins placed along routes.
- Coins or gold dropped by enemies.
- Platform enemy rewards.
- Blocking enemy rewards.
- Boss rewards.
- Challenge course rewards.
- Temporary powerup effects.
- Multipliers from gear, shop upgrades, and ascension upgrades.

Coins should start small and quickly become more valuable. Early coins might be worth a few gold. Soon they should be worth tens, hundreds, thousands, and eventually much larger values. The game should embrace idle-scale number growth, including millions, billions, trillions, and scientific notation.

The exact formulas should be defined in economy math documents later. This overview only commits to the intended shape:

- Frequent early rewards.
- Rapid early upgrade cadence.
- Exponential-feeling growth across tiers.
- Clear boundaries where new worlds, bosses, enemies, or ascension become relevant.
- Large numbers that feel exciting but remain validatable.

## Shop and Upgrades

The shop should always be available to the player. The player should be able to spend gold without feeling like they have left the game.

The gear menu uses rows: gear icon and effect description, current level, and a button on the right to buy the next level. The button shows the next purchase cost and is green when the player has enough gold or red when they do not. Buying updates the item's level, price, and all affected affordability states immediately. See [Gear Progression](gear-progression.md) for the detailed shop behavior.

An Unlocks section shows everything found and unlocked through discovery in the world, such as earned abilities and discovered mushroom/powerup types. Keep discovery availability distinct from an active consumable effect when showing status.

Show a badge for each biome beaten in the current World+ world level. These badges communicate progress through this world; earlier-world clears do not count toward the current set. Exact badge placement and whether unbeaten biomes appear as empty outlines remain open.

The shop is expected to include multiple upgrade categories:

- Gear upgrades.
- Damage upgrades.
- Gold generation upgrades.
- Coin value upgrades.
- Enemy reward upgrades.
- Ability unlocks.
- Ability improvements.
- Powerup duration or strength upgrades.
- Boss damage or blocker-clearing upgrades.

Gear is a classic idle progression layer. All purchased bonuses remain active together. Buying the same item again increases its level, with a higher price for each successive level; level 100 Gloves represents 100 purchased levels. Each piece contributes its own stats rather than every piece increasing damage.

Gear is the core repeatable upgrade path. The opening set presents three clear choices: Viking Axe increases axe-swing damage, Chest increases toughness and health, and Helmet increases gold from all sources. Players choose damage, survival, or income as they work toward beating the boss. Exact starting availability, costs, and values remain open.

Later wealth brackets primarily introduce income upgrades: gold per metre, gold from all sources, coin value, and monster-kill gold. Gloves, Hunting Axe, Golden Amulet, and shoulder pads are examples of income-focused pieces. Repeated effects are intentional. Gold per metre is part of this direction; whether there is also a separate time-based passive source remains open.

Special upgrades come from bosses and discoveries in the game world, outside the main wealth ladder: Francisca throwing axes, fireballs, a button-activated short sprint, and sapphire/ruby/emerald coins worth 2g/3g/4g. Special abilities become usable immediately on discovery, with no initial shop purchase. Specific reward sources, attack details, and gem reward modifier rules remain open. Francisca's damage and related-gold bonuses belong to this special progression path.

Gear pieces become available at milestones measured against gold currently held, with closely spaced early brackets around `10x` apart, gradually widening toward `1,000x` between later unlocks and continuing to approximately `10^30` gold. The first level must still be bought before its bonus applies. The exact ladder and whether unpurchased items stay available after spending below a reached threshold remain open. Purchased bonuses stay active when gold is spent. This replaces the earlier prior-piece-level requirements and fixed twenty-piece target.

Later levels offer higher gold rewards. Players should choose between upgrading combat stats to reach those richer levels and upgrading income in the content they can already farm. The initial three roles are settled; later content, stat values, and unlock thresholds remain open.

Detailed gear direction lives in [Gear Progression](gear-progression.md).

Non-gear upgrades can provide focused progression effects, such as:

- Increase all coin value by 50%.
- Increase passive running gold.
- Increase gold from enemies.
- Increase boss damage.
- Increase powerup duration.
- Unlock double jump.
- Unlock dash.
- Improve magnet strength.

Entering a wealth bracket makes its item available to buy; the player must purchase level 1 to gain the first effect. Special abilities earned through exploration or content completion are granted directly instead.

The shop should create regular decisions between immediate power and long-term scaling. Damage helps push forward. Gold multipliers help the next upgrades arrive faster. Abilities open better routes and challenge content.

## World and Route Progression

The game progresses automatically through its level sequence, then supports repeat runs and optional random travel between biomes.

Routes are expected to be assembled from authored tiles using deterministic generation. The server issues the map seed for a run, and the client and backend use the same seed, tile library, and generation algorithm so both sides can reproduce the same route.

Each world can contain:

- Main running routes.
- Side routes.
- High and low platform paths.
- Caves.
- Cloud routes.
- Underground routes.
- Challenge courses.
- Enemy packs.
- Blocking enemies.
- A final boss.

The player runs through a level until its boss. The boss is a combat check of damage output, health, and toughness. Defeating it automatically advances the player to the next level. If the Viking dies, the current level restarts quickly with gold and purchased upgrades intact, and automatic running resumes.

World+ advances the player through world levels, with the sequence to clear again at the next world level. Within each world level, content also becomes a little harder through gentler progression. Biomes have progression levels, and higher biome levels provide more gold. World level and within-world biome progression are distinct; exact scaling curves and advancement triggers remain open.

Portal travel becomes available after the full clear, letting the player revisit content and resources rather than only retry a stronger final boss. The player can enter an available portal or leave it unused; the destination remains another random biome. In addition to the earlier random teleport-box encounter, an ascension upgrade increases the chance of a portal at the start of a biome through five levels: 20%, 40%, 60%, 80%, and 100%. This changes portal availability, not destination choice. Ordinary event frequency, arrival rules, and portal eligibility across resets remain open.

World+ advances automatically after clearing the current world's level sequence: gold, gear levels, and abilities carry into the next world level, whose higher gold rewards encourage continued progress. The player eventually reaches a practical ceiling based on the Chest and Viking Axe upgrades affordable in their current wealth bracket, then ascends and repeats with permanent ascension benefits. Ascension resets run and world progression under the established ability-retention rules. World+ itself does not award ascension points or reset the build. Exact ceiling balance remains open.

Worlds should create both content progression and economy progression:

- New visual themes.
- Stronger enemies.
- Higher coin values.
- More valuable platforms.
- New enemy types.
- New challenge routes.
- New shop unlocks.
- New ascension hooks.

Branching routes should matter. A high route might contain more coins, while a lower route might contain more enemies. A cave might be more dangerous but more profitable. A cloud route might require stronger jumping ability. These route choices are also important for validation because the game needs to understand which rewards could realistically be collected together.

## Challenge Courses

Challenge courses are optional skill-focused routes inside worlds.

Examples:

- A cave entrance that leads to a tighter platforming section.
- A cloud path that requires precise jumping.
- An underground passage unlocked by an ascension upgrade.
- A timed route full of coins, enemies, or powerups.
- A horde route with unusually dense enemy rewards.

Challenge courses should be more intense than normal running. They can ask the player to use timing, jumping, dashing, double jumping, or other abilities more carefully.

Rewards from challenge courses can include:

- Run-level abilities granted for immediate use.
- Mushroom discoveries that unlock future drops of the type; taking those later drops activates Whacky World or Demon World overlays.
- Run-level passive upgrades.
- Strong temporary powerups.
- Higher-value enemy or coin clusters.
- New powerup types.
- Access to better routes.

The ability reward pattern is discovery or course completion followed by immediate use. No gold purchase is required to activate the earned ability.

"Permanent" challenge rewards should usually mean permanent for the current run. By default, these rewards reset on ascension. Ascension upgrades can later allow selected rewards, abilities, shop unlocks, or route unlocks to persist across runs.

## Temporary Powerups

Biome resources also support potions, balms, and similar consumables. Both potions and balms can increase damage and other stats. Balms make the Viking's skin glow; potions can raise hallucinations, increasing enemies seen or encountered and multipliers. The user described permanent buffs alongside consumption after a set distance, so whether effects expire, persist, or combine both remains unresolved. Detailed open lifecycle rules are recorded in [Progression and Economy](progression-and-economy.md).

Temporary powerups can appear in routes, challenges, enemy rewards, or special events.

Examples:

- Super speed for a short duration.
- Coin magnet for a short duration.
- Temporary flight.
- Double coin value.
- Triple coin spawns.
- Enemy horde event.
- Bonus damage burst.
- Special route reveal.

Powerups should create short spikes in attention and income. They are useful because they make the run feel more dynamic without requiring every base system to be complicated.

Powerups must eventually have validation rules. The backend will need to know how often they can appear, how long they can last, and how much reward they can reasonably create.

## Ascension

Ascension is the major prestige system.

The first ascension is offered when the player beats World+1, targeting a few play sessions. Ascending is optional and separate from automatic World+ advancement. Later ascension eligibility remains to be defined.

On ascension, the player sacrifices run-level progression:

- Current gold, gear levels, and normal run-level shop upgrades reset.
- Discovered abilities reset unless a purchased ascension retention unlock preserves them.
- World progression and run-level challenge completion flags reset.
- Purchased ascension upgrades, banked unspent points, lifetime point progress, and unlocked cultivation seeds remain. Other consumable and resource retention rules still need design.

Total gold earned across the account lifetime builds pending ascension points. The gold increment required for each successive point keeps increasing indefinitely, including across ascensions. Buying gear does not erase earned-gold progress. Ascending banks pending points once; lifetime progress and previously banked unspent points are retained. Banked points can be spent whenever the player chooses, without another reset.

Ascension points are spent on permanent upgrades, such as:

- Repeatable global gold/CPS increase.
- Permanently double all coin value.
- Permanently increase all gold generation.
- Keep a movement ability unlocked after ascension.
- Unlock advanced enemies with better rewards.
- Unlock underground paths.
- Improve starting damage.
- Improve starting passive income.
- Increase powerup spawn chance.
- Increase challenge course rewards.
- Reduce upgrade cost scaling.

Ascension should make the next run feel dramatically faster. The player should return to earlier content with enough power to smash through old boundaries and reach new tiers.

For the MVP, ascension should start with one repeatable upgrade that increases global gold/CPS by `+5%` per level.

## Progression Layers

The game has several progression layers that should support each other.

Run progression:

- Gold earned during the current run.
- Shop upgrades bought during the current run.
- Gear and ability levels for the current run.
- Challenge rewards that last until ascension.
- World and boss progress for the current run.

World progression:

- Clearing bosses.
- Unlocking new worlds.
- Discovering branches, caves, clouds, and special routes.
- Reaching higher-value enemies and rewards.

Ascension progression:

- Earning ascension points.
- Buying permanent upgrades.
- Unlocking content that reshapes future runs.
- Permanently accelerating the early and mid game.

Account progression:

- Long-term player profile.
- Permanent unlocks.
- Content versions and progression history.
- Future systems such as achievements, collections, events, or cosmetics.

The design should be careful about which layer each reward belongs to. A reward that resets on ascension creates run momentum. A reward that survives ascension creates account momentum.

## Economy Direction

The economy should scale from tiny values to enormous idle-game values.

The intended feeling:

- Start near zero with small passive gold income.
- First coins are worth a few gold.
- Early upgrades arrive quickly.
- Coin and enemy values reach hundreds and thousands soon.
- Midgame values move into millions and billions.
- Long-term values reach trillions and beyond.
- Scientific notation becomes necessary at high tiers.

The economy will need dedicated math packs and tuning tables. Those should define:

- Passive gold per second.
- Coin value curves.
- Enemy reward curves.
- Upgrade cost curves.
- Gear level curves.
- Boss health and damage requirements.
- Ascension point formulas.
- Run duration expectations.
- Reward caps for validation.

For now, the core commitment is that numbers should climb aggressively, but every source of growth should be traceable to content, upgrades, abilities, or ascension.

## Validation Direction

Progression should eventually be server-authorized. The game client can play smoothly and responsively, but durable rewards should be checked before becoming authoritative.

This matters because the game contains:

- Large gold numbers.
- Upgrade purchases.
- Route-based rewards.
- Mutually exclusive paths.
- Ability-limited rewards.
- Temporary powerups.
- Boss gates.
- Ascension rewards.

Validation will need to answer questions like:

- Could this player have reached this route?
- Could this player have collected these coins together?
- Could this player have killed these enemies in the reported time?
- Were these powerups possible in this segment?
- Did the player have the required ability or upgrade?
- Is the reported gold within expected bounds?
- Is the ascension reward consistent with the run state?

The detailed validation system belongs in technical documentation. This gameplay overview only establishes that route, reward, enemy, ability, and economy data should be designed with validation in mind.

## First Prototype Target

The first Godot prototype should focus on feel, then quickly grow into the one-zone MVP defined in [MVP Scope](../production/mvp-scope.md).

The minimum useful prototype:

- Auto-running Viking.
- Ground and platforms.
- Jump input.
- Coin pickup.
- Passive gold gain while running.
- One basic enemy type.
- Basic enemy defeat and gold reward.
- Player health, incoming damage, death, and automatic quick respawn on the same level.
- One blocking enemy or simple power check.
- A small always-available upgrade panel.
- One damage upgrade.
- One coin or passive gold upgrade.
- Large-number display foundation.

The next prototype layer:

- Double jump or dash.
- High-route versus low-route rewards.
- First boss gate.
- First temporary powerup.
- First challenge entrance.
- Simple run report data for validation planning.

This keeps the first build focused on whether running, jumping, collecting, killing, earning, and upgrading already feel good.

The MVP target expands this to one zone, two enemies, one boss, the three core gear choices, two secret routes, speed boost, magnetism, backend sessions, validation, and ascension. The extent of the later gear ladder and thrown-axe combat included in the first playable build still needs to be scoped.

## Documentation Breakout Plan

This document should remain the readable source-of-truth for the core game. Detailed systems should split into dedicated documents as they become concrete.

Likely next design documents:

- Movement and abilities.
- Combat and enemy roles.
- Worlds, routes, and horizontal progression.
- Tile map generation.
- Challenge courses.
- Ability unlocks and shop prerequisites.
- Shop and gear.
- Gear progression and cost scaling.
- Economy math packs.
- Ascension and prestige.
- Powerups and temporary modifiers.
- Content tables for enemies, coins, worlds, bosses, upgrades, and abilities.
- Validation rules tied to route and reward data.

The guiding rule: this document says what the game is. Breakout documents say exactly how each part works.

## Current Open Questions

- What is the exact first-session upgrade cadence?
- What regeneration rate and defence formula best support fast recovery and meaningful combat upgrades?
- How many levels should the first build contain to demonstrate automatic advancement and the repeat loop?
- How often do ordinary route portals appear, where does the player arrive, and what advances biome levels within a world level?
- How do World+ advancement and ascension affect portal eligibility?
- Do combat gear pieces also provide gold bonuses, and do unpurchased items remain available after spending below a reached wallet threshold?
- How much world progress resets on ascension?
- Which abilities are normal shop unlocks versus challenge rewards?
- Which abilities can become permanently retained through ascension?
- Should gear reset every ascension, or should some gear systems live at account level?
- How authored should each tile be versus how much variation should tile selection rules create?
- How often should challenge entrances appear?
- What retry allowance and waiting-state behavior should accompany the confirmed two-minute checkpoint cadence, and what closed-app gold percentages/reference rate should be used?
- What session length and economy curve make the first World+1 clear arrive after a few sessions?
