# Validation Service

This document defines the working validation-service model for the MVP and early live game.

The goal is server-authorized progression with believable simulation bounds, two-minute routine progress checkpoints, short tolerance for lost connections, and a trust score that reacts to repeated suspicious behavior. Low operating cost is a design priority. Normal active play requires internet. Closed-app earnings are a separate gold-only system.

## Core Philosophy

The backend validates plausibility.

It should ask:

- Did the player have a valid run session?
- Did the player have a valid seed lease?
- What tiles, enemies, coins, powerups, and secret routes could appear from that seed?
- What gear, abilities, and ascension upgrades did the player have?
- What purchases could they plausibly make during the elapsed time?
- What is the maximum believable reward for the reported delta?
- Is the player consistently reporting near-perfect or impossible results?

The validation service should not need a perfect replay of every frame. It should compute safe upper bounds and believable efficiency ranges.

The client-side action and state model is documented in [Client State Store](client-state-store.md). The validation service receives deltas derived from that store's action log.

## Checkpoints and Short Connection Grace

The server owns RNG seeds.

For MVP, a server-issued seed/session grant can also bound a short connection grace period:

- Normal active play requires an internet connection and regular accepted progress checkpoints.
- A brief loss of signal should not immediately interrupt a run. The motivating case is an underground train that only reconnects at stops.
- During the short grace window, the client persists predicted actions and rewards locally for the next checkpoint.
- When connectivity returns, submit pending progress promptly, reconcile the server response, and refresh the connection allowance.
- The intended tolerance for intermittent signal remains approximately 1-2 minutes. The proposed timing policy below separates that retry allowance from the two-minute routine checkpoint interval.
- Once the grace period expires, another successful checkpoint is required before further active progression. Exact waiting-screen behavior remains a product decision.

The seed lease is not just a random number. It should include:

- Seed id.
- RNG seed.
- Content version.
- Generation algorithm version.
- Lease start time.
- Lease expiry time.
- Run session id.
- Starting player state snapshot or profile version.
- Last accepted checkpoint, next checkpoint due time, and absolute progression deadline.

The purpose is to tolerate intermittent reception while requiring short-term progress validation. The route seed and content context must remain available to validate the buffered segment; refreshing connection permission does not inherently require generating a different route.

## Handshake Model

The client and server should handshake regularly when online.

The confirmed routine checkpoint interval is two minutes (120 seconds), chosen to keep operating costs low. Recommended batching and exceptional requests:

- Submit routine progress deltas every 120 seconds while actively playing.
- Batch ordinary gold collection, in-game gear purchases, boss clears, and discoveries into those deltas. Apply their effects provisionally on the client and validate them in event order.
- Require an online transaction for ascension and reward claims that must be final before proceeding. Include pending progress in the transaction where appropriate, rather than making a separate checkpoint request first.
- Persist pending progress locally during play and on app pause. Attempt a final checkpoint when practical; correctness must not depend on a background request completing.
- Reconcile on resume and submit queued progress promptly when connectivity returns, including short connections at train stops. Coalesce overlapping triggers into one request.
- Schedule the next routine checkpoint from a successful commit so an exceptional request does not immediately cause a redundant routine request.

Proposed grace policy: a checkpoint is due 120 seconds after the last accepted state, followed by a configurable 60-120-second retry allowance. The server grant fixes the absolute progression deadline at 180-240 seconds after the last accepted state. Start with 120 seconds of retry allowance as a recommendation, not a confirmed product decision. Failures, retries, and local clock changes cannot extend that deadline; only a successful server checkpoint can renew it.

This replaces the earlier proposal to expire all active progress 1-2 minutes after the last checkpoint, which would leave no retry time at the new cadence. The tradeoff is up to 3-4 minutes of provisional progress between validations. It is not proof of when the connection was actually lost: without additional traffic, the server cannot enforce a precise 1-2-minute physical disconnection limit. Keep the routine interval and retry allowance separate and configurable. At the absolute deadline, stop extending active progress and preserve the queued actions.

Checkpoint requests need stable identities and retry-safe commits. If the server accepts a checkpoint but its response is lost, retrying must return that result without applying rewards or purchases again. A lost response must not discard queued progress. Preserve each queued segment's original seed/content context until it is reconciled.

## Low-Cost Operation

- Two-minute checkpoints reduce scheduled requests from 120 to 30 per active player-hour, a 75% reduction before exceptional requests and retries. This is not a promise of 75% lower total cost: validation still processes the underlying gameplay events.
- Use request-driven validation rather than a continuously running server simulation for every player. Closed-app gold is calculated on return; it needs no per-player background timer.
- Use compact, bounded event batches with enough detail to validate rewards and purchase order. Avoid a separate request or durable database write for each coin, enemy, or ordinary upgrade click.
- Commit the profile and retry-safe checkpoint result in one database transaction. Keep detailed diagnostics bounded instead of retaining every gameplay event indefinitely.
- Use bounded retry backoff with jitter while a connection is failing. Do not add frequent heartbeat requests solely to support the longer checkpoint interval.
- Measure requests, payload size, validation CPU, and database writes per active player-hour before adding infrastructure. Longer intervals reduce request overhead but can increase batch size and the amount of provisional progress to reconcile.
- The current backend's 90-second maximum report duration is incompatible with this design. Implementation must support 120-second routine reports and bounded buffered catch-up, using server-issued time limits and cumulative accounting; increasing the client-reported duration limit alone is insufficient.

## Delta Sync

The client should send deltas since the last accepted server state.

The delta should be built from the client state store's action log, not manually assembled by UI components or individual gameplay scenes.

A delta can include:

- Previous server profile version.
- Run session id.
- Seed lease id.
- Client elapsed time.
- Tile range or distance covered.
- Gold earned by category.
- Coins collected.
- Enemies killed by type.
- Boss progress or clear.
- Secret route entries and completions.
- Special box hits and rewards.
- Powerup drops and activations.
- Ability activations.
- Shop purchases made during the delta.
- Offline bonus claimed during the delta.

The server validates the delta against the last accepted profile. If accepted or clamped, it commits a new authoritative profile version.

This should behave like a client-server reconciliation loop: the client predicts, the server validates, and the client reconciles to the authoritative result.

Server responses should be applied on the client as store actions, such as accepted, clamped, rejected, or seed lease refreshed.

## Active Play During a Brief Disconnection

An already active session can continue provisionally during its short connection grace period. This is interruption tolerance for an online game.

Within that window, the proposed buffered actions are:

- Keep running.
- Earn predicted gold.
- Collect coins.
- Kill enemies.
- Find powerups.
- Complete secret routes.
- Make predicted shop purchases.
- Progress toward boss clear.

When the client reconnects, it submits queued deltas for validation, including purchases and progression changes. The client must stop extending active progression when the grace expires and retain its pending progress until reconciliation. A later reconnect should not invalidate otherwise valid buffered progress solely because submission occurs after expiry: validate when the actions occurred within the permitted session window. Actions outside that window are not authorized active progress.

Whether a fresh app launch can use an unexpired allowance, and exactly which actions remain available during the waiting state, remain open. Ascension stays an explicit online action.

## Closed-App Gold

While the app is closed, the player earns gold only. The initial system does not defeat bosses, advance levels, discover abilities, or make upgrade purchases on the player's behalf. Later upgrades, most likely in the ascension system, may explicitly add automation of those activities.

Closed-app income is separate from active play during a signal outage. It earns a reduced amount and is validated on the player's return against elapsed real-world time using server records and the last accepted progression state. There is no accumulation cap. Rates decline across the working bands 0-12, 12-24, 24-48, 48-168, and 168+ hours. Exact percentages remain provisional. A successful server-validated return and reward claim resets the schedule to its first band; no minimum active-play duration is required.

Recommended piecewise calculation, pending rate tuning:

```text
away_gold = reference_gold_per_second * sum(tier_seconds[i] * tier_rate[i])

tier_seconds[i] = max(0, min(eligible_away_seconds, tier_end[i]) - tier_start[i])
```

The server should compute this from:

- Last accepted checkpoint and reconciled activity intervals.
- Current server timestamp.
- Last accepted profile.
- Tier boundaries at 12, 24, 48, and 168 hours, with an unbounded final band.
- Reduced tier rates and the authoritative reference earning rate, still to be decided.
- Applicable accepted gear and ascension bonuses, applied once.

The proposed band calculation applies each rate only to its own interval; entering a lower-rate band never removes earlier earnings. The final rate should remain positive so legitimate time away continues to earn gold indefinitely. There is no time or accumulated-reward cap in this design.

Recommendation: reconcile buffered active play first, then award gold for eligible time away, excluding intervals already rewarded as active play. Use server timestamps and accepted activity records to validate real elapsed time on return. A device-clock change must not create extra entitled time. Commit the reward, consumed interval, and schedule reset together. A duplicate request must return the existing result without awarding the same interval again or moving the reset a second time. Long absences can be calculated by summing the five bands rather than simulating every elapsed second.

The reset belongs to a validated return from time away. Local app opening without server validation and routine checkpoint retries do not themselves reset it. Track active and away intervals separately so a subsequent absence starts in the first band and elapsed active time does not advance the away-rate schedule.

## Daily Login Streak Validation

Daily login rewards are an independent system with a consecutive-day streak. The server determines eligibility from the chosen day-boundary rule, tracks the last eligible day and streak progression, and commits each daily entitlement once. Device clock changes, repeated requests, and multiple devices must not create duplicate grants or advance the streak twice in one day. The cycle length, rewards, and any missed-day grace rules remain open. This is a login streak, not a non-consecutive collection track. No ad completion is required.

## Rewarded-Ad Doubling of Offline Earnings

Each banked away-gold claim can receive one optional ad bonus equal to its validated base amount. Store the original amount and eligibility against that claim. A payout of `G` can gain an additional `G`, yielding `2G` total; daily rewards and unrelated gold are excluded from this offer.

Recommended implementation:

1. Settle the base away reward and its decay reset using the normal retry-safe return claim.
2. Create an ad-bonus entitlement tied to that claim and the player's account, with the base amount frozen.
3. Verify reward completion through the chosen ad provider's supported verification mechanism. A client-supplied completion flag alone must not authorize the bonus.
4. Atomically consume the entitlement and write the matching gold credit to the ledger. Duplicate or delayed callbacks return the prior result without a second grant.
5. Preserve base earnings if the ad is declined, unavailable, or incomplete. If completion verification is delayed, retain the pending claim so a valid bonus can be reconciled later.

The provider, verification contract, and offer lifetime are implementation decisions still to be made. Ad completion does not create a second away-income interval or reset the away schedule again. Initial away earnings remain gold-only even when doubled.

Daily login eligibility/streak state and away-payout ad eligibility are independent. Ad completion must not mutate the login streak, and the daily reward must not enter the amount eligible for offline doubling.

## Rewarded-Ad Challenge Retry

Challenge failure offers a rewarded ad for another attempt or a return to the originating level. Recommended validation stores the origin context and failed attempt, verifies ad completion with the provider, and issues a retry entitlement tied to the account and course. Consume that entitlement once when starting the retry. Duplicate callbacks or requests must not grant more attempts, completion rewards, or discoveries. Keep ad reward purpose explicit so the same completion cannot grant both a challenge retry and an away-gold bonus. Recommend returning to the originating level if the ad is declined, unavailable, or incomplete; exact return position, retry limits, and failed-attempt reward handling remain open.

## Purchases During Deltas

Purchases can happen in online deltas or, as a proposed grace-period behavior, buffered active-play deltas. They do not occur automatically while the app is closed.

The client should report purchases in order:

```text
[
  { time_offset: 12.4, type: "gear", id: "gear_001", quantity: 10 },
  { time_offset: 31.8, type: "gear", id: "helmet", quantity: 1 }
]
```

Validation should replay or approximate the delta in purchase order:

1. Start from last accepted profile.
2. Validate rewards up to the first purchase time.
3. Validate the purchase cost from the item's current level and its prerequisites, including milestones based on gold held at the relevant point in the delta.
4. Update simulated player state.
5. Continue validating with the new stats.

This matters because gear purchases can change global gold bonuses, coin value, enemy gold, gold per metre, any separately defined passive income, and combat stats inside the same minute. Reward summaries should preserve these sources so the server can apply the correct bonuses before and after each purchase. Distance-earned gold must be checked against plausible travel, rather than elapsed time alone. The existing backend's aggregate report is an earlier scaffold and does not yet implement this model.

Each repeat gear purchase increases the same item's level and raises the next purchase price. All owned gear bonuses remain active together, including after spending lowers the wallet balance. Milestone attainment uses gold currently held, not lifetime or ascension-run earnings; whether an unpurchased item stays eligible after a reached threshold is still open. Keep that eligibility policy distinct from the persistence of already purchased bonuses.

Ascension upgrades should not come through normal deltas. Ascension and ascension-upgrade purchases should be explicit server-authorized actions. Banked points can be spent during an active run without ascending again. Reconcile pending run events before applying an upgrade so its benefits begin at the correct point.

Track accepted lifetime earned gold, cumulative point entitlement, all points previously banked, and unspent banked points separately. Each successive point requires a larger gold increment, increasing indefinitely across ascensions. Ascending credits pending entitlement once, resets run state, and preserves lifetime progress and unspent points. Spending points never lowers the lifetime requirement or makes prior points claimable again. The first ascension offer requires a World+1 clear; exact gold increments, qualifying sources, and later eligibility remain design decisions.

## Route and Reward Bounds

The backend should regenerate or approximate the route from:

- Seed lease.
- Tile library.
- Content version.
- Generation algorithm version.
- Tile range or distance.

Then it computes possible rewards:

- Coin groups.
- Enemy spawns.
- Blocker rewards.
- Boss rewards.
- Secret route entries.
- Special box opportunities.
- Powerup opportunities.
- Mutually exclusive reward groups.

Level progression must account for automatic advancement after a boss clear, automatic World+ advancement after clearing the current world's level sequence, and gentler biome progression within each world level. Track world level, biome progression level, first-clear eligibility, and current visit separately. Higher world and biome levels increase gold; exact formulas and within-world biome advancement triggers remain design decisions. Validate both levels against accepted progression instead of trusting client-supplied reward multipliers or treating every new visit as advancement. World+ preserves gold, gear levels, and ability ownership. It must not invoke the ascension reset or award ascension points. Ascension separately resets run/world progression, preserving purchased permanent upgrades and abilities covered by retention unlocks.

Portal travel requires the configured eligibility, a valid generated portal opportunity, and optional player activation. The normal full-clear requirement remains the starting rule; its persistence across resets and any upgrade exceptions are unresolved. Validate ordinary route opportunities separately from the five-level ascension upgrade's biome-start chance: 20%, 40%, 60%, 80%, or 100%, based on the owned upgrade level. At level 5, eligible starting opportunities are guaranteed. Use stable entry/event identities so retries cannot reroll portal appearance or destination. The destination must be the event's random outcome from the permitted pool of other biomes, not a client-selected destination. Resolve and consume each event once; do not count teleport displacement as earned running distance. Validate events before and after the transition against their respective biome levels, visits, and content/seed contexts. Portal events can stay in the normal two-minute checkpoint batches; they do not inherently require a separate request.

The MVP validator can use aggregate bounds rather than exact route-choice replay. The client does not need to report every route choice.

For example, if a tile has high coins and low enemies, the server can allow a plausible combined maximum with margin, but should treat repeated 100% collection of mutually exclusive content as suspicious.

## Efficiency Caps

Reported rewards should be compared to possible rewards with an efficiency model.

Candidate MVP model:

- Compute theoretical max for the generated tile range.
- Compute a practical cap, such as `90%` of theoretical max for dense segments.
- Allow `100%` for simple early segments where perfect collection is realistic.
- Clamp rewards above the practical cap.
- Track repeated near-maximum reports as trust-score signals.

Example:

```text
accepted_gold = min(reported_gold, practical_gold_cap)
```

The practical cap can vary by content:

- Simple route: higher allowed efficiency.
- Dense route: lower expected efficiency.
- Magnet active: higher coin pickup cap during magnet duration.
- Speed boost active: higher route distance cap during boost duration.
- Secret route: separate completion and reward bounds.

## Magnetism Bounds

Magnetism can collect coins from nearby paths, including coins above the player while the player remains on a lower route.

This means magnetism can weaken route exclusivity during its active duration, but it should not mean "collect every coin in the segment."

Validation should check:

- Magnetism was unlocked.
- A magnet special box was possible from the seed.
- The reported box hit corresponds to a generated special box.
- The seeded box reward was magnetism.
- Magnet active duration is plausible.
- Coin pickup boost fits magnet radius and duration.
- Magnetism was not active for the entire segment unless the seed and box rules make that plausible.

Repeated reports that behave like permanent magnetism should reduce trust score.

## Enemy and Boss Bounds

Enemy spawns are generated from tile content and seed rules.

Validation should estimate:

- Which enemies could appear.
- Their health.
- Their rewards.
- Player damage from gear and upgrades during the delta.
- Player health and defence, enemy outgoing damage, and time available for out-of-combat regeneration.
- Time spent on blockers.
- Whether boss clear is plausible.

Combat rules distinguish basic packs killed in one hit from epic enemies and bosses that stop the player for sustained fights. Validation should use the generated pack/spawn data for basic kills and damage plus survival bounds for sustained fights. Damage alone is insufficient to establish a plausible boss victory.

When thrown axes are introduced, their damage and reward effects must be distinguished from melee swings. Francisca improves thrown-axe damage and related gold, Gloves improve monster-kill gold, and Helmet improves all gold. The report model needs enough attack attribution to apply the chosen stacking rules once they are defined, while awarding each monster's base reward only once.

Attack definitions should expose their triggers, targeting rules, ranges, cadence, and burst counts. The current examples are frontal automatic melee, aerial targeting for thrown axes, and a three-fireball arc from airborne jump input. These examples remain provisional; validation must follow the finalized content definitions. It must check the granting boss/world reward and plausible attack opportunities. Exact cooldowns, repeat-trigger limits, and input/position evidence remain open; frame-by-frame replay is not yet required by this design.

Death restarts the current level quickly with gold and purchased upgrades retained and player health restored fully. Boss health resets fully on each attempt. Report data must distinguish attempts so fresh rewards from a legitimate replay are not confused with duplicate submissions, and damage cannot be carried across boss attempts. This is a design requirement; attempt identity and the exact report schema are still to be defined.

If the player reports too many kills or too-fast blocker clears, the backend should clamp rewards and lower trust score if the pattern repeats.

## Trust Score

Each account should have a trust score or trust state.

Candidate states:

| State | Meaning | Behavior |
| --- | --- | --- |
| `trusted` | Consistently normal reports. | Standard caps and seed lease duration. |
| `normal` | Default state. | Standard validation. |
| `suspicious` | Repeated near-perfect or clamped reports. | Tighter caps, more frequent handshakes. |
| `restricted` | Very low trust. | Reduced offline allowance or online-only progression. |
| `banned` | Severe or repeated impossible behavior. | Block progression or account access. |

Trust should fall from:

- Impossible reward reports.
- Repeated 100% efficiency in dense segments.
- Permanent-magnet-like coin collection.
- Powerups reported outside seed possibilities.
- Purchases that could not be afforded.
- Boss clears that are impossible for current damage.
- Tampered profile versions or invalid delta order.

Trust can recover slowly with normal accepted reports, unless the account hits severe thresholds.

## Validation Outcomes

Validation should produce clear outcomes:

| Outcome | Meaning |
| --- | --- |
| Accept | Delta is plausible and committed. |
| Clamp | Delta is too high but can be safely reduced to the practical cap. |
| Reject | Delta has impossible structure or invalid purchase/order data. |
| Flag | Delta is accepted or clamped but contributes to trust score decay. |
| Refresh | Client must reconcile to the authoritative server profile. |
| Restrict | Account loses some offline or seed-lease privileges. |
| Ban | Account is blocked after severe or repeated violations. |

Default behavior for "too good" should be clamp to max plausible or practical cap, not immediate ban.

## MVP Implementation Steps

1. Store profile version and last accepted timestamp.
2. Issue a seeded session with a short, configurable connection grace allowance.
3. Accept 120-second routine progress deltas and bounded catch-up within the server-issued deadline.
4. Reconcile buffered deltas for active play within the permitted grace window.
5. Validate gear purchases in delta order.
6. Validate route rewards using generated tile bounds.
7. Clamp rewards above practical caps.
8. Track trust score signals.
9. Refresh seed lease on online handshake.
10. Require a successful checkpoint before resuming active progression after grace expiry; preserve pending progress while waiting.

## Open Questions

- Should the MVP practical cap be fixed at 90%, or vary by tile density from day one?
- What trust score threshold moves a player to restricted mode?
- Should restricted players be online-only, or just have shorter seed leases?
- Should the retry allowance after a due two-minute checkpoint be 60 or 120 seconds? The recommendation is 120, allowing at most four minutes of provisional progress between validations.
- What should the player see or be able to do when the connection grace expires?
- Can a fresh app launch use a still-valid grace allowance, or must every launch connect first?
- What percentages and reference earning rate should the five uncapped closed-app bands use?
- Confirm the proposed non-overlap rule between active-play rewards and closed-app gold.
- Should bans be automatic in MVP, or should MVP only restrict and flag?
