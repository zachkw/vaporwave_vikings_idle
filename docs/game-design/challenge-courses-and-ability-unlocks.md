# Challenge Courses and Ability Unlocks

This document defines the early direction for secret routes, cloud levels, challenge rooms/courses, ability unlocks, and discovered mushroom drop unlocks. Challenge rooms refer to the existing challenge-course system here.

The key rule is: a special ability becomes owned and usable immediately when discovered or earned by completing its challenge or boss. There is no initial shop purchase. Wealth-bracket items follow a different rule: reaching the bracket makes them purchasable, and buying level 1 grants their first effect.

## Purpose

Challenge courses should create skill gates inside the idle runner.

They reward precise movement and exploration with immediately usable new power. The gold-spending loop remains in repeatable gear and wealth upgrades; it does not delay using an earned special ability.

## Secret Route Entrances

Some generated tiles can contain secret level connections.

The simplest example is a cloud level entrance above the normal tile path. The player sees or reaches special blocks above the main route, jumps into them, and transitions into a cloud challenge course above the main map.

Secret route entrances can appear as:

- Cloud entrances above the main route.
- Cave entrances inside or below the main route.
- Underground entrances opened by later upgrades.
- High-platform route doors.
- Special challenge portals.

These entrances should be authored into tile metadata so both the Godot client and backend know they existed in the generated route.

## Cloud Level Example

A basic cloud level flow:

1. The main route generator places a tile with a cloud entrance.
2. The player reaches the entrance by jumping onto higher blocks or platforms.
3. The route transitions into a cloud challenge course.
4. The cloud course asks for more precise jump timing than normal play.
5. The player completes the course and reaches the end marker.
6. The run gains ownership of the course's special ability, such as double jump.
7. The player can use the ability immediately.
8. The interface shows the newly acquired ability and its controls.

This makes completing the cloud course immediately rewarding.

## Failure and Ad Retry

On failing a challenge room, the player can watch a rewarded ad for another try or return to the level from which they entered. Declining the retry returns them to that original level. Recommend the same return path when no ad is available or the ad is not completed, so an ad failure does not trap the player in the room.

The ad grants another attempt at the challenge; it does not grant its completion reward. Save the originating level/visit context through the room and any retry. Exact return position, whether retries restart the course or a checkpoint, any retry limit, and treatment of rewards already collected within a failed attempt remain open. Retry ads are separate from offline-gold doubling ads.

## Mushroom Discovery in Challenge Rooms

Mushrooms are first discovered by doing challenge rooms. A room's mushroom discovery/reward unlocks that type as a possible future drop during runs. Taking a later spawned mushroom activates its associated world overlay:

```text
Enter challenge room -> discover its mushroom -> unlock future drops of that type
-> eligible mushroom spawns during a run -> take the drop -> activate its world overlay
```

Mushrooms reveal Whacky World or Demon World. Both overlays can be active together while real biome enemies remain present. The additional enemies can damage the Viking, but mainly provide more mobs to kill and access to higher-grade materials. Other pickup effects can stack alongside them to provide multipliers and special effects.

Use each room's configured discovery/reward condition to grant the drop unlock. Which room grants each mushroom and whether the first discovery also activates an immediate effect remain open. The continuing drop source, spawn chance, and duration values also remain to be designed. Repeating the same pickup adds its full duration to its remaining effect; garden-grown and world-dropped versions are different items whose buffs can coexist. Challenge-room discovery is confirmed specifically for mushrooms; flower and other pickup discovery sources have not yet been assigned.

Keep the mushroom drop-unlocked flag separate from the currently active effect. Existing direct ability rewards, such as double jump or speed boost, still become usable immediately when earned; the mushroom reward makes its future drops eligible. See [Abilities and Powerups](abilities-and-powerups.md).

## Ability Unlock States

Abilities should have distinct states:

| State | Meaning |
| --- | --- |
| `hidden` | The player has not discovered the ability or its source yet. |
| `locked` | The player can see the ability but has not met the requirement. |
| `owned` | The player earned or discovered the ability and can use it immediately. |
| `upgraded` | The player owns the ability and has bought one or more improvements. |

The exact UI can hide or reveal these states differently, but the progression data should keep them separate.

## Shop Relationship

Throwing axes, fireballs, sprint, and gem coins are special upgrades obtained through bosses and discoveries in the game world. Challenge courses can be one such source. Special abilities are usable immediately when earned; completing the speed route grants sprint directly.

The acquisition flows are:

```text
Discover or earn special ability -> ability becomes owned and usable
Discover mushroom in challenge room -> its future drops become eligible -> taking a drop activates its effect
Reach wealth bracket -> item becomes purchasable -> buy level 1 -> item effects apply
```

Specific content rewards still need to be assigned. Any later ability improvements may have their own purchase rules, but they do not gate initial use.

## Reset Rules

Challenge-course ability unlocks are confirmed run-level progression by default, like abilities earned from bosses or other discoveries.

They reset on ascension unless a purchased ascension retention unlock keeps them available. Retention unlocks are part of the intended progression; the exact roster and costs remain to be designed.

Candidate effects for the confirmed retention-upgrade system:

- Keep double jump owned after ascension.
- Start each run with cloud entrances revealed.
- Keep one completed challenge course reward.
- Preserve a selected discovered ability after ascension.

## Tile Metadata

Tiles with secret entrances should declare them explicitly.

Useful metadata:

| Field | Purpose |
| --- | --- |
| `secret_connections` | List of optional secret route entrances on the tile. |
| `connection_id` | Stable id for validation and progress reporting. |
| `route_type` | Cloud, cave, underground, portal, or another special route type. |
| `entry_position` | Where the player enters the secret route. |
| `required_abilities` | Abilities required to reach or complete the entrance. |
| `target_pool` | Tile pool or course id used after entry. |
| `completion_reward` | Unlock flag, currency, powerup, or other reward granted at the end. |
| `mushroom_discovery_reward` | Optional mushroom type/drop unlock and the room condition that grants it. Exact content schema remains to be designed. |
| `return_rule` | How the player returns to the main route, if applicable. |

This data should live alongside normal tile metadata, not only in scene logic.

## Validation Notes

The backend should be able to validate:

- The tile containing the secret entrance appeared in the generated route.
- The player could plausibly reach the entrance.
- The player entered only one mutually exclusive route where relevant.
- The reported challenge course existed for that entrance.
- An ad-funded retry has a verified, unconsumed retry entitlement tied to the failed attempt/course, and preserves the originating level context.
- The player had the required movement abilities.
- The completion time and reward are plausible.
- The resulting ability ownership or powerup-type unlock is allowed.
- A mushroom drop unlock is supported by its challenge-room discovery/reward condition, and later drops require that unlock.
- Subsequent ability use follows that accepted reward and the ability's rules.

This does not require perfect frame-by-frame replay at first. It does require that secret entrances, course ids, completion rewards, and granted ownership are data-visible.

## Prototype Scope

The first implementation can be very small:

- One main-route tile with a cloud entrance.
- One short cloud course.
- One completion marker.
- One ability granted immediately on completion.
- One interface state showing the acquired ability and how to use it.

A good first reward candidate is double jump or jump dash, because either one immediately makes route access feel different.

## Open Questions

- Should secret entrances be visible before discovery, partially hinted, or hidden?
- Where in the originating level does a failed room return the player, and where does an ad-funded retry restart the challenge?
- Is there a limit on ad-funded retries for one room visit, and what failed-attempt rewards are retained?
- Does the main route pause while the player is in the secret course, or does the course replace the current route segment?
- Which retention upgrades preserve ability availability, entrance visibility, or course completion flags?
- Which first ability should the first cloud course grant?
- Which challenge room discovers each mushroom type, and does the first discovery also activate its effect?
