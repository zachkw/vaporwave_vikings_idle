# Level generation

Surface levels are assembled from small hand-authored tiles, so the run feels endless and varied while every piece was designed. Assault courses are different: each is a whole hand-made level.

Open (T1): confirm that the surface is generated this way and only the courses are hand-made. This doc assumes so.

## Tiles

- A tile is an authored piece of route: terrain, platforms, coins, enemy spawn points, ingredient boxes, pits and optional course entrances.
- Tiles are 15 blocks high and any width (for example 10, 16, 20 or 32 blocks). A block might be 16 by 16 pixels; that can change with the art.
- Each tile is tagged with the biomes it belongs to, so one biome asset pack fills the same tile shapes.

## Connector rows

Each tile has one entry and one exit, given as the floor row at the seam. A tile can only follow a tile whose exit row matches its entry row.

```text
Tile A exits at row 2.
Tile B enters at row 2.  -> B can follow A.
Tile C enters at row 2 and exits at row 7.
The next tile must enter at row 7.
```

- Keep connector rows inside a tight band (say rows 2 to 10) so the route cannot drift off screen.
- The first tiles can all be row 2 to row 2, then widen once the runner feels right.
- The main route must always be completable without any optional ability. Higher platforms can hold better rewards.

## Tile data

| Field | Purpose |
| --- | --- |
| `tile_id` | Stable id |
| `width_blocks` | Width |
| `biomes` | Biomes it can appear in |
| `role` | Ground, coin line, jump, enemy, elite, pit, cave entrance, sky entrance, boss approach, boss |
| `entry_row`, `exit_row` | Connector rows |
| `weight`, `cooldown` | How often it is picked and how soon it can repeat |
| `spawns` | Enemy spawn points and their roles |
| `coins` | Coin groups |
| `boxes` | Ingredient and pickup boxes |
| `entrances` | Cave pits and sky platforms, with the course pool they lead to |

Reward-bearing things live in tile data, not only in the scene, so the gold model and the server's bound can be computed from the same tables.

## Building a level

1. Start from a safe start tile.
2. Pick the next tile from those whose entry row matches the current exit row, filtered by biome, role, difficulty and cooldown.
3. Choose by weight using a seeded random number generator, so a level can be rebuilt from its seed.
4. After a set distance or tile count, place the boss approach tile, then the boss tile.
5. Courses are picked by the course rules in [Courses and unlocks](courses-and-unlocks.md): mostly A courses while A artefacts are missing, and completed ones come back as farms.

Early levels need guardrails so a new player meets things in a sensible order: ground and coins, basic enemies, a jump, an elite, then the boss.

## Open

- Should a level be rebuilt from the same seed after a death, or rolled again?
- Boss placement by distance, tile count or both?
- Should tile data live in Godot resources or in shared JSON that the backend can also read? (Shared JSON fits the server's gold bound best.)
