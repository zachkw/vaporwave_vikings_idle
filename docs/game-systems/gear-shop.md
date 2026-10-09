# Gear shop

Purpose: let the player buy gear levels with gold, unlock new slots as gold grows, and turn gear levels into stats.

## Rules

- 22 slots in a fixed order (see [Gear and artefacts](../game-design/gear-and-artefacts.md)). The first build uses the ten warrior slots.
- **Unlocking.** A slot unlocks the first time the wallet holds at least its `bracket`. Once unlocked it stays unlocked. Unlocking gives no level; the player buys level 1.
- **Cost.** `next_level_cost = base_cost + step × level`. Linear, per slot.
- **Stats.** Each level adds the slot's `per_level` values. Every core slot has a `gold_per_metre` value, plus one extra effect (damage, defence, health, an ability, or later a percentage boost to one gold source). Percentage boosts add up within one source (proposed; P3).
- **Grants.** Some slots grant an ability at level 1: Legs grant sprint.
- **One tap, one level.** Bulk buy is a later extra.
- The shop is open from the run screen; the run keeps going behind it (proposed).

## Shop rows

| Part | Shows |
| --- | --- |
| Icon | The slot's art |
| Name and effect | For example "Sword: +0.2 gold per metre, +2 damage per level" |
| Level | Current level |
| Buy button (right) | Next cost; green when `can_afford`, red when not; disabled when red |

- Rows update instantly after any purchase or gold change.
- A buy-amount selector in the panel header: **x1, x10, x100, Max**. It applies to every row; a row's button shows the total price for that many levels (the linear sum, `Selectors.level_cost_sum`) and goes red when the wallet cannot cover the whole batch, so a bulk tap never buys a partial amount. Max shows how many levels fit right now (`Selectors.max_affordable_levels`, a binary search on the closed-form cost); when nothing fits it shows the next level's price in red. Built 9 Oct.
- Below the last unlocked row, one locked row shows the next slot's name and its bracket ("Unlocks at 10K gold held").
- Numbers use short notation (1.2K, 3.4M, then scientific). Affordability always compares full values.

## Content data

`gear.json`: `id`, `order`, `bracket`, `base_cost`, `step`, `per_level`, `grants`. See [Content data](content-data.md).

## State and actions

| Action | Reducer effect |
| --- | --- |
| `GEAR_LEVEL_BOUGHT` | Checks cost against `wallet.gold`, subtracts it, raises `gear.<slot>.level` |
| Any gold-adding action | Wallet reducer sets `unlocked` on every slot whose bracket is now reached |

Selectors: `next_level_cost(slot)`, `can_afford(slot)`, `next_slot_unlock`, plus every stat selector that sums gear.

## Godot

- `scenes/ui/shop.tscn`: a scrolling list of row scenes bound to selectors through the `Store.changed` signal.
- `state/reducers/gear.gd`, `state/selectors.gd`.

## Acceptance

- A new player sees Sword, Chest and Helmet buyable; Legs appear locked until 100 gold is held.
- Buying any gear level visibly raises the gold-per-second readout.
- Buying a level subtracts exactly `base_cost + step × level`.
- The server's spend check accepts every purchase made through the shop (shared test vectors).
- Sprint button appears the moment Legs level 1 is bought.

## Open

G2 material tiers, G3 gold boosts per slot, G4 and G5 set pieces, P3 stacking rule.
