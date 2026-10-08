# Runner

Purpose: move the Viking left to right through the streamed segments, handle jumping, auto-jump, sprint and pit falls, and report distance.

## Rules

- The Viking always runs right at `run_speed_mps` (1 block = 1 metre). He stops only when an elite or boss blocks him, or during death and respawn.
- **Tap on the ground:** jump. **Tap in mid-air:** cast the wand if one is equipped, otherwise nothing. Taps on UI buttons never jump.
- **Auto-jump:** when the Viking reaches the edge of a gap and the player has not jumped, he jumps automatically with a jump that clears the gap. An idle Viking never falls into a pit.
- **Dropping into a pit:** only happens when the player jumps early so the Viking comes down inside the gap, short of the far edge. If the pit is a cave entrance, the Viking enters the course; otherwise it is a pit fall.
- **Drop-in:** after a death or a pit fall, the Viking falls from the top of the screen and lands a little ahead, then keeps running. After a death he lands about a block ahead of where he died; after a pit fall, just past the pit. The air column he falls through may hold coins or enemies (see the drop-in pass in [Level builder](level-builder.md)). He can hit them on the way down.
- **Pit fall:** no damage, but it counts as a death that costs progress. A drop-in just past the pit, `PIT_FALLEN` is dispatched, and the level builder extends the level so the boss is a full level's length away again.
- **Sprint:** a button, visible only when `has_sprint` is true (Legs owned). Multiplies run speed for its duration, then cools down. Socks raise the multiplier.
- **Steps up:** a rise of one block is walked over; higher rises need a jump (auto-jump also handles steps the main route requires).

## Jump limits

These limits are the contract with segment authors (see [Level builder](level-builder.md)). The physics values must produce them at base speed.

| Limit | Value (placeholder) |
| --- | --- |
| Highest rise in one jump | 3 blocks |
| Widest gap at base speed | 4 blocks |
| Jump time, take-off to landing on flat | about 0.8 s |
| Coyote time after leaving an edge | 0.1 s |
| Tap buffer before landing | 0.1 s |

Sprint makes gaps easier but no main route may need it.

## Content data

`viking.json`: `sprint.speed_mult`, `sprint.duration_s`, `sprint.cooldown_s`. `economy.json`: `run_speed_mps`. Jump physics (gravity, jump velocity) are tuned in the scene to meet the limits above.

## State and actions

| Action | When |
| --- | --- |
| `DISTANCE_TRAVELLED` | Every 1 metre crossed (or batched each frame as a fractional amount) |
| `TIME_ADVANCED` | Every frame with the frame's play time |
| `SPRINT_USED` | When the sprint button starts a sprint |
| `PIT_FALLEN` | On a pit fall |
| `COURSE_ENTERED` | On dropping into a cave entrance or climbing into a sky course |

Reads: `has_sprint`, `sprint_speed_bonus`, `run.sprint_cooldown`.

## Godot

- `scenes/viking/viking.tscn`: `CharacterBody2D`, animation player, attack area in front, hurt box.
- `systems/runner.gd`: movement, gap detection ahead (a ray or a small probe two blocks ahead at floor level), auto-jump, input handling.
- Input: one full-screen touch area under the UI; the sprint button is a UI control that consumes its own touches.

## Acceptance

- Left idle for 10 minutes, the Viking never falls into a pit.
- An early tap before a cave-entrance pit drops him into the course every time.
- Sprint appears only after Legs level 1 is bought.
- Every segment in the library can be crossed at base speed with auto-jump alone.

## Open

C4 double jump and jump dash. Exact drop-in distances and fall speed.
