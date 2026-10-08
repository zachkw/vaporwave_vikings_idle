# Biomes and dimensions

Every biome is built from one template, so each breaks down into the same asset pack. On top of the real-world biome sit the dimensions the Viking sees when he eats an ingredient.

## Biome template

Four biomes ship at launch: Grassland, Dark Forest, Volcano Land and Frost Mountain, with room for up to eight. Grassland is biome 1 in play order; the order of the rest is not set (W2). Dark Forest is the first one being built.

| Layer | What it is | Contents |
| --- | --- | --- |
| Foreground | Space the player interacts with | Floor, ledge, water and obstacle tiles; sky tiles; underground tiles |
| Background | Space the player does not interact with | Light source, parallax layers, low-detail scenery, cave tiles |
| Real-world enemies | Native to the biome, always present | Basic and elite along the run, boss at the end |
| Biome dimensional enemies | Seen only in this biome while its ingredient is active | One enemy type per ingredient |
| Global dimensional enemies | Seen in every biome their ingredient is tagged for | Stone-face people are the first example |
| Trigger ingredients | Natural items found in the biome | A leaf, mushroom, flower or herb per dimension |
| Dimension set pieces | Background-only effects during a hallucination | Colour shift plus a themed element per dimension |

**Biome or global is a tag.** Every ingredient lists the biomes where its enemies can appear. A biome ingredient lists one; a global one, like the stone flower, lists several. Late in the game a well-stocked garden lets the player use widely tagged ingredients everywhere.

## Level types

Each biome has three kinds of level, so each asset pack needs tiles for all three.

| Level type | Where | How the player gets there | What it gives |
| --- | --- | --- | --- |
| Surface | Ground level | Default | The main run, ingredient boxes, the boss at the end |
| Sky | Above the run | Jumping on platforms that sometimes lead up to a sky level | Unlocks: artefacts, ingredients, pickups and other one-off items |
| Underground cave | Below the run | Jumping early into a pit that is a cave entrance | The same kinds of unlock as the sky |

Sky and cave levels are hand-made assault courses. See [Courses and unlocks](courses-and-unlocks.md).

**Pits.** The surface has pits. Some lead to caves; an upgrade (likely a talent) always shows which ones. Falling into an ordinary pit is not a death: the Viking drops back in from the sky just past the pit, sometimes through coins or enemies.

## Dimensions

Each ingredient opens one dimension. While it is active:

- The background shifts colour and the dimension's set piece appears behind the play space. Set pieces are background only.
- That dimension's enemies spawn alongside the real-world ones. They are more things to kill, so more gold. Some are tougher or harder to reach, such as flyers.
- Dimensional enemies drop their own materials. Demon hide, for example, goes to the tanning bench.

**Stacking.** Several ingredients can be active at once. Colour shifts, set pieces and enemies layer on top of each other. Each active dimension adds another enemy term to the gold model, which is why stacking pays.

**How long it lasts (tentative).** A raw ingredient from a surface box runs on a timer. A garden ingredient mixed with something lasts the whole level. Death probably does not end an effect. Open: timer length and what "whole level" means (D1, D2).

**Getting ingredients.**

1. First find: an unlock from one of that biome's sky or cave courses.
2. Repeat finds: boxes on the surface, knocked open Mario-style. Grabbing one starts the effect again.
3. Later: the garden grows them. See [Village](village.md).

**Auto-consume.** The player can set rules such as "eat a torched red flower on entering Volcano Land". The rule fires whenever the ingredient is in the bag. (A talent may gate this; see [Progression](progression.md).)

### Known ingredients

| Found in | Ingredient | Works in | Enemies revealed | Background set piece |
| --- | --- | --- | --- | --- |
| Dark Forest | Spirit leaf | Dark Forest | Forest spirits (nature realm) | Not decided |
| Dark Forest | Evil mushroom | Dark Forest | Demon trolls | Not decided |
| Volcano Land | Torched red flower | Volcano Land | Flying demon imps | Not decided |
| Volcano Land | Stone flower | Several biomes (list not set) | Stone-face triangle people | Giant spinning triangle faces |

## Biome roster

### Dark Forest (first to build)

| Slot | Design |
| --- | --- |
| Foreground | Dark grassy tiles, moss stone tiles, normal water, tree stumps, wooden tree bridges |
| Background | Night moonlight, dense trees |
| Real-world basic | Vine plants |
| Real-world elite | Moss golem |
| Real-world boss | Giant frog (signature move: tongue grab) |
| Biome dimensional | Forest spirits, from spirit leaf |
| Biome dimensional | Demon trolls, from evil mushroom |

### Volcano Land

| Slot | Design |
| --- | --- |
| Real-world basic | Magma snails |
| Biome dimensional | Flying demon imps, from torched red flower |
| Global dimensional | Stone-face triangle people, from stone flower |
| Dimension set piece | Giant spinning triangle faces (stone flower) |

Tiles, backgrounds, elite and boss are still to be listed (W3).

### Grassland and Frost Mountain

Named as launch biomes. No enemies, ingredients or tiles yet (W3).

## Asset pack checklist

One pack per biome, in this shape.

**Tiles**

- [ ] Surface: floor, ledge, water, obstacle
- [ ] Sky platforms
- [ ] Underground cave

**Backgrounds**

- [ ] Light source
- [ ] Parallax layers
- [ ] Low-detail scenery
- [ ] Cave background

**Enemies**

- [ ] Real-world basic
- [ ] Real-world elite
- [ ] Real-world boss
- [ ] Dimensional enemy, first dimension
- [ ] Dimensional enemy, second dimension

**Ingredients**

- [ ] Trigger ingredient per dimension
- [ ] Seed per ingredient
- [ ] Material drop per dimensional enemy (demon hide, for example)

**Hallucination effects**

- [ ] Colour-shift treatment per dimension
- [ ] Background set piece per dimension

**Shared by all biomes**

- [ ] Coins
- [ ] Question mark boxes

Source: the [Miro board](https://miro.com/app/board/uXjVEeSYwdg=/) and the voice description of 6 October 2026.
