# Decisions and open questions

This is the source of truth for the design. When any other doc disagrees with this one, this one wins, and the other doc should be fixed.

Last updated 8 October 2026.

## How to use this file

- Every decision lands here first, with its date, then in the doc for that system.
- Anything marked **tentative** was said as a "maybe" and should be confirmed before it is built.
- Anything marked **Claude's reading** is an interpretation that has not been confirmed.
- Working principle (Zach): **easy is best for now.** When a question is open, build the simplest option and revisit later.

## History

- **June 2026:** the first design and technical docs were written. They have been folded into this set and removed.
- **6 to 7 October 2026:** the biome, dimension-viewing, gear, artefact and Village design was worked out (Miro board and voice notes), then a long question-and-answer session settled the decisions below.
- **8 October 2026:** the docs were rewritten into this folder as one set. Work from here from now on.

## Decisions

### Controls and abilities (7 Oct)

- A tap jumps at any time. Auto jump is only a backup at pit edges, so an idle Viking never falls in. A tap in mid-air casts the equipped wand.
- A new Viking starts with the sword and jumps only.
- Sprint comes from gear: the Legs piece grants the sprint button, and Socks raise its speed bonus. Sprint should arrive very early.
- Claude's reading: the ranged and magic attacks arrive with the first ranged weapon and the first wand.

### Death, pits and bosses (7 Oct)

- The Viking dies regularly on a normal surface run, every few minutes for most of the game. Death restarts the level and keeps gold and gear.
- Pits are not a death. Falling in drops the Viking back onto the level from the sky, a bit further along. Sometimes there are coins in the sky to fall through, so falling can be the best move. Pits that are cave entrances still lead to caves.
- The boss is always an automatic fight at the end of the area. If the Viking is very weak the boss kills him at once with a signature move (the giant frog's tongue grabs him and eats him).
- Enemy roles are basic, elite and boss. Elites stop the Viking: he halts and fights until one of them dies.

### Dimension effects (7 Oct, tentative)

- Death probably does not end a dimension effect.
- A found ingredient probably runs on a timer instead.
- Garden ingredients are mixed with something to make a smoother effect that lasts the whole level. So there are two forms: raw (from surface boxes, timed) and mixed (from the garden, whole level).

### Garden and seeds (7 Oct)

- The player has to get the garden first. Once they have it, achievements appear: "eat this plant N times to unlock 1 seed".
- This replaces "first seed at 50 finds".
- Claude's reading: the garden comes from an ascension talent.

### Gear (7 Oct)

- One item per slot, 22 slots including the ranger and wizard set pieces. See [Gear and artefacts](game-design/gear-and-artefacts.md).
- Slots unlock by gold held in the wallet, on a widening ladder. When a slot unlocks the player still has to buy level 1.
- Unlock order follows how exotic the piece is: warrior pieces first, under-layers and jewellery in the middle, ranger and wizard pieces last.
- Core gear is bought with gold only. No materials.
- Material tiers on core gear are parked: not decided, and not meant to be extravagant.
- Chest carries defence. Health sits on another piece; Helmet was the example, so Helmet = health is likely but not locked.
- Sword gives damage and gold from enemies slain. Gloves give crit chance and gold from enemies slain.
- Wizard pieces give gold and magic damage. Ranger pieces give gold and ranged damage (bow and throwing axes). Claude's reading: they are their own rows on the ladder.

### Materials (7 Oct)

- Leathers and other drops are for making money, making your villagers and Village stronger, and upgrading artefacts. They are never spent on core gear.

### Weapons and artefacts (7 Oct)

- The player equips one wand and one ranged weapon.
- Everything else is passive and works at once. The Sword is the only melee weapon swung; Hunting Axe, Thunder Hammer, Whetstone and Golden Whetstone run in the background.
- Artefacts can be upgraded with materials (for example the Obsidian Hunting Axe).

### Assault courses (7 Oct)

- One fall fails the attempt. The player then retries with an ad or goes back to the surface.

### World structure (7 Oct)

- World+ stays: once every biome is beaten, the same biomes repeat harder and richer.
- Random portals stay: after a full clear, portals can send the Viking to a random biome.

### Ascension (7 Oct)

- Ascension level equals points earned. Each point, earned from lifetime gold, raises the level by one.
- Nothing survives an ascension by default. Things persist only when the player owns a talent that makes them permanent. This covers gear, artefacts, ingredient and pickup unlocks, and course completions.

### First build (7 Oct)

- Dark Forest, with a light backend: vine plants, moss golem, giant frog, one ingredient, one course. See [First build](production/first-build.md).

### State and sync (7 Oct)

- Player state lives in one Redux-style store: actions, reducers, selectors.
- The game is playable offline and validated later. The device save is the working copy.
- Sync sends only the difference since the last sync. The server checks that the gold in it was possible in the time played.
- Saving happens at checkpoints and when the app closes or goes to the background.
- See [State store spec](technical/state-store-spec.md).

### Documentation (8 Oct)

- The `docs/` folder in this repo is the single source of truth. The June docs were removed once this set covered them.

## Open questions

Each has a number so it can be referred to. Proposed defaults, where there is one, are in brackets.

### Gear

- G1. Level cost: 1.15x per level (June) or linear (October)?
- G2. Parked: whether core gear has material tiers at all, and whether the Viking's look changes as gear levels.
- G3. Gold boost for each slot not yet decided. The October proposal is in [Gear and artefacts](game-design/gear-and-artefacts.md).
- G4. Any full-set bonus? Do set pieces also take the matching warrior slot?
- G5. Set pieces sit at the end of the ladder (10^34 and up), but the bow and wand are found much earlier. Is that gap intended?
- G6. Does an unlocked slot stay unlocked if gold drops below its bracket? [Yes]

### Materials and Village

- V1. How do materials make money: sold directly, or crafted into goods first?
- V2. What does "making your villagers strong" mean: levels, gear or stats, and what does a stronger villager do?
- V3. What does a stronger Village do for the run?
- V4. Do Village buildings, seeds and stock persist through later ascensions?
- V5. Hunting lodge output. Which building upgrades artefacts?
- V6. Are villagers a managed resource or just a timer?

### Combat and death

- C1. What kills the Viking on the surface: contact damage, elite fights, both?
- C2. Does death clear timed pickups?
- C3. Can coins crit? Is the crit-chance dampener accepted?
- C4. Do double jump and jump dash (June) still exist?
- C5. How weak is "very weak" for the boss's instant kill, and is there a warning?

### Ingredients and dimensions

- D1. Confirm the tentative model (raw timed, mixed whole level). How long is the raw timer? What is the garden ingredient mixed with, and where?
- D2. Does "whole level" mean one level, one biome visit, or until the boss?
- D3. How is the garden acquired, and how many eats per seed?
- D4. How often ingredient boxes appear on the surface.
- D5. Stone flower's biome list; set pieces for spirit leaf and evil mushroom.
- D6. Garden growth time and yield.
- D7. What the apothecary's balms, medicines and remedies do.

### Assault courses

- A1. How many letter tiers? One fixed artefact per course, or a pool per tier?
- A2. Is there an access system? Any limit on ad retries?
- A3. Where does the Viking come back to on the surface?
- A4. How often do farm courses appear, and how rich are they?

### Artefacts, weapons and pickups

- P1. Does an artefact that matches a gear slot replace it or sit alongside? What does Speed Socks do now that Legs grant sprint?
- P2. Are artefact levels bought with gold, materials or both?
- P3. Do boosts to the same gold source add or multiply?
- P4. Cloud Ring vs cloud boots: keep both or merge? Duration of every pickup.
- P5. Are gem coins (sapphire, ruby, emerald) still in?

### World structure

- W1. How many levels per biome, and what raises a biome's level within a world?
- W2. Biome order after Grassland.
- W3. Content for Grassland and Frost Mountain; Volcano Land's elite, boss, tiles and backgrounds.
- W4. How often sky coins appear on a pit fall, and how far along the Viking lands.

### Ascension

- S1. Is the first ascension still offered on beating World+1?
- S2. Talent web shape and the list of gateway talents, including a "make permanent" talent for each kind of unlock.

### Economy

- E1. Top gold number at launch (the draft gear ladder implies about 10^31, or 10^46 with sets).
- E2. Starting split between distance, coins and enemy gold.
- E3. Away-gold rates (June proposed 50, 25, 10, 5 and 1 percent).

### Build and tech

- T1. Is the surface generated from authored tiles, with only the courses hand-made?
- T2. Which ingredient and which course go in the first build? Does it include the Village or ascension?
- T3. Can the player ascend offline? [No: ascension and talent purchases need a sync first]
- T4. When two devices disagree, who wins? [Ask the player which save to keep]
- T5. If trimmed gold was already spent? [Wallet stops at zero, purchases stay]
- T6. Margin on the server's gold bound? [2 times the expected rate]
- T7. Any cap on how long unvalidated offline play can run? [None; old segments merged hourly]
- T8. Do bag inventory (ingredients, materials) and the Village reset on ascension?

### Parked

- The "special counter" and "perma counter" stickies on the Miro board: Zach doesn't know what they are yet.
