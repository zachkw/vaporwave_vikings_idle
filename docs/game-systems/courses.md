# Courses

Purpose: run hand-made assault courses: entering from the surface, playing, failing or clearing, rewards and farms.

## Rules

- **Entry.** A cave course is entered by dropping into a cave-entrance pit. A sky course is entered by climbing the platforms in a `sky_access` segment to its top. Both dispatch `COURSE_ENTERED`.
- **The course.** A whole hand-made level (one scene per course), not built from segments. Same runner and controls. The auto-jump backup is off inside courses (proposed): jumping is the skill being tested.
- **Fail.** One fall fails. The player sees a choice: watch an ad to retry from the course start, or return to the surface. No ad available means return.
- **Clear.** Reaching the end marker clears the course: its reward unlocks, `COURSE_COMPLETED` is dispatched, and the Viking returns to the surface.
- **Return point.** The Viking returns to the surface just after the segment he entered from (proposed, A3).
- **Choosing a course.** When a level's plan has a course beat, pick the course: mostly A-tier courses for this biome while A rewards are missing; sometimes a higher tier; sometimes an already-cleared course as a farm. See [Courses and unlocks](../game-design/courses-and-unlocks.md).
- **Farms.** A cleared course plays again with its rewards replaced by dense coins and enemies, and no failure on falling (proposed).

## Content data

`courses.json`:

```json
[
  { "id": "df_cave_a1", "biome": "dark_forest", "kind": "cave", "tier": "A",
    "scene": "res://scenes/courses/df_cave_a1.tscn",
    "reward": { "type": "ingredient", "id": "spirit_leaf" } }
]
```

Reward types: `ingredient`, `artefact`, `pickup`.

## State and actions

| Action | Reducer effect |
| --- | --- |
| `COURSE_ENTERED` | Records the return point in `run` |
| `COURSE_FAILED` | Clears the course state; the scene returns to the surface or retries |
| `COURSE_COMPLETED` | Adds the course to `unlocks.courses` and grants the reward unlock |

## Godot

- `scenes/courses/<id>.tscn`: hand-made, with `Start` and `End` markers and a kill zone below.
- `systems/courses.gd`: loads the course scene, swaps it in for the surface, handles fail, retry and return.
- Ad retry calls a rewarded-ad interface stub in the first build.

## Acceptance

- Dropping into the Dark Forest cave pit loads the course; falling shows retry or return; clearing unlocks spirit leaf and returns to the surface just past the entrance.
- A cleared course chosen again plays as a farm.

## Open

A1 tiers and reward pools, A2 access and ad limits, A3 return point, A4 farm frequency, L5 how often a course is due.
