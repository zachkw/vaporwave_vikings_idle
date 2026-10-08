# Game overview

Vaporwave Vikings Idle is a mobile idle runner. A Viking runs left to right on his own, earns gold from distance, coins and kills, and spends it on gear that makes him earn faster. On top of that sit a hallucination hook, hand-made assault courses, a world to push through, and an ascension and Village layer for the long game.

The visual version of this page is the "Game Design" frame on the [Miro board](https://miro.com/app/board/uXjVEeSYwdg=/).

## The hook

The Viking eats natural ingredients (leaves, mushrooms, flowers, herbs), hallucinates, and sees into another dimension. The background shifts colour, a dimension set piece appears behind the play space, and extra enemies from that dimension join the real-world ones. More enemies means more gold. This is where the vaporwave look comes from and it is the game's main selling point. See [Biomes and dimensions](biomes-and-dimensions.md).

## Player flow

The game is one core loop with three systems around it.

### The core run (seconds)

1. The Viking auto-runs. A tap jumps; a tap in mid-air casts the wand.
2. He kills enemies, collects coins and covers distance. Elites stop him for a fight.
3. He earns gold from all three, boosted by crits.
4. The player spends gold on gear levels. New gear slots open as gold grows; the Legs unlock sprint.
5. He is stronger and richer, and the loop repeats.

Setbacks loop straight back in: a pit fall drops him back in from the sky, and a death restarts the level with gold and gear kept.

### What players find (minutes)

- **Assault courses.** Jumping early into a cave pit, or climbing to a sky course, starts a hand-made jumping course. Clear it and something unlocks: an artefact, an ingredient or a pickup. One fall fails; the player can retry with an ad or return to the surface. A cleared course later comes back as a farm full of coins and enemies. See [Courses and unlocks](courses-and-unlocks.md).
- **Ingredients.** Surface boxes hold ingredients. Eating one opens a dimension and adds its enemies to the run.
- **Gear and artefacts.** Artefacts and weapons found in courses add abilities and gold boosts. See [Gear and artefacts](gear-and-artefacts.md).

### Where players go (the area and the world)

- Each area ends in an automatic boss fight. Win and the Viking moves to the next level or biome and earns a biome badge. Lose and the area repeats while the player farms more gold.
- When every biome is beaten, World+ starts: the same biomes again, harder and richer, with random portals.
- Eventually gear can no longer keep up and growth slows. That is the cue to ascend.

See [Progression](progression.md).

### The long game (hours and days)

- **Ascension.** The player chooses to ascend. Everything resets unless a talent made it permanent. Ascension points come from lifetime gold, and each one raises the ascension level. Points buy talents in a large web.
- **Village.** Talents unlock Village buildings. Workshops turn pelts and demon hide into artefact upgrades and goods. The garden grows ingredients, and mixed garden ingredients last the whole level (tentative).

See [Progression](progression.md) and [Village](village.md).

## Design principles

- **Volume over polish.** The genre rewards a lot to chase more than finish. A fun experience with the right chase is the goal.
- **Low mechanics, low stakes.** With auto jump and auto attack there is little to get wrong, so a busy screen is fine as long as it stays readable.
- **One art style, multiplied.** Make one style of assets, then use AI to multiply it into the full set.
- **Assault courses are the level design.** They are hand-made and one of the few designed spaces in the game, so their feel matters most.
- **Every system feeds gold.** Ingredients, artefacts, the Village and ascension all exist to raise gold per second in some way.
- **Easy is best for now.** Where a question is open, build the simplest version first.

## Where to read next

| Doc | Covers |
| --- | --- |
| [Controls and combat](controls-and-combat.md) | Tap controls, sprint, enemy roles, elites, death, pits, bosses, crits |
| [Biomes and dimensions](biomes-and-dimensions.md) | Biome template, level types, ingredients, dimension enemies, biome roster |
| [Courses and unlocks](courses-and-unlocks.md) | Assault courses, the difficulty grid, farms, pickups |
| [Gear and artefacts](gear-and-artefacts.md) | The 22 gear slots, artefacts, weapon families, materials |
| [Economy](economy.md) | The gold model, crits, costs, away gold, daily rewards, ads |
| [Progression](progression.md) | Areas, bosses, World+, portals, ascension |
| [Village](village.md) | Buildings, garden and seeds |
| [Level generation](level-generation.md) | How surface levels are assembled from tiles |
