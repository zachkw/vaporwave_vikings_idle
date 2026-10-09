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

Costs copy Idle Slayer's first ten pieces exactly, scaled so the Sword opens at 2 gold (decided 9 Oct; see [Economy](economy.md#the-gear-ladder)). The gap between one piece's opening price and the next is small at first and widens up the ladder. A slot is revealed when the wallet holds half its level 1 cost, so the player sees the next piece a little before they can buy it. Pieces 11 to 22 continue the curve as placeholders until the economy simulation.

| # | Piece | Group | Level 1 cost | Gold held to unlock | Gap from previous | Extra effect |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Sword | Warrior | 2 | Start | | Damage |
| 2 | Chest | Warrior | 16 | Start | 8x | Defence |
| 3 | Helmet | Warrior | 250 | Start | 15x | Health |
| 4 | Legs | Warrior | 5.3K | 2.65K | 21x | Grants sprint at level 1 |
| 5 | Boots | Warrior | 40K | 20K | 7.5x | Run speed (proposed) |
| 6 | Gloves | Warrior | 400K | 200K | 10x | Crit chance |
| 7 | Shoulders | Warrior | 4.7M | 2.35M | 12x | Basic enemy gold (proposed) |
| 8 | Bracers | Warrior | 195M | 97.5M | 41x | Coin gold (proposed) |
| 9 | Belt | Warrior | 1.8B | 900M | 9x | Elite gold (proposed) |
| 10 | Cloak | Warrior | 110B | 55B | 61x | Dimensional enemy gold (proposed) |
| 11 | Undershirt | Under-layer | 1.5T (10^12) | half | 14x | Proposed: all gold |
| 12 | Socks | Under-layer | 7.3 x 10^13 | half | 48x | Sprint speed bonus |
| 13 | Underwear | Under-layer | 5 x 10^16 | half | 680x | Proposed: elite gold |
| 14 | Beard ring | Jewellery | 1.7 x 10^25 | half | 3 x 10^8 | Proposed: boss gold |
| 15 | Finger ring | Jewellery | 1.7 x 10^35 | half | 10^10 | Proposed: all gold |
| 16 | Necklace | Jewellery | 3.3 x 10^43 | half | 2 x 10^8 | Proposed: all gold |
| 17 | Earring | Jewellery | 1.7 x 10^51 | half | 5 x 10^7 | Proposed: dimensional enemy gold |
| 18 | Ranger coif | Ranger set | 1.7 x 10^61 | half | 10^10 | Ranged damage |
| 19 | Ranger vambraces | Ranger set | 10^65 | half | | Ranged damage |
| 20 | Leather chaps | Ranger set | 10^69 | half | | Ranged damage |
| 21 | Wizard hat | Wizard set | 10^73 | half | | Magic damage |
| 22 | Wizard robe | Wizard set | 10^77 | half | | Magic damage |

Pieces 11 to 18 follow Idle Slayer's pieces 11 to 18 (Spellbook to Shuriken) scaled by the same third; the four set pieces beyond that are a guess at 10^4 apart.

Every row also adds gold per metre; the amount per level grows with the slot's bracket so the newest slot is always the best income buy. "Proposed" extra effects for slots 5 to 17 come from the October proposal and are not confirmed (G3). On this ladder the 17 regular pieces open near 10^51 and the sets near 10^77, close to Idle Slayer's own ceiling (E1).

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
