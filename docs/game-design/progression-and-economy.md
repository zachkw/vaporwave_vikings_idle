# Progression and Economy

## Primary Resource

Gold is the primary resource. It is earned from coins, defeated enemies, and possibly end-of-segment rewards. Gold is spent on upgrades that increase power, ability effectiveness, gear strength, and gold generation.

## Biome Resources, Potions, and Balms

Biome-specific resources are used for potions, balms, and similar consumables. This is a confirmed purpose for revisiting biomes. Exact ingredients, collection sources, recipes, costs, and the crafting or application interface remain open.

- Balms make the Viking's skin glow and can increase damage and other character stats. Strengths, other affected stats, and visual variations remain to be defined.
- Potions can also increase damage and other stats. Hallucination effects increase the number of enemies seen or encountered and boost multipliers. Exact effects on spawning, combat, enemy rewards, and multiplier categories remain to be defined; potions are not restricted to income effects.
- Consumption is tied to a specified amount of distance travelled. Exact distances and the meaning of consumption are not yet settled.

Discoverable world pickups include mushrooms, flowers, and other forms. Discovering a type unlocks future drops; taking a subsequent spawned pickup activates its effect. Effects stack to provide more enemies, multipliers, and special effects together. Mushrooms specifically reveal Whacky World or Demon World, the surreal and demonic overlays, which can coexist while real biome enemies remain present. These enemies can damage the Viking, but their main purpose is more mobs to kill and access to higher-grade materials. Track discovered pickup types separately from active effects. Exact sources, flower/other effect mappings, material tables, and durations remain open. Preserve the separate confirmed possibility of potion/balm damage and other stat buffs. See [Routes, Enemies, and Rewards](routes-enemies-and-rewards.md).

For cultivated pickups, continuous late-game availability is maintained by automatic reuse when each application expires. It is sustained by consumable stock. Exact per-item duration values and the duration basis for ordinary mushroom/flower pickups remain open. Earlier potion/balm distance-based duration and any separate lasting stat bonuses still need their own precise definitions.

Mushroom discovery comes from the existing challenge rooms/courses. A room's discovery reward unlocks that type's future drops; its active effect is triggered by taking a drop. Exact room assignments and subsequent drop rates remain open. Flower and other pickup discovery sources remain unassigned.

Multiple pickup effects can coexist and stack. Repeating the same item adds its full duration to the remaining duration. Garden-grown and world-dropped versions are different items and can each apply the same buff concurrently, with independent durations. World pickups extend the world item's effect rather than the garden item's effect. Exact additive/multiplicative formulas for concurrent buffs, limits, death, teleport distance, closed-app behavior, and ascension handling remain open. The first playable build's inclusion of this system is also unscoped. Additional enemies and multipliers must be represented in shared content rules so validation can accept their legitimate rewards.

## Late-Game Cultivation

Cultivation is unlocked through the ascension system. Seeds for each mushroom or other growable item are unlocked by using that item repeatedly. Growing requires the appropriate cultivation/garden unlock and the item's seed unlock. Whether ascension provides one general cultivation unlock, individual gardens, or a combination remains open, along with exact use thresholds and costs.

The progression is mushroom discovery in challenge rooms, eligibility for random drops, repeated use unlocking the corresponding seeds, then cultivation with the appropriate ascension and seed requirements met. Cultivation lets players keep the mushroom worlds active continuously for maximum gold farming. Whacky World and Demon World can remain active together alongside real biome enemies, providing reliable access to more mobs and higher-grade materials.

Track qualifying uses and seed unlocks by item type, separately from first discovery and currently active effects. The confirmed UI is a simple Auto use toggle for the consumable. While enabled, when its own active effect runs out, consume another unit from stock and reapply that effect, independently of any world-dropped version's buff. Different enabled items can maintain their effects together. Exact crops, resources, recipes, costs, yields, growth rates, harvesting, and per-use duration remain open.

Recommended toggle behavior: if enabled while no effect is active, use one available unit immediately; if stock is empty, keep the preference enabled and wait for more stock; turning it off lets the current application finish. These edge behaviors are proposals. Never consume another unit merely because an application is still active. The confirmed renewal point is effect expiry.

The purchased cultivation ascension unlock and unlocked seeds survive ascension. Retention of unfinished use-count progress, crops, stock, active effects, and the Auto use preference remains open, as does whether uses count before the cultivation feature is purchased. Offline production/use and death behavior also remain open. The initial closed-app system still awards gold only; any later crop production or resource automation needs its own designed calculation. This is late-game scope, beyond the first playable slice.

### Village or Named Upgrade Presentation

The broader late game may include many production unlocks. Two presentation directions are under consideration:

- A grounded village with gardens, breweries, and similar buildings representing production and progression.
- A simpler ascension interface with permanent named unlocks such as "[Mushroom Name] Garden", without requiring a village interface.

Neither direction is chosen. A village layout, building placement, extra management actions, and brewery mechanics are not committed features. The simpler named garden is a possible permanent ascension upgrade, not a decision that every effect becomes active without stock or Auto use. Keep the confirmed use-to-seed progression and automatic renewal behavior; exactly how seed requirements fit individual garden upgrades remains open.

Recommended foundation: represent each production unlock and what it enables independently of its visual presentation, so the same progression can appear as a named upgrade or a village building later. This does not require designing or implementing a village now.

## Other Candidate Secondary Resources

These are not committed yet, but are likely useful later:

- Runes - long-term magical upgrades or prestige-adjacent systems.
- Shards - gear crafting, gear upgrades, or duplicate conversion.
- Keys - chest, dungeon, or timed reward unlocks.
- Energy - optional session pacing if needed for economy control.

These additional resource systems are uncommitted; biome ingredients for potions and balms have a confirmed purpose separately.

## Upgrade Categories

### Power

Power upgrades increase the player's ability to defeat stronger enemies. This can include base damage, attack speed, critical chance, or enemy-specific damage bonuses.

### Abilities

Ability upgrades improve active or semi-active skills. Examples include cooldown reduction, damage, area size, duration, or reward conversion bonuses.

Special abilities are immediately owned and usable when discovered or earned through the relevant world content or boss. For example, a completed course can grant double jump directly. No initial gold purchase is required.

Discovered abilities reset on ascension unless a purchased ascension retention unlock keeps them unlocked. Exact retention upgrades and whether they also preserve ability improvement levels remain open.

The special-ability state model distinguishes hidden, locked, owned, and upgraded. Wealth items have a separate purchase flow: wealth milestone -> available for purchase -> buy level 1 -> effects apply.

### Gear

Gear behaves like a classic idle system. All purchased gear bonuses stay active together, increasing combat stats or gold generation without equipment-slot selection.

Gear is the main repeatable gold sink. Each purchase adds one level to a piece with its own stat role, and each successive level costs more. Level 100 Gloves means buying 100 levels of the same item, not holding 100 inventory copies. The exact cost growth and per-level stat increases remain tunable. The initial choice is deliberately limited to Viking Axe (damage), Chest (survival), and Helmet (income). Later pieces expand the economy after those essential choices are introduced.

Gear can improve combat stats, global income, or particular income sources. The latest concrete roles are:

- Chest increases toughness and health.
- Viking Axe increases axe-swing damage.
- Helmet increases gold from all sources by a percentage.

Later gear and additional income examples:

- Gloves increase gold gained from killing monsters.
- Further wealth-bracket items can increase gold per metre.
- Hunting Axe increases gold from killing enemies.
- Golden Amulet increases the value of collected coins.
- Shoulder pads increase passive gold generation.

The final roster and numbers remain open, and the suggested `+10%` shoulder-pad passive bonus is a tuning placeholder. Modifiers may increase values or multipliers; exact stacking rules and whether enemy bonuses cover boss rewards remain open. Global bonuses such as the helmet explicitly apply to all income sources, while other pieces target specific sources. The planned global ascension multiplier remains separately identifiable.

Gold per metre is an intended income source; whether there is also a separate time-based passive source remains open.

Basic enemies appear in packs killed in one hit. Damage helps resolve sustained fights with epic enemies and bosses, while health and defence help the Viking survive them. Health regenerates generously out of combat, and death restores full health on a quick restart with wealth and upgrades retained.

Further gear pieces become available at milestones measured against gold currently held in the wallet, replacing the earlier prior-piece-level requirements. Spending before reaching a milestone therefore competes with saving for the next item. Exact thresholds remain open, as does whether an unpurchased item stays available after the wallet falls below a reached threshold. Spending does not remove already purchased levels or their active bonuses. Ascension resets are a separate rule.

Early new-item brackets should begin roughly `10x` apart and gradually widen toward a steady `1,000x`, continuing to approximately `10^30` gold. Repeated effects on different items are intentional. This unlock spacing is separate from the cost growth for levelling existing gear.

Special upgrades come from bosses and discoveries in the game world, outside the main wealth-bracket sequence. Discovered abilities become usable immediately. Wealth milestones make routine income upgrades purchasable, with a paid first level required. Specific special reward sources and provisional attack behavior remain open. Francisca's attack-attributed gold also needs a rule for monsters hit by multiple attack types.

Gem coin values are sapphire 2g, ruby 3g, and emerald 4g. Whether these are pre-multiplier values and how they enter the pickup pool remain to be decided.

Later levels have higher gold rewards, and biomes have progression levels that increase gold earned as they rise. Clearing a world's level sequence automatically advances World+, presenting the sequence again with higher gold rewards; within each world level, content also becomes a little harder through gentler progression. The trigger for advancing biome levels and the exact world/biome difficulty and reward curves remain open. Spending on damage, health, and defence can open richer farming, while gold-focused pieces improve income directly. Players should have a meaningful choice between these investments.

World+ preserves the current run's gold, gear levels, and abilities. Eventually the Chest and Viking Axe strength affordable at the player's wealth bracket creates a practical progression ceiling, motivating ascension and another run with permanent benefits. Tune income, upgrade costs, and enemy strength around this loop. The ceiling is a balance target; no hard maximum gear level or fixed World+ limit has been specified.

See [Gear Progression](gear-progression.md) for the detailed model.

Future systems can add gear rarity, drops, replacement, crafting, affixes, or special milestone effects, but those are outside the MVP gear path.

### Gold Generation

Gold generation upgrades increase the value of coins, enemy drops, route rewards, or total gold earned. These upgrades are core to the idle feeling because they make prior content more profitable.

## Lifetime Ascension Point Progress

The first optional ascension offer arrives on beating World+1, targeting a few sessions. Total gold earned across the account lifetime builds pending points, with an endlessly increasing gold increment for each successive point. Spending wallet gold does not reduce this progress. Ascension banks the pending points once while preserving lifetime progress and the increasing requirement; banked unspent points can be spent whenever desired. Neither ascending nor spending points restarts the point-cost curve. Exact increments and eligible gold sources remain open. See [Ascension Progression](ascension-progression.md).

## Economy Principles

- Gold should be earned frequently and spent often.
- Early upgrades should be cheap enough to teach the loop quickly.
- Gear should be the default thing players can always spend gold on.
- Multipliers should be visible and understandable.
- Gear should create meaningful build milestones, not just invisible math.
- Reward growth should be high enough to feel idle-like but bounded enough for backend validation.
- New systems should unlock only when the current loop is understood.

## Closed-App Gold and Declining Rates

Closed-app earnings grant gold only at a reduced rate. On the player's return, the backend validates elapsed real-world time using server records and calculates the award from the accepted progression state. There is no accumulation cap: earnings continue, but the rate declines across longer absences.

The working bands are:

| Time Away | Rate |
| --- | --- |
| 0-12 hours | Initial reduced rate; percentage TBD. |
| 12-24 hours | Lower rate; percentage TBD. |
| 24-48 hours | Lower again; percentage TBD. |
| 48-168 hours | Further reduced rate; percentage TBD. |
| 168 hours onward | Lowest configured positive rate, continuing without a time cap; percentage TBD. |

Recommended calculation: each rate applies only to the time spent in its band. Reaching a later band does not retroactively reduce gold already accumulated in earlier bands. A proposed first tuning pass is 50%, 25%, 10%, 5%, and 1% of reference unattended earnings across the five bands; these percentages are provisional, and the reference rate still needs to be defined.

Opening the game resets the away-rate schedule to its first band once the return and reward claim are validated by the server. No minimum period of active play is required. The claim settles the previous eligible absence before the reset takes effect; reopening without successful validation does not itself establish a new authoritative schedule. A later absence starts again at the first band, excluding time spent actively playing.

Active gameplay uses two-minute routine checkpoints. A proposed further 1-2-minute retry allowance after a checkpoint is due supports intermittent signal; this is independent of the uncapped time-away reward schedule. Automation of bosses or discoveries remains future progression, likely through ascension.

## Daily Login Bonus and Streak

The daily login bonus is a conventional, independent daily reward system with a streak across consecutive days. It is not a collection track that simply pauses when days are missed. The exact streak length, rewards, day boundary, and any missed-day grace rules remain to be defined. No ad is required for the daily login bonus.

## Rewarded Ad for Double Offline Earnings

Each banked away-gold payout offers an optional rewarded ad to double that payout. If the server-calculated base payout is `G`, a successfully completed and validated ad grants an additional `G`, for `2G` total. The doubling is available per away-gold payout, rather than being the daily reward itself. Daily rewards and unrelated gold are not part of this specific doubling offer.

Recommended flow: settle the normal away reward and reset its decay schedule on the validated return, then offer the ad for the additional matching amount. Declining the offer or an unavailable/incomplete ad leaves the normal payout intact. Freeze the eligible amount at the original validated claim so later purchases or extra ads cannot change or repeatedly double it. Exact offer presentation and availability duration remain open.

Daily rewards and ad bonuses should scale sensibly with progression; their precise balance remains to be designed.

The two systems have separate eligibility and state: daily login tracks eligible days and the login streak; the ad offer tracks an individual validated away-gold payout. Watching an ad does not advance or preserve the daily streak, and the daily bonus is not included in offline-payout doubling.

## Challenge Retry Ads

Failure in a challenge room offers an optional rewarded ad for another attempt or a return to the level where the player entered. This reward is a retry, not a completion or an unlock, and is separate from offline-gold doubling. Return position, retry limits, and failed-attempt reward handling remain open. See [Challenge Courses and Ability Unlocks](challenge-courses-and-ability-unlocks.md).

## Balance Variables To Define

| Area | Example Variables | Notes |
| --- | --- | --- |
| Coins | spawn rate, value, route placement | Must respect mutually exclusive route choices. |
| Enemies | health, outgoing damage, attack timing, pack size, reward value | Basic pack kills and sustained epic/boss fights need distinct validation rules. |
| Power | upgrade cost, damage increase | Drives access to stronger enemies. |
| Gear | item count, current-wallet unlock thresholds, level cost, cost growth rate, gold, damage, health, defence contributions | All owned bonuses remain active; distinct piece roles support spending decisions. |
| Abilities | unlock prerequisite, purchase cost, cooldown, effect strength, duration | Must be validated against purchase rules and usage limits. |
| Rewards | gold per minute, bonus drops, streaks | Should be measurable by segment. |

## MVP Math Anchors

Initial MVP math anchors:

- Gear next cost provisionally uses `base_cost * 1.15 ^ current_level`; increasing costs are confirmed, the exact growth rate is tunable.
- Three core gear choices are implemented first: damage, survival, and income.
- Gear has piece-specific gold, damage, health, and defence contributions.
- Ascension has one repeatable upgrade worth `+5%` global gold/CPS per level.
- Magnetism starts as a powerup drop after its secret route is completed.
- Speed boost becomes usable immediately when its secret route is completed.

Detailed formulas live in [Gear Progression](gear-progression.md) and [Ascension Progression](ascension-progression.md).

## Open Questions

- What costs and stat gains should the three opening pieces use?
- What is the exact wealth-bracket sequence and timing for later gear unlocks?
- Do enemies drop fixed gold, scaled gold, or loot-table rewards?
- Should gold generation be a separate stat, a gear property, or both?
- What advances biome progression levels within a world level, and how quickly should the player's wealth and Chest/Axe strength reach an ascension-worthy ceiling?
- What is the desired time to first meaningful upgrade: 15 seconds, 30 seconds, 60 seconds, or longer?
- Which first abilities should be granted by challenge-course completion?
