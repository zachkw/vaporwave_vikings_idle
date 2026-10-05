# Progression Validation

## Goal

The backend should validate that reported progress is plausible before committing rewards. The goal is not perfect anti-cheat on day one. The goal is to make progression server-authoritative, catch impossible reports, and create a path toward stronger validation as the game matures.

The detailed handshake, offline delta, seed lease, efficiency cap, and trust score model lives in [Validation Service](validation-service.md).

## Validation Inputs

A progress report can be checked against:

- Player profile at the start of the segment.
- Purchased gear levels and upgrade levels; all owned gear bonuses contribute together.
- Content version.
- Run session id.
- Seed lease id and expiry.
- Server-issued map seed.
- Generation algorithm version.
- Tile library or route content version.
- Tile index range, route distance, or segment metadata.
- Enemy health and reward tables.
- Enemy layer/mushroom reveal rules and accepted mushroom-effect changes during the segment.
- Discovery-gated world-pickup drops and concurrent effect rules, including flower/other pickup multipliers and special effects.
- Gear cost, stat contribution, and damage formulas.
- Coin placement and pickup groups.
- Special box placement, unlock rules, and seeded rewards.
- Secret route entrances and challenge course metadata.
- Wealth-item eligibility from current-wallet milestones, level-dependent purchase costs, and ability ownership from content rewards.
- Ability cooldowns and effect rules.
- Powerup drop rules and active durations.
- Boss health and clear rules.
- Ascension point formula and permanent upgrade levels.
- Segment duration.
- Previous accepted reports.
- Previous authoritative profile version.
- Platform, app version, and telemetry signals.

## Boundary Checks

Initial validation should focus on upper bounds:

- Maximum possible gold from route pickups.
- Maximum possible gold from enemy kills.
- Maximum enemy kills given player power and elapsed time.
- Maximum blocker progress given gear-derived damage.
- Maximum ability activations given cooldowns.
- Maximum powerup drops and active duration.
- Maximum special box hits and rewards.
- Maximum rewards from mutually exclusive route choices.
- Maximum secret route completions and unlock flags possible in the segment.
- Maximum boss progress or clear plausibility.
- Maximum total report value for the content version.
- Minimum and maximum elapsed time for the report interval.
- Whether reported progression occurred inside a valid seed lease.

## Route Exclusivity

Route data should identify reward groups that cannot be collected together. For example, a high platform and low platform may each have rewards, but the player cannot collect both if the route choice is exclusive.

The current route direction is deterministic tile generation. The server issues the map seed when it creates the run session. The Godot client and backend use the same content version, tile library, generation algorithm, and seed to produce the same tile sequence.

Because of this, validation should not need to trust the client to describe which tiles appeared. The backend should be able to regenerate the relevant tile range from the run session seed, then check the player's reported pickups, kills, and rewards against those tiles.

The validator should detect impossible combinations such as:

- Rewards from two mutually exclusive platforms.
- Pickups too far apart for the elapsed time.
- Enemy kills requiring a route the player did not report.
- Coin groups requiring different lane choices in the same time window.
- A challenge course completion for an entrance that did not appear.
- An ability ownership grant without its required discovery, content completion, or purchased ascension retention unlock.
- A wealth-item effect applied before the bracket requirement and paid first level are satisfied.
- A magnet special box or magnet powerup activation before the magnet route unlock exists.
- A magnet special box reward from a tile where no box appeared.
- A speed boost activation before the speed boost ability is owned.

## Consistency Checks

Beyond hard upper bounds, the backend can track consistency:

- Does this player repeatedly hit theoretical maximum rewards?
- Does this player repeatedly exceed practical efficiency caps?
- Does reported gold per minute jump sharply without a matching upgrade?
- Does reported blocker clear speed match the player's gear-derived damage?
- Are rewards always at the top edge of possible outcomes?
- Are reports aligned with realistic ability timing?
- Does the client report impossible route combinations only on some devices or versions?

These checks should feed trust score changes rather than immediate rejection.

## Validation Outcomes

| Outcome | Meaning |
| --- | --- |
| Accept | Report is plausible and rewards are committed. |
| Clamp | Report is mostly plausible, but rewards are reduced to a safe maximum. |
| Reject | Report is impossible and rewards are not committed. |
| Flag | Report is accepted or clamped, but the account receives a review signal. |
| Refresh | Client must reload authoritative profile state. |
| Restrict | Account loses some offline or seed-lease privileges. |
| Ban | Account is blocked after severe or repeated violations. |

## First-Pass Algorithm

1. Load the player's authoritative profile.
2. Load the run session and previous accepted report.
3. Verify report order, elapsed time, content version, generation algorithm version, profile version, seed lease validity, and session validity.
4. Compute the player's effective stats at segment start, including gear-derived bonuses for each income source, damage, health, and defence.
5. Regenerate or load the generated tile range for the reported segment.
6. Compute the maximum possible rewards for that tile range.
7. Apply route exclusivity and ability cooldown constraints.
8. Compare reported rewards and kills against computed boundaries.
9. Commit, clamp, reject, flag, restrict, or ban.
10. Return the updated authoritative profile or reconciliation result.

## Important Design Constraint

Validation becomes much easier when gameplay content is data-driven. If reward values, enemy health, route exclusivity, and pickup placement live only inside Godot scene behavior, the backend cannot reason about them reliably.

Generated tiles should therefore be data-visible. Reward-bearing coins, enemy spawns, blockers, boss gates, powerups, branch exits, and required abilities should exist in tile metadata that the backend can read.

Secret route entrances and challenge course completion rewards should also be data-visible. If a cloud course grants an ability, the backend needs the entrance id, course id, completion conditions, and granted ownership before accepting the reward and subsequent ability use. The client can make the discovered ability usable immediately in predicted state; the reward event establishes durable ownership when validated.

Mushroom discovery is a challenge-room/course reward. Validate the room entrance and configured discovery/reward condition before granting the mushroom type's future-drop unlock, then validate later drops against that state. Keep the unlock separate from active effects. Discovery, later pickup, and effect-triggered enemy rewards can be reconciled in order within the normal checkpoint batch.

On challenge failure, preserve the originating level/visit context for return. An optional rewarded-ad retry requires a verified entitlement tied to the account, failed attempt, and course, consumed once to grant another attempt. The ad itself never grants completion or discovery rewards. Keep retry entitlements separate from away-gold ad bonuses; exact retry limits, restart position, and failed-attempt reward policy remain open.

Gear must also be data-driven. Each piece has explicit contributions to combat stats, global gold, and/or particular income sources. The backend needs the same global-gold, coin-value, enemy-gold, gold-per-metre, any separately defined passive-income, damage, health, and defence formulas as the client. Reports should retain the reward-source breakdown needed to apply these bonuses. Distance-earned gold also requires plausible distance travelled; elapsed seconds alone cannot justify it.

Wealth milestones are measured against gold held at the relevant point in the ordered delta, not total earnings or only the final checkpoint balance. Validate rewards and spending in order so spending before a threshold is reached cannot be ignored. Whether eligibility for an unpurchased item persists after a reached threshold is a separate unresolved rule. Owned gear bonuses remain active when the wallet falls, and repeat purchases increase the same item's level. Compute each successive level's rising price from its current level, deduct the cost, and apply the new bonus only to subsequent events. All owned pieces contribute without an equipment selection gate.

Ascension points must be based on accepted lifetime earned gold, not client-reported totals or current wallet balance. Each successive point requires a larger gold increment indefinitely; the configured curve and lifetime progress persist across ascensions. Derive pending points from lifetime entitlement minus all previously banked points, never minus the current unspent balance. Ascension credits those pending points once and resets run-level state while preserving lifetime progress, unspent points, and permanent upgrades. The first offer requires a validated World+1 clear; later eligibility and exact increments remain open. Banked points can buy upgrades during an active run through explicit server-authorized purchases without another reset.

Discovered abilities reset on ascension unless an owned ascension retention upgrade explicitly keeps them unlocked. Validate retained ownership against the server's purchased upgrade state; a pre-ascension ability flag alone must not survive the reset. The treatment of ability improvement levels remains open.

World+ automatically advances after the current world's required level sequence is cleared. It preserves gold, gear levels, and abilities and grants no ascension points. Validate the required world clear before advancing difficulty and gold rewards. Ascension resets run/world progression; do not treat entering a new world level as ascension or allow a client to collect ascension rewards for it.

Biome resources used for potions and balms introduce additional inventory and modifier state. When that system is implemented, validate resource grants, resource use, item activation, and resulting rewards in event order within the normal checkpoint batch. Hallucination-driven changes to enemy counts and multipliers must come from shared content rules. Distance-related consumption must use validated movement. The exact effect lifecycle, stacking, qualifying distance, and ascension behavior remain unresolved, so no expiration formula or persistent bonus is specified yet.

Real-world biome enemies are always present. Hallucination monsters and the demonic true layer are additional overlays revealed according to the mushrooms taken, and both overlays can coexist. Validate discovery of a mushroom type before accepting subsequent drops of that type, then validate the generated drop and its collection/use before granting the corresponding effect. Validate each overlay enemy's availability against accepted effect state at encounter time, independently of world difficulty and basic/epic/boss role. Later consumption must not retroactively authorize earlier unavailable-overlay kills. Overlay enemies can damage the player and grant access to higher-grade materials; validate damage and material grants against the defined enemy/reward tables. Track discovery, drops, effects, kills, and material rewards in event order within normal checkpoint batches. Exact mushroom mappings, durations, spawn/drop rates, and behavior on effect changes remain design questions.

This discovery/drop/effect model also covers flowers and other world-pickup forms. Mushrooms specifically reveal Whacky World or Demon World. Multiple pickup effects can stack to add enemies, multipliers, and special effects. Repeating an item adds its full configured duration to its remaining duration. Garden-grown and world-dropped versions have distinct item identities and independent effect durations, even when they apply the same buff; do not collapse them into one effect keyed only by buff type. Accept each pickup/use event once, including its duration extension, so a retried checkpoint cannot extend it again. Exact arithmetic for combining concurrent buffs and any limits remain open. Apply modifiers only from accepted activation onward.

Late-game cultivation is unlocked by a purchased ascension upgrade. Seeds are earned through repeated qualifying uses of each growable item. Derive per-type use counts from accepted use events, grant the seed unlock when the configured requirement is met, and ensure retries cannot count the same use twice. Discovery, continuous effect uptime, and enemy kills are not themselves additional item-use events. Both the cultivation upgrade and the relevant seed unlock must support growing an item. Purchased cultivation and unlocked seeds survive ascension. Exact thresholds and retention of unfinished use progress, crops, stock, and active effects remain open.

Cultivation supplies consumable stock for Auto use. Validate the enabled preference, expiry of that garden item's preceding application, available stock, and effect reapplication in order. A concurrent world item's buff neither delays this expiry nor replaces the garden effect. Stock deduction, renewed effect, and any qualifying use-count increment must be committed once together so a retried checkpoint cannot consume or count the same item twice. Continuous overlay activity is legitimate when supported by these renewal events, with enemy/material rewards checked against the same content rules. Owning cultivation or seeds alone does not authorize unlimited effects without stock. Validate the configured duration or distance allowance; toggling Auto use must not itself generate inventory or rewards.

Cultivation may be presented through a village with production buildings or through permanent named garden upgrades. Validate configured cultivation/garden and seed prerequisites independently of the UI. Whether the ascension unlock is general, per item, or a combination remains open; the possible village does not authorize additional production rules by itself.

Keep renewals in the existing two-minute checkpoint batches. A proposed low-cost implementation also reconciles any required elapsed growth/resource accounting during checkpoints or returns, without a continuously running server timer per crop or a request per consumed item. Offline crop production and Auto use need separate rules beyond the initial gold-only away-income system.

## Open Questions

- Should the backend fully replay tile generation for each report, cache generated tile ranges, or validate aggregate bounds from generated tile metadata?
- Which seeded RNG algorithm should be shared between Godot and Node.js?
- How much tolerance should be allowed for lag, pause, and backgrounding?
- Should offline active play and offline bonus be mutually exclusive for the same elapsed time?
- What happens when content data changes during an active run?
- How visible should validation corrections be to players?
