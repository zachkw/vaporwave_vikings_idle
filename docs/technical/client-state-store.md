# Client State Store

This document defines the client-side state architecture.

The model is inspired by Redux: a single state store, actions that describe what happened, deterministic reducer logic that updates state, and UI systems that subscribe to state changes. We are not committing to using Redux itself. This is a Godot-friendly version of the same pattern.

Reference:

- [Redux Fundamentals: Concepts and Data Flow](https://redux.js.org/tutorials/fundamentals/part-2-concepts-data-flow)
- [Redux Three Principles](https://redux.js.org/understanding/thinking-in-redux/three-principles)

## Goal

The client should have one predictable internal gameplay state.

Game systems should not directly mutate gold, gear levels, ability ownership, seed lease state, or run progress. Instead, they dispatch actions to the store. The store applies deterministic logic, updates the state, emits change notifications, and records the action for validation deltas.

This gives us:

- Independent UI that listens to state changes.
- One place where reward math is applied.
- One action log that can become a server delta.
- Easier reconciliation after backend validation.
- Easier debugging because state changes have named causes.

## Core Pattern

The pattern is:

```text
gameplay event -> action -> reducer -> new state -> subscribers update -> action log grows -> delta sync
```

Example:

```text
Coin pickup collision
-> dispatch COLLECT_COIN { coin_id, tile_id, base_value }
-> store calculates final gold from gear, ascension, powerups, and multipliers
-> state.gold increases
-> gold UI updates because it subscribes to gold
-> action is recorded for next validation delta
```

The coin object is only a representation in the world. The store decides what that coin is worth.

## Store Responsibilities

The `GameStateStore` should own predicted local state for:

- Current gold.
- Gear levels and milestone upgrades.
- Global gear gold bonuses and bonuses by source (coins, enemies, gold per metre, and any separately defined passive income), with global ascension bonuses kept separate.
- Damage stats.
- Ability unlock and ownership states.
- Active ability cooldowns.
- Powerup unlocks and active durations.
- Discovered world-pickup types (mushrooms, flowers, and other forms) eligible for future drops, separate from active effects. Taking an eligible generated drop activates its mapped effect.
- Concurrent pickup effects for additional enemies, multipliers, and special effects. Repeating the same item adds its full duration to its remaining duration. Garden-grown and world-dropped versions are distinct items with separate effect durations, even when they apply the same buff. Mushrooms reveal Whacky World and/or Demon World while the base biome layer stays active. Exact numerical combination and duration values remain open.
- Purchased cultivation/garden ascension unlocks, qualifying use progress by growable item type, and seed unlocks earned by repeated use. Cultivation unlocks and unlocked seeds survive ascension; retention of unfinished use progress and stock remains open. The general-versus-per-item unlock structure is unchosen. Store progression independently of a potential village-building or simple upgrade-list presentation.
- Consumable stock and Auto use preference per item, plus current effect expiry state. While Auto use is enabled, that garden item's expiry consumes another available unit and reapplies its effect, independently of any concurrent world version. Keep these separate from discovery flags and random-drop activation. No stock means no renewed effect; exact waiting/resume UX and toggle retention remain proposals.
- Magnetism state.
- Speed boost state.
- Run session id.
- Seed lease id and expiry.
- Current generated route position.
- Current World+ world level, biome progression level within that world, full-clear history, and current visit identity as separate state. Clearing the required world sequence automatically advances World+, preserving the build.
- Challenge course/attempt identity, originating level/visit context, failure state, and any server-verified ad retry entitlement. Returning restores the originating level context; an ad grants an attempt, not completion.
- Purchased biome-start portal upgrade level and the current generated portal opportunity. Exact biome-level advancement and reset rules remain open.
- Accepted profile version.
- Pending action log.
- Offline delta queue.
- Lifetime accepted earned gold and point progression, including progress toward the next increasingly expensive point; these persist across ascensions.
- Ascension preview showing pending points, total points ever banked, banked unspent points, and the first-offer eligibility from beating World+1. Banked points remain spendable during a run.

The store is local-predicted state. The backend remains authoritative for durable progression.

## Actions

Actions describe what happened.

Candidate MVP actions:

| Action | Purpose |
| --- | --- |
| `RUN_STARTED` | Store run session id, seed lease, profile version, and initial state. |
| `TILE_ENTERED` | Track generated route progress. |
| `COIN_COLLECTED` | Award coin gold through store math. |
| `ENEMY_KILLED` | Award enemy gold and record kill. |
| `BLOCKER_DAMAGED` | Track blocker progress. |
| `BOSS_DAMAGED` | Track boss progress. |
| `BOSS_DEFEATED` | Record boss clear and reward. |
| `LEVEL_ADVANCED` | Enter the next level automatically after a valid boss clear and update level-clear history. |
| `TELEPORT_EVENT_AVAILABLE` | Record an eligible optional route or biome-start portal opportunity, including the start-portal upgrade's 20% per level chance up to 100%. |
| `TELEPORT_EVENT_ACTIVATED` | Record the player's choice to use the portal; the destination is random rather than player-selected. |
| `LEVEL_TELEPORTED` | Apply the event's random other-biome destination and generation context without awarding skipped-distance gold. |
| `GEAR_PURCHASED` | Spend gold and increase gear level. |
| `GEAR_MILESTONE_PURCHASED` | Spend gold and apply milestone multiplier. |
| `SECRET_ROUTE_ENTERED` | Record secret route entry. |
| `SECRET_ROUTE_COMPLETED` | Grant the course's special ability or powerup-type unlock, including mushroom future-drop eligibility where its discovery is the completion reward. |
| `CHALLENGE_FAILED` | Offer an ad retry or return while preserving the originating level context. |
| `CHALLENGE_RETRY_ACCEPTED` | Start another attempt using a server-verified retry entitlement once. |
| `CHALLENGE_RETURNED` | Return to the level where the player entered. |
| `ABILITY_GRANTED` | Mark an ability owned and immediately usable from its discovery/content reward. |
| `ABILITY_ACTIVATED` | Start ability duration or cooldown. |
| `POWERUP_DROPPED` | Record generated/drop powerup opportunity. |
| `SPECIAL_BOX_HIT` | Record a hit-from-below box activation and its seeded reward. |
| `POWERUP_COLLECTED` | Activate temporary effect. |
| `OFFLINE_BONUS_PREVIEWED` | Preview offline bonus before server commit. |
| `RETURN_REWARD_ACCEPTED` | Apply a server-validated away payout and schedule reset; store its ad-bonus eligibility. |
| `DAILY_REWARD_ACCEPTED` | Apply the server-validated daily login reward and consecutive-day streak state. |
| `AWAY_AD_BONUS_ACCEPTED` | Apply the once-only matching bonus for a validated away payout. |
| `ASCENSION_REQUESTED` | Freeze current run state for server ascension request. |
| `SERVER_DELTA_ACCEPTED` | Apply authoritative accepted profile version. |
| `SERVER_DELTA_CLAMPED` | Reconcile to clamped authoritative values. |
| `SERVER_DELTA_REJECTED` | Roll back or refresh from server state. |
| `SEED_LEASE_REFRESHED` | Store new seed lease after handshake. |

Actions should include enough metadata for validation:

- Local timestamp or elapsed run time.
- Run session id.
- Seed lease id.
- Tile id or tile index where relevant.
- Source object id where relevant.
- Base reward value where relevant.
- Purchase id and quantity where relevant.

## Reducers

Reducers are deterministic state update functions.

They should:

- Take current state and an action.
- Compute the next state.
- Avoid hidden side effects.
- Use shared math helpers for rewards, costs, damage, and cooldowns.
- Record enough information for validation deltas.

They should not:

- Play sounds.
- Spawn particles.
- Call the network.
- Read wall-clock time directly.
- Use non-deterministic RNG directly.

Side effects should be handled by systems that listen to actions or state changes.

## Selectors and Subscribers

UI should read state through selectors or subscriptions.

Examples:

- Gold label subscribes to `state.wallet.gold`.
- Gear shop rows subscribe to the item's icon/name/effect description, current level, next-level cost, purchase eligibility, and affordability. The right-aligned buy button displays that cost and is green when affordable or red when gold is insufficient for an available item.
- Ability shop subscribes to ability unlock and ownership states.
- Unlocks section subscribes to world-discovery rewards and their current ownership/drop-eligibility states. A discovered mushroom type is not shown as an active effect merely because its drops are unlocked.
- Biome badges subscribe to biome-clear records keyed to the current run and World+ world level. Derive badges from those records; do not use lifetime or previous-world completion as current-world completion.
- Ascension tab subscribes to first-offer eligibility, pending points, banked unspent points, the next lifetime point requirement, and permanent upgrade levels. Buying with banked points does not require a reset.
- HUD subscribes to active powerups and cooldowns.

The UI should not compute durable reward math itself. It should display values derived by the store.

A next-level purchase dispatches the gear purchase action for one level. Apply the predicted wallet debit and level increase together, then refresh next cost and affordability across the visible gear rows. A second tap must use the updated state and price. Use full currency values for comparisons, not formatted/rounded labels. The existing checkpoint model reconciles these ordered purchases; the row design does not require a network request for each tap. Disabling unaffordable red buttons is recommended; wealth-locked row presentation remains open.

## Effects

Effects are the systems that react to actions or state changes but do not own durable state.

Examples:

- Play coin pickup sound after `COIN_COLLECTED`.
- Spawn damage numbers after `ENEMY_KILLED`.
- Trigger speed lines while speed boost is active.
- Start network delta submission after a report interval.
- Persist queued offline delta after each action.

This keeps presentation and networking separate from progression logic.

## Action Log and Deltas

The store should keep an action log since the last accepted server profile version.

The action log can be summarized into a validation delta:

```text
last_accepted_profile_version
run_session_id
seed_lease_id
elapsed_time
tile_range
reward_summary
kill_summary
powerup_summary
special_box_events
purchase_events
secret_route_events
boss_events
```

The server does not need to trust every action blindly. The actions explain what the client thinks happened. The backend validates the delta against the seed lease, content version, and authoritative profile.

After validation:

- Accepted delta clears the matching action log.
- Clamped delta reconciles state to the authoritative server response.
- Rejected delta triggers rollback or profile refresh.

## Brief Disconnection Queue

Normal play requires internet with routine checkpoints every two minutes. Persist predicted actions locally between checkpoints and batch ordinary purchases, boss results, and discoveries in event order. The proposed grace policy allows a further 1-2 minutes to retry a due checkpoint, supporting intermittent reception such as an underground train reconnecting at stops. This permits up to 3-4 minutes of provisional progress after the last accepted state; two minutes of retry allowance is recommended but not yet confirmed.

The client should persist:

- Last accepted profile.
- Last accepted profile version.
- Seed lease.
- Pending action log.
- Queued delta summaries.
- Last accepted checkpoint, stable checkpoint request ids, next checkpoint due time, and absolute server-issued progression deadline.

When connectivity returns, submit queued deltas in order promptly enough to use a brief connection. Retain pending actions until the matching server acknowledgement; retries of an accepted request must not duplicate its effects.

When the absolute progression deadline expires, stop extending active progression and preserve pending actions for a successful checkpoint. Failed requests must not move that deadline. Keep the 120-second routine interval separate from the proposed 60-120-second retry allowance; exact waiting-state behavior remains open. Keep the original content/seed context for every queued delta.

Closed-app rewards are a separate gold-only calculation based on authoritative state and validated real-world time away. Earnings have no cap, but use declining rates with boundaries at 12, 24, 48, and 168 hours. The server calculates and commits the award on return; a local preview is not authoritative. Bosses, discoveries, and automatic purchases during closed-app time are future automation features, likely tied to ascension. The proposed reconciliation order is buffered active play first, then non-overlapping away gold.

Apply the reset to the first away-income band from the server-validated return/claim result. A local reopen alone must not reset authoritative decay state. Keep the same pending claim identity across retries so a lost response does not cause repeated awards or resets.

Keep daily rewards and the optional away-gold ad bonus as separate claims. The ad bonus references the settled away payout and can add its base amount only once. An ad SDK callback can trigger verification, but only the server-accepted result grants durable bonus gold. Store pending verification state across app interruptions.

Track daily eligibility, last eligible day, and the consecutive-day login streak separately from away-payout ad eligibility. An ad result does not change the daily streak, and the daily reward is excluded from the ad's matching bonus amount.

## Reconciliation

The server can return:

- Accepted values.
- Clamped rewards.
- Rejected delta.
- New profile version.
- New seed lease.
- Trust state changes.

The store should apply this through server actions:

- `SERVER_DELTA_ACCEPTED`
- `SERVER_DELTA_CLAMPED`
- `SERVER_DELTA_REJECTED`
- `SEED_LEASE_REFRESHED`

This keeps server correction inside the same action flow as gameplay.

## MVP Implementation Shape

For the first Godot implementation, the store can be an autoload singleton.

Suggested pieces:

- `GameStateStore`: owns state, dispatch, subscriptions, action log.
- `GameState`: serializable state object or dictionary.
- `GameAction`: typed action payloads.
- `Reducers`: pure update functions.
- `Selectors`: helper functions for UI.
- `Effects`: optional listeners for audio, VFX, persistence, and networking.
- `DeltaBuilder`: converts action log to server payload.

This does not need to be overly abstract. The important part is discipline: gameplay systems dispatch actions; state changes happen in one place.

## Open Questions

- Should every pickup and kill be logged individually, or should the store aggregate some events immediately?
- How much of the action log should survive app kill before being summarized?
- Should reducers be shared between Godot and backend, or should only math/config be shared?
- Should server reconciliation roll back and replay local actions, or directly snap to authoritative values in MVP?
- What state belongs in the store versus transient scene-only state?
