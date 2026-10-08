# Dimensions

Purpose: ingredient boxes, eating ingredients, running dimension effects, and the colour shifts and set pieces that show them.

## Rules

- **Unlock first.** An ingredient only appears in boxes once it is unlocked, by clearing the course that holds it.
- **Boxes.** Box slots in segments are filled by the level builder's box pass with unlocked ingredients found in the biome. The Viking knocks a box from below (a jump under it, or auto-collect if he runs through its trigger) and eats the ingredient at once.
- **Effect.** Eating starts that ingredient's dimension:
  - its colour shift fades in over 1 s,
  - its background set piece appears behind the play space,
  - its enemies are added to segments streamed in from now on.
- **Duration (tentative).** A raw ingredient from a box lasts `raw_timer_s` of play time. A mixed garden ingredient lasts until the level ends. Eating the same ingredient again while it is active resets its timer to full (proposed; June's rule added durations together).
- **Stacking.** Several dimensions can be active. Colour shifts blend, set pieces layer, enemy pools add up.
- **Ending.** When an effect ends, its colour shift fades out over 1 s and no new enemies of that dimension spawn. Enemies already on screen stay until killed or passed.
- **Death.** Effects survive death (tentative). Pit falls never affect them.
- **Where it works.** An ingredient only reveals enemies in biomes in its `works_in` list. Eaten elsewhere it still shifts colour (proposed) but adds no enemies.
- **Auto-consume (later).** Rules like "eat a torched red flower on entering Volcano Land" fire from bag stock. Not in the first build.

## Content data

`ingredients.json`: `id`, `found_in`, `works_in`, `reveals`, `raw_timer_s`, `colour_shift`, `set_piece`. See [Content data](content-data.md).

Colour shifts are named presets (a hue rotation, saturation boost and tint, or a palette swap shader) defined by the art style; the system only switches presets.

## State and actions

| Action | Reducer effect |
| --- | --- |
| `INGREDIENT_EATEN` | Adds an entry to `effects` with id, form and end time; counts the eat in `stats` |
| `TIME_ADVANCED` | Removes effects whose end time has passed |
| Level change | Removes mixed-form effects |

Reads: `active_effects`, `enemy_pool(biome)`.

## Godot

- `systems/dimensions.gd`: listens to `effects` changes and drives the colour-shift shader and set-piece nodes.
- One full-screen colour-shift shader on the run's canvas layer, taking a list of active presets.
- Set pieces as background nodes per dimension, toggled with a fade.

## Acceptance

- After clearing the first course, spirit leaf boxes start appearing in Dark Forest levels.
- Eating one shifts the colour, shows the set piece, and adds forest spirits to the next segments.
- The effect ends after its timer; the colour returns and no new spirits spawn.
- The run stays readable: the Viking, enemies and coins are clear under the shift.

## Open

D1, D2 (durations), D4 (box frequency), D5 (set pieces), timer refresh vs add.
