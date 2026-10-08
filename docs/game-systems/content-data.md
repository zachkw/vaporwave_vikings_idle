# Content data

Purpose: every number the game uses lives in JSON under `vaporwave-vikings-idle/content/`. The Godot game and `backend-service` read the same files, so the client and the server always agree on what was possible.

## Rules

- One file per kind of content. Ids are lowercase snake case and never change once shipped.
- `content/version.json` holds a single `content_version` string. Every save and sync batch records it.
- All values marked *placeholder* below are for the first build only and will be replaced after the economy simulation.
- `content/test_vectors.json` holds sample states and the expected outputs of `expected_gold_per_second`, level costs and away bands. Godot tests and backend tests both run them.

## Files

| File | Holds |
| --- | --- |
| `version.json` | `content_version` |
| `economy.json` | Run speed, gold per metre, coin value, level length, away bands, sync margin |
| `viking.json` | Base health, damage, attack rate, regen, sprint, jump physics |
| `gear.json` | The 22 slots: order, bracket, base cost, step, stats per level |
| `enemies.json` | Every enemy: role, health, attack, gold, flying, material drop |
| `biomes.json` | Biome order, enemy lists, ingredients, segment pool, boss |
| `ingredients.json` | Each ingredient: biomes it works in, enemies it reveals, timer, colour shift |
| `segments/<biome>.json` | Segment metadata exported from the segment scenes (see [Level builder](level-builder.md)) |
| `courses.json` | Each course: biome, tier, scene, reward |
| `test_vectors.json` | Shared maths checks |

## Placeholder values for the first build

### `economy.json`

```json
{
  "run_speed_mps": 5,
  "gold_per_metre": 1,
  "coin_value": 6,
  "sync_margin": 2,
  "level_length_m": 1500,
  "away_bands": [
    { "from_h": 0,   "to_h": 12,   "rate": 0.50 },
    { "from_h": 12,  "to_h": 24,   "rate": 0.25 },
    { "from_h": 24,  "to_h": 48,   "rate": 0.10 },
    { "from_h": 48,  "to_h": 168,  "rate": 0.05 },
    { "from_h": 168, "to_h": null, "rate": 0.01 }
  ]
}
```

### `viking.json`

```json
{
  "health": 100,
  "sword_damage": 10,
  "attacks_per_second": 2,
  "regen_delay_s": 2,
  "regen_per_second_pct": 10,
  "sprint": { "speed_mult": 1.5, "duration_s": 3, "cooldown_s": 20 },
  "crit": { "cap": 0.5, "k": 100, "base_damage_mult": 2, "base_gold_mult": 2 },
  "physics": {
    "block_px": 32,
    "gravity_blocks_s2": 28,
    "jump_velocity_blocks_s": 14,
    "coyote_s": 0.1,
    "jump_buffer_s": 0.1,
    "drop_in_height_row": 14,
    "probe_ahead_px": 20
  }
}
```

### `gear.json` (first ten slots)

Decided 8 Oct: every core piece adds gold per metre plus one extra effect. Opening costs scale slot by slot (Sword 1, Chest 10, Helmet 100, Legs 250); from Boots on, `base_cost = bracket / 2`. `step = base_cost / 2` everywhere, so a slot's level cost rises linearly. Gold per metre per level is about a tenth of the level 1 cost in the early slots, so a level pays for itself in roughly ten metres.

| Slot | Bracket (gold held) | Level 1 cost | Step | Gold per metre per level | Extra effect per level |
| --- | --- | --- | --- | --- | --- |
| Sword | 0 | 1 | 1 | 0.2 | +2 damage |
| Chest | 0 | 10 | 5 | 1 | +1 defence |
| Helmet | 0 | 100 | 50 | 5 | +10 health |
| Legs | 100 | 250 | 125 | 10 | Level 1 grants sprint |
| Boots | 1,000 | 1,000 | 500 | 25 | +0.5% run speed |
| Gloves | 10,000 | 5,000 | 2,500 | 100 | +2 crit rating |
| Shoulders | 10^5 | 5 x 10^4 | 2.5 x 10^4 | 500 | +2% basic enemy gold |
| Bracers | 10^7 | 5 x 10^6 | 2.5 x 10^6 | 2.5 x 10^4 | +2% coin gold |
| Belt | 10^9 | 5 x 10^8 | 2.5 x 10^8 | 2.5 x 10^6 | +2% elite gold |
| Cloak | 10^11 | 5 x 10^10 | 2.5 x 10^10 | 2.5 x 10^8 | +2% dimensional enemy gold |

All placeholders until the economy simulation. Each entry carries `name`, `per_level` (with a `gold_per_metre` key and the extra effect) and an `effect` string for the shop row. The file is `vaporwave-vikings-idle/content/gear.json`.

### `enemies.json` (Dark Forest)

| id | Role | Health | Attack | Attack every | Gold | Flying | Drops |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `vine_plant` | basic | 10 | 5 | 1.0 s | 25 | no | |
| `moss_golem` | elite | 120 | 8 | 1.0 s | 150 | no | |
| `giant_frog` | boss | 1500 | 15 | 1.5 s | 500 | no | |
| `forest_spirit` | dimensional (spirit leaf) | 10 | 4 | 1.0 s | 15 | yes | |
| `demon_troll` | dimensional (evil mushroom) | 40 | 10 | 1.2 s | 15 | no | `demon_hide` |

### `ingredients.json` (Dark Forest)

```json
[
  { "id": "spirit_leaf",   "found_in": ["dark_forest"], "works_in": ["dark_forest"],
    "reveals": ["forest_spirit"], "raw_timer_s": 60, "colour_shift": "spirit_green" },
  { "id": "evil_mushroom", "found_in": ["dark_forest"], "works_in": ["dark_forest"],
    "reveals": ["demon_troll"],   "raw_timer_s": 60, "colour_shift": "demon_red" }
]
```

`raw_timer_s` is a placeholder for the tentative timed model (D1).

## Acceptance

- The game starts with no hard-coded gameplay numbers outside `content/`.
- Changing a value in `gear.json` changes the shop and the server's spend check with no code change.
- `test_vectors.json` passes in both Godot and backend test runs.

## Open

E1, E2 and the full balance pass. T2 decides which ingredient ships first.
