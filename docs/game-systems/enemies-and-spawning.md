# Enemies and spawning

Purpose: define every enemy as data, decide what spawns where, and run the basic, elite and boss behaviours.

## Rules

### Roles

| Role | Behaviour |
| --- | --- |
| Basic | Comes in packs on ground slots, or alone in air slots if it flies. Touching the Viking deals its attack once per attack interval. Usually dies to one sword hit. |
| Elite | Stands in an elite arena. When the Viking reaches it, he stops and both fight until one dies. |
| Boss | Stands in the boss arena at the end of the level. Same stop-and-fight rule, plus a signature move. |
| Dimensional | Any role, from an active dimension. Spawned into free slots while its ingredient is active. |

### Elites and bosses stop the Viking

1. When the Viking's front reaches the enemy's stop line, the runner halts and the fight starts.
2. Both sides attack on their own intervals. The Viking's ranged weapon and wand keep firing as usual.
3. If the enemy dies, the runner resumes. If the Viking dies, he drops back in just in front of an elite and fights again; against a boss see C6 in [Combat](combat.md).

### Boss signature move

- Before the fight, compare **time to kill** the boss with the Viking's current damage per second, and **time to die** from the boss's damage per second against his health and defence.
- If time to kill is more than 3 times time to die (placeholder, C5), the boss uses its signature move at once and the Viking dies. For the giant frog: the tongue grabs him and eats him.
- Otherwise the fight plays out normally.

### Spawn tables

Spawning is done by the level builder's fill passes; see [Level builder](level-builder.md). Per biome, `biomes.json` lists:

```json
{
  "id": "dark_forest",
  "basic": ["vine_plant"],
  "elite": ["moss_golem"],
  "boss": "giant_frog",
  "pack_size": { "min": 2, "max": 5 },
  "ingredients": ["spirit_leaf", "evil_mushroom"]
}
```

Dimensional density per ingredient (placeholder): one extra ground enemy per pack slot group, or one flyer per air slot, at 50 percent fill.

## Content data

`enemies.json` fields: `id`, `role`, `health`, `attack`, `attack_interval_s`, `gold`, `flying`, `drops` (material id and chance), `signature` (bosses only: animation id). Dark Forest values are in [Content data](content-data.md).

## State and actions

| Action | When |
| --- | --- |
| `ENEMY_KILLED` | On death, with enemy id, role, dimension (if any) and whether the killing hit crit |
| `MATERIAL_GAINED` | When a drop rolls |
| `BOSS_DEFEATED` | When a boss dies (in addition to `ENEMY_KILLED`) |
| `PLAYER_DAMAGED` | When an enemy hit lands |

Reads: `enemy_pool(biome)`, `damage`, `max_health`, `defence` (for the signature check).

## Godot

- `scenes/enemies/<id>.tscn`: one scene per enemy, sharing a base `enemy.gd` with `health`, `attack`, `on_hit()`, `on_death()`.
- `systems/spawner.gd`: fills a streamed segment's slots from the tables.
- Elites and bosses carry a `StopLine` marker.

## Acceptance

- A Dark Forest level always shows vine plant packs, at least one moss golem that stops the Viking, and the giant frog at the end.
- A brand-new Viking is eaten by the frog's tongue at once; a moderately geared one fights it.
- With spirit leaf active, forest spirits appear in air slots of newly streamed segments.

## Open

C1 what damages the Viking during the normal run (contact only, or attacks too). C5 the instant-kill threshold and a warning. W3 other biomes' enemies.
