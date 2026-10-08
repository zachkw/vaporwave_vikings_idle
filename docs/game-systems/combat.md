# Combat

Purpose: resolve all damage between the Viking and enemies, including crits, health, defence, regeneration and death.

## Rules

### The Viking's attacks

| Attack | Trigger | Targets |
| --- | --- | --- |
| Sword | Automatic, at `attacks_per_second`, whenever an enemy is in the attack area in front | The nearest enemy in front |
| Ranged weapon | Automatic, whenever an enemy is in range and the weapon is off cooldown | Nearest enemy in range; pierces through every enemy in its line |
| Wand | Tap in mid-air | The spell's own pattern (fireball, icicles, lightning, vines) |

Ranged and wand arrive with the first weapon of each family (Claude's reading). The first build has the sword only.

### Damage

```text
damage dealt   = attack damage × (crit ? crit_damage_mult : 1)
damage taken   = enemy attack × 100 / (100 + defence)        (proposed)
```

- Sword damage = `sword_damage` + Sword level × `per_level.damage`.
- Defence comes from Chest; health from the health piece (probably Helmet).

### Crits

```text
crit_chance = cap × rating / (rating + k)                      (proposed, C3)
```

- `rating` comes from Gloves. `cap` and `k` are in `viking.json` (0.5 and 100 as placeholders).
- `crit_damage_mult` starts at 2 and is raised by the Whetstone; `crit_gold_mult` starts at 2 and is raised by the Golden Whetstone.
- The scene rolls the crit with the combat random generator and passes `crit: true` in `ENEMY_KILLED` when the killing hit crit, so the reducer pays crit gold.
- Guaranteed crits (Vine Wand roots, Dead eye pickup) skip the roll.

### Health and death

- Health regenerates after `regen_delay_s` without taking damage, at `regen_per_second_pct` of max health per second.
- At zero health the Viking dies: death animation, a short resurrection (placeholder 1.5 s), the level restarts from its start with full health. Gold and gear are kept. No confirmation screen.
- Pit falls never cause damage or death.
- Proposed: active dimension effects survive death (tentative decision); timed pickups end (C2).

## Content data

`viking.json`: health, sword damage, attack rate, regen, crit. `gear.json`: per-level damage, defence, health, crit rating. `enemies.json`: health, attack, interval.

## State and actions

| Action | Reducer effect |
| --- | --- |
| `PLAYER_DAMAGED` | Lowers `run.health` |
| `PLAYER_DIED` | Counts the death, restores health, resets level progress |
| `ENEMY_KILLED` | Pays gold, applying crit gold if `crit` |

Reads: `damage`, `ranged_damage`, `magic_damage`, `crit_chance`, `crit_damage`, `crit_gold`, `defence`, `max_health`.

## Godot

- `systems/combat.gd`: attack timers, target selection, crit rolls, damage application.
- Damage numbers and crit flashes are effects listening to actions.

## Acceptance

- Buying Sword levels visibly shortens moss golem fights.
- Buying Chest levels visibly reduces damage taken.
- With Gloves bought, crits appear and pay more gold, and the crit rate never exceeds the cap.
- Death never loses gold or gear.

## Open

C1, C2, C3 (crit formula and coin crits), C5.
