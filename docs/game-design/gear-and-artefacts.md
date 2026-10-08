# Gear and artefacts

Gear is the main gold sink: the thing the player can always spend on. Artefacts are a second kind of upgrade, found in the world rather than bought.

## Gear

- The Viking wears one item per slot. There are 22 slots: the sword, 16 worn slots, and 5 ranger and wizard set pieces.
- Each slot is levelled with gold. Core gear never needs materials.
- Slots unlock by **gold held in the wallet**, on a widening ladder. Reaching the bracket makes the slot available; the player still buys level 1 before it does anything. Proposed: once unlocked it stays unlocked even if gold drops (G6).
- Unlock order follows how exotic the piece is: warrior pieces first, under-layers and jewellery in the middle, ranger and wizard pieces last.
- A piece can carry a combat stat and a gold boost.
- Material tiers (leather, then the next material, ×2 and a new look) are parked (G2).

### Unlock ladder

Brackets are placeholders. They start about 10× apart, widen to 100×, then 1,000×.

| # | Piece | Group | Gold held to unlock | Combat stat | Gold boost |
| --- | --- | --- | --- | --- | --- |
| 1 | Sword | Warrior | Start | Damage | Gold from enemies slain |
| 2 | Chest | Warrior | Start | Defence | Proposed: all gold |
| 3 | Helmet | Warrior | Start | Health (likely) | Proposed: boss gold |
| 4 | Legs | Warrior | 10^2 | Grants sprint | Proposed: elite gold |
| 5 | Boots | Warrior | 10^3 | | Proposed: gold per metre |
| 6 | Gloves | Warrior | 10^4 | Crit chance | Gold from enemies slain |
| 7 | Shoulders | Warrior | 10^5 | | Proposed: basic enemy gold |
| 8 | Bracers | Warrior | 10^7 | | Proposed: gold per coin |
| 9 | Belt | Warrior | 10^9 | | Proposed: gold per coin |
| 10 | Cloak | Warrior | 10^11 | | Proposed: dimensional enemy gold |
| 11 | Undershirt | Under-layer | 10^13 | | Proposed: all gold |
| 12 | Socks | Under-layer | 10^16 | Sprint speed bonus | Proposed: gold per metre |
| 13 | Underwear | Under-layer | 10^19 | | Proposed: elite gold |
| 14 | Beard ring | Jewellery | 10^22 | | Proposed: boss gold |
| 15 | Finger ring | Jewellery | 10^25 | | Proposed: all gold |
| 16 | Necklace | Jewellery | 10^28 | | Proposed: all gold |
| 17 | Earring | Jewellery | 10^31 | | Proposed: dimensional enemy gold |
| 18 | Ranger coif | Ranger set | 10^34 | Ranged damage | Gold |
| 19 | Ranger vambraces | Ranger set | 10^37 | Ranged damage | Gold |
| 20 | Leather chaps | Ranger set | 10^40 | Ranged damage | Gold |
| 21 | Wizard hat | Wizard set | 10^43 | Magic damage | Gold |
| 22 | Wizard robe | Wizard set | 10^46 | Magic damage | Gold |

"Proposed" gold boosts come from the October proposal and are not confirmed (G3). The 17 regular pieces end near 10^31, matching June's ~10^30 target; the sets push the ladder to about 10^46 (E1).

Hidden or small slots (undershirt, underwear, socks, rings, necklace, earring) may only need an icon, not art on the Viking.

Open: full-set bonus and whether set pieces also take the matching warrior slot (G4); the gap between finding the bow and wand early and buying set pieces at 10^34 and up (G5).

### Level cost

Each level costs more than the last. The curve is open (G1): June's candidate is

```text
next_level_cost = base_cost × 1.15 ^ current_level
bulk_cost(level, count) = base_cost × 1.15 ^ level × (1.15 ^ count − 1) / 0.15
```

October's notes call levels "cheap, repeatable and linear". Pick one before tuning.

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
