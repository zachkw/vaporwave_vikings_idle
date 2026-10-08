# Courses and unlocks

Sky and cave levels are hand-made jumping assault courses, and they are where the player unlocks new things. Pickups are the timed powers those unlocks feed into the run.

## Assault courses

- A sky course sits above the run and is reached by jumping on platforms that sometimes lead up. A cave course sits below and is reached by jumping early into a pit that is a cave entrance. Otherwise they work the same way.
- They are hand-made, one of the few designed spaces in the game. Their feel matters more than anything else in level design.
- An area may hold several of each.
- **One fall fails the attempt.** The player can then watch an ad to retry, or go back to the surface. The ad grants another attempt, never the reward.
- Clearing a course unlocks something: an artefact, an ingredient, a pickup, or another one-off item.
- Open: an access system for courses (A2), ad retry limits (A2), and where the Viking returns to on the surface (A3).

### Difficulty grid

Every course has a letter tier and a biome number. A is easier than B, and biome 1 is easier than biome 8.

| | Biome 1 | Biome 2 | ... | Biome 8 |
| --- | --- | --- | --- | --- |
| Tier A | A1 | A2 | ... | A8 |
| Tier B | B1 | B2 | ... | B8 |
| Tier C | C1 | C2 | ... | C8 |

- **The A row tracks the player's wealth.** A1 to A8 rise in step with normal progress through the biomes.
- **Higher letters are the stretch.** A C4 course can turn up in biome 4 and will feel very hard.
- **Generation favours what the player still needs.** While the player is missing A artefacts, most courses served are A courses.
- Open: how many letter tiers, and whether each course holds one fixed artefact or a tier shares a pool (A1).

### Farms

Completed courses keep appearing even when the player is well ahead. A course already completed comes back filled with coins and enemies, so finding one is a chance to farm heavily (A4: how often and how rich).

## Unlock flow

| Thing | First unlock | After that |
| --- | --- | --- |
| Artefact | Found in a course; works straight away at level 0 | Levelled up, sometimes upgraded with materials |
| Ingredient | Found in that biome's course | Appears in surface boxes; later grown in the garden |
| Pickup | Found in a course | Turns up in runs |

Everything unlocked resets on ascension unless a talent makes that kind of unlock permanent.

## Pickups

Pickups appear during a run and give a power for a limited time. They are a separate system from dimension ingredients. Each has to be unlocked first in a course; many are unlocked early so the player has plenty to play with.

| Pickup | Effect while active |
| --- | --- |
| Magnetism | Pulls all nearby coins to the Viking |
| Dead eye | Every hit crits. With luck it can cheese a boss |
| Gold multiplier | Multiplies gold earned |
| Gold rush | A long, densely packed line of coins appears |
| Enemy horde | Enemies appear densely packed for the duration |
| Spell overload | The wand fires continuously |
| Rapid fire | The ranged weapon fires continuously with no cooldown. It still auto-targets, and looks cooler than it is effective |
| Cloud boots | A big floaty jump and faster running, for about 90 seconds |
| Cloud Ring | A floaty jump for the duration |

Each pickup is a temporary pull on one lever of the gold model: coins collected, coins per metre, enemies per metre, crit chance, kill speed or the all-gold multiplier.

Open: Cloud Ring and cloud boots overlap (P4); durations are not set beyond June's 5 s placeholder for Magnetism (P4); whether death clears pickups (C2). The gust wand idea overlaps with Magnetism.
