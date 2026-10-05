# Godot Client

## Role

The Godot client is responsible for delivering the real-time mobile game experience. It should feel immediate, readable, and rewarding, while treating server responses as authoritative for lasting progression.

Predicted client progression should flow through a Redux-inspired state store. Gameplay systems dispatch actions, the store updates predicted state, UI listens to store changes, and the action log becomes the basis for validation deltas. See [Client State Store](client-state-store.md).

## Major Client Systems

| System | Responsibility |
| --- | --- |
| Runner Controller | Moves the hero through the side-scrolling route. |
| Route System | Generates and loads authored tiles from a server-issued map seed. |
| Pickup System | Handles coins, resource pickups, and collection feedback. |
| Combat System | Resolves attacks, enemy damage, kills, and ability effects locally. |
| Ability System | Tracks unlock state, ownership, cooldowns, activations, effects, and upgrade scaling. |
| Powerup System | Handles temporary pickups and drops such as magnetism. |
| Game State Store | Owns predicted local state, dispatches actions through reducers, notifies subscribers, and records the action log. |
| Upgrade UI | Lets players spend gold on power, abilities, gear, and multipliers. |
| Gear System | Tracks the three opening pieces and later wealth-bracket gear, next costs, source/attack bonuses, combat stats, and previews. |
| Ascension UI | Shows ascension eligibility, previewed points, and permanent upgrade purchases. |
| Persistent Menu | Provides tabs for shop, gear, abilities, ascension, and development/debug views. |
| Run Session | Tracks the active run and accumulates reportable segment data. |
| Network Client | Handles auth, profile loading, run start, run reports, and purchases. |
| Profile Cache | Stores the last known accepted profile, profile version, seed lease, and queued offline deltas for responsive UI. |

## Progress Reporting

The client should periodically submit progress reports, likely around every 60 seconds at first. A report should be compact, deterministic where possible, and tied to a server-issued run session.

Route generation should be deterministic. The client receives a map seed from the backend when a run starts, then uses the shared generation algorithm and content version to assemble the same tile sequence the backend can reconstruct.

Candidate report fields:

- Account id or auth context.
- Run session id.
- Seed lease id.
- Report sequence number.
- Client timestamp and elapsed segment time.
- Content version.
- Map seed reference or run session generation context.
- Tile index range, route distance, or segment identifiers.
- Starting player state reference.
- Gold collected.
- Other resources collected.
- Enemy kills by type or content id.
- Pickups collected by id, group, or count.
- Ability activations and timing.
- Powerup drops, pickups, and active durations.
- Secret route entries, challenge course completions, and shop unlock flags.
- Upgrade or gear changes since the previous report, if allowed during runs.
- Client app version and platform.

The server should not trust these fields blindly. They are evidence used for validation, not proof.

Reports should be built from the state store's action log rather than from scattered UI or scene state.

## Reconciliation

The client may show predicted rewards immediately, but should reconcile once the backend responds.

Possible server outcomes:

- Accepted exactly.
- Accepted with adjusted rewards.
- Rejected and rolled back to last accepted state.
- Accepted but flagged for review.
- Requires profile refresh.

The UI should make normal reconciliation feel invisible. Only severe mismatches should require player-facing messaging.

## Gear UI Notes

The MVP shop should make repeatable gear purchases feel quick and readable.

The gear menu uses one row per piece. Each row should show:

- Gear icon, name, and description of its effects.
- Current level.
- A right-aligned button to buy the next level, with the next cost on the button.
- Green buy-button styling when current gold covers the cost, red when it does not, for available gear. Keep the price visible in both states.
- Current global gold bonuses and contributions to coin value, enemy gold, gold per metre, and any separately defined passive income where applicable.
- Current contributions to damage, health, and defence where applicable.
- Unlock requirement for the next gear piece, with exact locked-row presentation still open.
- One level bought per default button press. Bulk-buy modes remain optional later enhancements.

The client can preview gear costs and stat changes locally, but the backend response is authoritative after purchase.

## Discovery Unlocks and Biome Badges

Provide an Unlocks section for everything found and unlocked through discovery in the world. This includes discovered abilities, mushroom and other powerup drop types, and other discovery rewards as they are defined. Read entries from the shared discovery/unlock state. A type being unlocked for future drops is distinct from its effect currently being active; the UI should reflect the applicable state.

Show a badge for each biome beaten in the current World+ world level. Use clear records belonging to that current world level and run. Entering a new world level starts its own completion progress; a clear in an earlier world must not make the current-world badge appear earned. Exact placement, artwork, and display of unbeaten biomes remain open. Update badges from predicted completion state and reconcile them with the accepted profile like other progress UI.

## Mobile Considerations

- Support app pause, resume, backgrounding, and network loss.
- Avoid losing the active report if the app is killed.
- Require internet for normal play, with two-minute routine checkpoints and a proposed further 1-2-minute retry allowance after a checkpoint is due for intermittent reception.
- Persist pending progress during dropouts and checkpoint promptly when connectivity returns.
- Stop extending active progression after grace expiry and preserve the queue until a successful checkpoint.
- Show separately calculated gold-only earnings on return from closed-app time; initial away rewards do not advance bosses, levels, or discoveries.
- Keep input simple and readable on small screens.
- Ensure combat and rewards remain legible under visual effects.
- Design for variable frame rate without changing progression math.

## Tile Generation Notes

The first route system should use a small library of authored tiles with connector rows. A simple early tile might enter at Y row 2 and exit at Y row 2, allowing it to connect to other row 2 tiles. MVP tiles use a 15-block height with variable widths.

Tiles can also contain secret level connections, such as cloud entrances above the main route. These should be authored as data-visible triggers so completion can grant immediately usable abilities in a way the backend can validate.

The client should not use Godot's default random behavior for authoritative route choices unless the backend can reproduce it exactly. Route generation should use a documented shared RNG implementation, with deterministic random-number consumption.

## Open Questions

- Which Godot version will be used?
- Which client systems should be scenes, autoloads, resources, or pure scripts?
- How should shared tile metadata be represented in Godot?
- Should run simulation beyond tile generation be deterministic enough for the server to replay?
- Can upgrades happen mid-run, or only between run segments?
- What is the minimum supported device class?
