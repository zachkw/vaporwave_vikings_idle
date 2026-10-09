# Gear and artefacts

Gear is the main gold sink: the thing the player can always spend on. Artefacts are a second kind of upgrade, found in the world rather than bought.

## Gear

- The Viking wears one item per slot. There are 22 slots: the sword, 16 worn slots, and 5 ranger and wizard set pieces.
- Each slot is levelled with gold. Core gear never needs materials.
- Slots unlock by **gold held in the wallet**, on a widening ladder. Reaching the bracket makes the slot available; the player still buys level 1 before it does anything. Proposed: once unlocked it stays unlocked even if gold drops (G6).
- Unlock order follows how exotic the piece is: warrior pieces first, under-layers and jewellery in the middle, ranger and wizard pieces last.
- Every core piece adds **gold per metre**, the game's passive income (like coins per second in Idle Slayer, since the Viking never stops moving). Each piece also has one extra effect: a combat stat, an ability, or later a boost to one gold source. Decided 8 Oct.
- Material tiers (leather, then the next material, ×2 and a new look) are parked (G2).

### Unlock ladder

Costs follow Idle Slayer's shape (decided 9 Oct, see [Economy](economy.md#the-gear-ladder)): the gap between one piece's opening price and the next starts small and widens as the ladder climbs. A slot is revealed when the wallet holds half its level 1 cost ("gold held"), so the player sees the next piece a little before they can buy it. Everything from Boots on is a placeholder until the economy simulation.

| # | Piece | Group | Level 1 cost | Gold held to unlock | Gap from previous | Extra effect |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Sword | Warrior | 1 | Start | | Damage |
| 2 | Chest | Warrior | 10 | Start | 10x | Defence |
| 3 | Helmet | Warrior | 100 | Start | 10x | Health |
| 4 | Legs | Warrior | 250 | 100 | 2.5x | Grants sprint at level 1 |
| 5 | Boots | Warrior | 1,000 | 500 | 4x | Run speed (proposed) |
| 6 | Gloves | Warrior | 5,000 | 2,500 | 5x | Crit chance |
| 7 | Shoulders | Warrior | 30K | 15K | 6x | Basic enemy gold (proposed) |
| 8 | Bracers | Warrior | 250K | 125K | 8x | Coin gold (proposed) |
| 9 | Belt | Warrior | 2.5M | 1.25M | 10x | Elite gold (proposed) |
| 10 | Cloak | Warrior | 30M | 15M | 12x | Dimensional enemy gold (proposed) |
| 11 | Undershirt | Under-layer | 450M | 225M | 15x | Proposed: all gold |
| 12 | Socks | Under-layer | 9B | 4.5B | 20x | Sprint speed bonus |
| 13 | Underwear | Under-layer | 270B | 135B | 30x | Proposed: elite gold |
| 14 | Beard ring | Jewellery | 13.5T | 6.75T | 50x | Proposed: boss gold |
| 15 | Finger ring | Jewellery | 1.1Qa (10^15) | half | 80x | Proposed: all gold |
| 16 | Necklace | Jewellery | 1.3 x 10^17 | half | 120x | Proposed: all gold |
| 17 | Earring | Jewellery | 2.6 x 10^19 | half | 200x | Proposed: dimensional enemy gold |
| 18 | Ranger coif | Ranger set | 7.8 x 10^21 | half | 300x | Ranged damage |
| 19 | Ranger vambraces | Ranger set | 3.9 x 10^24 | half | 500x | Ranged damage |
| 20 | Leather chaps | Ranger set | 3.1 x 10^27 | half | 800x | Ranged damage |
| 21 | Wizard hat | Wizard set | 3.7 x 10^30 | half | 1,200x | Magic damage |
| 22 | Wizard robe | Wizard set | 7.5 x 10^33 | half | 2,000x | Magic damage |

Every row also adds gold per metre; the amount per level grows with the slot's bracket so the newest slot is always the best income buy. "Proposed" extra effects for slots 5 to 17 come from the October proposal and are not confirmed (G3). With the widening gaps the 17 regular pieces open near 10^19 and the sets near 10^34; level costs rise linearly on top, so the real top number is higher (E1).

Hidden or small slots (undershirt, underwear, socks, rings, necklace, earring) may only need an icon, not art on the Viking.

Open: full-set bonus and whether set pieces also take the matching warrior slot (G4); the gap between finding the bow and wand early and buying set pieces at 10^34 and up (G5).

### Level cost

Levels are cheap, repeatable and linear (decided 8 Oct): each level costs a fixed step more than the last.

```text
next_level_cost = base_cost + step × current_level
bulk_cost(level, count) = count × base_cost + step × (count × level + count × (count − 1) / 2)
```

`base_cost` and `step` are set per slot in the content tables. Because slots unlock on an exponential gold ladder, later slots have much larger base costs; the ladder, not the per-level curve, carries the exponential growth.

### Shop

- One row per piece: icon, name and effect, current level, and a buy button on the right that shows the next cost.
- The button is green when gold covers the cost and red when it does not; the cost shows either way.
- One tap buys one level. Bulk buying (10, 50, max) is an optional later extra.
- After a purchase every row's level, cost and colour update at once.
- Affordability compares full gold values, never the rounded label.
- The row for the next locked slot shows its bracket.

## Artefacts

- Found in assault courses, then levelled up. Each unlocks an ability and boosts a gold source.
- One piece of art each, no material tiers.
- **Level 0.** A new artefact gives its ability straight away but no gold until levelled.
- Everything except the equipped wand and ranged weapon works passively and at once.
- Some artefacts can be upgraded with materials into a stronger version.
- They reset on ascension unless the "keep artefacts" talent is owned.

| Artefact | Unlocks | Boosts |
| --- | --- | --- |
| Hunting Axe | Pelt gathering from enemies | Gold from enemies |
| Thunder Hammer | Zaps enemies every 10 seconds | Gold from enemies |
| Speed Socks | Was: sprint. Now open, since Legs grant sprint (P1) | Gold per metre |
| Wizard Wand | Fireballs | Not set |
| Ranger Bow | Piercing arrow | Not set |
| Whetstone | Higher crit damage | Gold from enemies slain |
| Golden Whetstone | Higher crit gold multiplier | Gold from enemies slain |

**Crafted upgrades.** The Obsidian Hunting Axe raises pelts harvested by 50 percent (a 50 percent chance of an extra pelt). Other artefacts have no crafted version. Which building crafts them is open (V5).

Open: does an artefact that matches a slot replace it or sit alongside (P1); are levels bought with gold, materials or both (P2); do two boosts to the same source add or multiply (P3).

## Weapon families

The family sets the behaviour; each weapon sets the flavour. Effects stay simple and reuse each other's visuals. The player equips one wand and one ranged weapon; the Sword is the only melee weapon swung.

| Family | Weapon | Effect | Reuses | Status |
| --- | --- | --- | --- | --- |
| Wand | Fire wand | Fireball that explodes in a small area | | Decided |
| Wand | Frost wand | Three icicle spears in an arc in front | | Decided |
| Wand | Storm wand | A bigger version of the hammer's lightning | Thunder Hammer zap | Decided |
| Wand | Vine wand | Roots all enemies in front; hits on rooted enemies always crit | Vine plant art | Decided |
| Wand | Stone wand | Drops a stone triangle on the nearest enemy | Stone-face art | Idea |
| Wand | Spirit wand | A wisp that homes in on flyers | Forest spirit art | Idea |
| Wand | Gust wand | Sweeps nearby coins to the Viking | | Idea (overlaps Magnetism) |
| Ranged | Ranger bow | Fast, flat piercing arrow | | Decided |
| Ranged | Francisca axes | Slow, heavy spinning axe that pierces | | Decided |
| Ranged | Javelin | Long throw that pierces a whole line | | Idea |
| Ranged | Returning axe | Pierces on the way out and back | Francisca spin | Idea |
| Ranged | Throwing knives | Three knives in a fan | Icicle arc | Idea |
| Melee | Magma mace | Ground slam that leaves a burning patch | Fireball explosion | Idea |

## Materials

Pelts, leathers, demon hide and other drops are used to:

- make money (sold directly or as goods: V1),
- make villagers and the Village stronger (V2, V3),
- upgrade artefacts.

They are never spent on core gear.
