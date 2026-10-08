# Controls and combat

Controls are light: the Viking runs and attacks on his own, and the player mostly decides when to jump, when to sprint and what to buy. Decisions are dated in [decisions](../decisions.md).

## Controls

| Input | What it does |
| --- | --- |
| Nothing | The Viking runs left to right, swings his sword at anything in front of him, and auto-jumps at pit edges so he never falls in by accident. |
| Tap on the ground | Jump. |
| Tap in mid-air | Cast the equipped wand's spell (once a wand is owned). |
| Sprint button | Run faster for a short time, then cool down. Appears once the Legs gear slot is bought. |

Falling into a pit is a choice: the player jumps early, before the pit, and drops in. That is how cave courses are entered.

## Abilities and when they arrive

| Ability | Source | Notes |
| --- | --- | --- |
| Sword swing | Start | Automatic melee in front of the Viking. |
| Jump | Start | Manual, with auto jump as the pit-edge backup. |
| Sprint | Legs gear slot | Socks raise the sprint's speed bonus. Should arrive very early. June placeholders for feel testing: 3 s at 1.5x speed, 20 s cooldown. |
| Ranged auto-attack | First ranged weapon (Claude's reading) | Fires by itself whenever it can hit an enemy. Every ranged weapon pierces. |
| Magic attack | First wand (Claude's reading) | Tap in mid-air. The equipped wand decides the spell. |

The player equips one wand and one ranged weapon. Everything else they own works passively and at once. See [Gear and artefacts](gear-and-artefacts.md) for weapon families.

Open: do June's double jump and jump dash still exist (C4)?

## Enemy roles

| Role | Behaviour |
| --- | --- |
| Basic | Appear in packs along the run and usually die in one hit. The steady source of kill gold. |
| Elite | Stops the Viking. He halts and fights until one of them dies. The power check along the run. |
| Boss | Ends each area. An automatic fight that checks damage and survival. |
| Dimensional | Extra enemies from an active dimension. More things to kill, not a different kind of enemy; some are tougher or fly. They drop their own materials. |

Enemy roles are separate from which dimension an enemy belongs to. A dimensional enemy can be a basic or an elite. See [Biomes and dimensions](biomes-and-dimensions.md).

## Health, death and pits

- The Viking has health and defence. Chest gives defence; another gear piece (probably the Helmet) gives health.
- He dies regularly on a normal surface run, every few minutes for most of the game.
- Health regenerates gradually but generously out of combat.
- Death does not restart the level. The Viking drops back in from the sky about a block ahead, with full health, and keeps running. Very little interruption, no confirmation screen. Gold and gear are kept.
- Sometimes there are coins or enemies in the air to hit on the way down.
- Falling into a pit counts as a death that costs progress. The Viking drops back in just past the pit and runs on, but the level is extended so the boss is a full level's length away again, as if he had restarted. No visible restart; gold and gear are kept.
- Dying to the boss builds a brand-new level (new layout, same biome and level number) and the Viking starts at its beginning.
- Open (C7): does an ordinary enemy death also extend the level? Proposed: no.
- Because auto-jump stops an idle Viking from falling in, only a player who jumps early lands in a pit. Doing it on purpose buys more run before the boss: more farming, more chances at boxes and courses.
- Open: what exactly kills him on the surface (C1), and whether death clears timed pickups (C2). Death probably does not end dimension effects (tentative).

## Bosses

- Each area is a run with a boss at the end. The fight is automatic and checks damage, health and defence.
- Win and the Viking moves to the next level or biome. Lose and the area repeats.
- If the Viking is very weak, the boss kills him at once with a signature move. The giant frog's tongue grabs him and eats him.
- Boss health resets fully on every attempt, so repeated deaths cannot chip a boss down.
- Open: how weak counts as "very weak", and whether there is a warning (C5).

## Crits

- Any hit can crit. A crit deals more damage and the kill pays more gold.
- Three stats, each from its own source:

| Stat | Source |
| --- | --- |
| Crit chance | Gloves |
| Crit damage | Whetstone artefact |
| Crit gold multiplier | Golden Whetstone artefact |

- Crit chance gets diminishing returns from a dampener so it cannot run away. Suggested shape, not confirmed: chance = cap × rating / (rating + K).
- Some effects guarantee a crit and bypass the dampener: the Vine Wand roots enemies and hits on rooted enemies always crit; the Dead eye pickup makes every hit crit.
- On average, crits multiply enemy gold by 1 + crit chance × (crit gold multiplier − 1). A 10 percent chance of triple gold is worth +20 percent enemy gold.
- Open: can coins crit (C3)?
