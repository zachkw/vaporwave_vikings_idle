# Glossary

## Ability

A player-triggered or semi-automatic power with cooldowns, effects, and upgrades.

## Ability Unlock State

The progression state of a special ability, such as hidden, locked, owned, or upgraded. Discovery or the required content reward grants immediate ownership; no initial purchase is required.

## Action

A client-side event message that describes something that happened, such as collecting a coin, killing an enemy, buying gear, or receiving server reconciliation.

## Action Log

The ordered list of client-side actions since the last accepted server profile version. It is summarized into validation deltas.

## Ascension

The prestige reset system. The player sacrifices run-level gold, gear, world progression, and unprotected abilities in exchange for ascension points that buy permanent account upgrades. Players ascend when their current wealth and Chest/Axe progression limit further World+ progress.

## World+

Automatic progression to a higher world level after clearing the current world's level sequence, keeping current gold, gear levels, and abilities. Each world level presents the sequence again with higher gold rewards, alongside gentler biome difficulty growth within that world. Advancing World+ does not award ascension points or reset the build.

## Ascension Points

Permanent currency earned from lifetime gold progression, with an endlessly increasing gold increment required per successive point. Pending points are banked on ascension and can then be spent whenever desired on permanent upgrades. Ascension and spending do not restart lifetime point progress or the requirement curve.

## Authoritative Profile

The server-owned version of a player's durable progression, including currencies, upgrades, gear, and accepted rewards.

## Blocking Mob

An enemy that stops forward progress until defeated. Blocking mobs act as short power checks before major boss gates.

## Boss Gate

A world or zone endpoint where the player must defeat a boss to unlock the next area.

## Challenge Course

An optional skill-focused route, such as a cave, cloud path, underground path, or timed section, that offers stronger rewards or run-level unlocks.

## Cloud Level

A challenge course above the main route, usually entered from special blocks or a secret entrance in a generated tile.

## Content Version

A versioned set of game data used by both client and backend. It can include enemy stats, reward values, route metadata, upgrade costs, and gear definitions.

## Connector Row

A tile seam contract that defines the Y row where a tile can connect to another tile. For example, a tile exiting at row 2 can connect to another tile entering at row 2.

## Global and Source-Specific Gold Bonuses

A gear bonus can increase a particular source, such as coin value, enemy-kill gold, or gold per metre, or all sources as with the helmet. Only explicitly global bonuses affect all income. Global gear bonuses, bonuses by source, and ascension bonuses remain separately identifiable; exact stacking rules are still open.

## Delta

A client-submitted change set since the last accepted server profile version, including rewards, purchases, kills, pickups, powerups, and elapsed time.

## Efficiency Cap

A practical validation limit below the theoretical maximum reward for a segment. Reports above the cap can be clamped and tracked as trust score signals.

## Gear

Equipment that increases player power, gold generation, or other stats. Gear is expected to behave like a classic idle progression system.

## Gear Level

The repeatable purchase count for a gear slot. Each level adds stat contribution and increases the next purchase cost.

## Gear Power

Stat contributions derived from gear levels and each piece's role, used to calculate source-specific income bonuses, damage, health, or defence.

## Gear Slot

A repeatable gear category in the ordered gear ladder, such as Gear 1, Gear 2, or Gear 3. Display names can be assigned later.

## Gear Tier

A named milestone band for a gear slot, such as Bronze, Silver, Gold, Adamant, or Mithril. Tiers can be presentation labels over gear levels.

## Gold

The primary resource. Players earn gold from runs and spend it on upgrades, abilities, gear, and multipliers.

## Map Seed

A server-issued seed stored on the run session and used by both client and backend to generate the same tile sequence.

## Offline Bonus

Server-calculated gold for closed-app time, validated against real elapsed time on return and the last accepted profile. Earnings are reduced and uncapped, with rates declining at 12, 24, 48, and 168 hours. Initial away rewards do not defeat bosses or discover abilities. Later automation upgrades, likely in ascension, may expand that behavior.

A server-validated return and reward claim resets the away-rate schedule to the first band. Merely reopening locally without validation does not reset it.

## Progress Report

A client-submitted summary of rewards, kills, pickups, ability use, and elapsed time for a run segment.

## Powerup

A temporary modifier found during play, such as speed, magnet, flight, coin multiplier, horde event, or bonus damage.

## Run-Level Progression

Progress that belongs to the current run and normally resets on ascension, such as run gold, shop upgrades, temporary ability unlocks, and challenge course rewards.

## Run Segment

A short slice of gameplay that can be checkpointed and validated independently. The confirmed routine online cadence is two minutes. The proposed retry allowance is a separate 1-2 minutes after a checkpoint is due, permitting up to 3-4 minutes of provisional progress between validations.

## Run Session

A server-known gameplay session. A run session may contain many progress reports.

## Reducer

A deterministic client-side function that takes current state and an action, then returns the next predicted state.

## Seed Lease

A server-issued seed/session grant used to validate generated content. Active play uses two-minute routine checkpoints and a server-issued progression deadline. The proposed deadline includes a further 1-2-minute retry allowance after a checkpoint is due; this does not authorize extended offline play.

## Selector

A helper that reads a specific derived value from the client state store for UI or systems, such as current gold, next gear cost, or speed boost cooldown.

## Route Exclusivity

A content rule that marks rewards or paths as mutually exclusive. For example, the player may be able to collect rewards from the high route or the low route, but not both.

## Secret Level Connection

An optional entrance authored inside a tile that transitions the player into a special route, such as a cloud level, cave, underground path, or challenge course.

## Shop Unlock Flag

A progression flag that makes a shop item available for purchase without granting the item automatically.

## Special Box

A hit-from-below tile object that releases a seeded reward, such as magnetism, and can be validated from tile data.

## State Store

The client-side single source of predicted gameplay state. Systems dispatch actions to it, reducers update it, UI subscribes to it, and its action log feeds validation deltas.

## Tile

An authored route piece with terrain, rewards, enemies, and entrance or exit connector rows. Tiles are assembled by deterministic generation.

## Tile Library

The versioned set of authored tiles available to the route generator for a content version.

## Trust Score

A server-side account reliability signal affected by impossible, clamped, or repeatedly near-perfect reports. Low trust can restrict offline progression or lead to bans.

## Unlocked For Purchase

A wealth-item state where the player has reached the required bracket but must buy level 1 before receiving its effects. Special abilities earned through discovery use immediate ownership instead.

## Validation

The backend process that checks whether reported progression is plausible before committing rewards to the authoritative profile.

## World Progression

Horizontal content progression through worlds, routes, branches, bosses, caves, clouds, and other unlockable areas.
