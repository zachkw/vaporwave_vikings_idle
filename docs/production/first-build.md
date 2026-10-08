# First build

The first playable build is one biome, Dark Forest, with a light backend. Its job is to prove that running, earning, buying and the hallucination hook feel good, and that the store and sync hold together.

## Content

| Area | In the first build |
| --- | --- |
| Biome | Dark Forest: dark grass, moss stone, water, stumps, tree bridges; night moonlight, dense trees |
| Enemies | Vine plants (basic), moss golem (elite, stops the Viking), giant frog (boss, tongue-grab instant kill when far too weak) |
| Dimension | One ingredient, spirit leaf or evil mushroom (T2), eaten from surface boxes, with its colour shift and its enemies |
| Course | One hand-made assault course (sky or cave), one fall fails, unlocks the ingredient |
| Gear | The ten warrior pieces, Sword to Cloak, unlocking by gold held; Legs grant sprint |
| Controls | Auto-run, tap to jump, auto-jump at pit edges, sprint button |
| Setbacks | Death and pit falls drop the Viking back in from the sky a little ahead, keeping gold and gear; a pit fall extends the level; losing to the frog builds a fresh level |
| Shop | Gear rows with green/red buy buttons |
| Segments | A Dark Forest library of about 33 hand-made segments, mostly on rows 2, 5 and 8, that passes the [library linter](../game-systems/level-builder.md); levels about 5 minutes |

## Not in the first build

Artefacts and wands, pickups, farm courses, World+, portals, ascension, the Village, away gold, daily rewards and ads. Their state slices exist but stay empty.

## Technical

- `Store` autoload with the slices listed in the [state store spec](../technical/state-store-spec.md).
- Device save at checkpoints and on background.
- Batch builder and queue; `POST /api/v1/sync` on the backend with the revision, time, gold-earned and gold-spent checks.
- Guest sign-in only.

## Build order

Each step is playable or testable on its own.

1. `Store` autoload with the `wallet`, `gear` and `run` reducers, their selectors, and the device save.
2. Shop rows reading `next_level_cost` and `can_afford`, dispatching `GEAR_LEVEL_BOUGHT`.
3. Running, coins and enemies in Dark Forest dispatching the run actions; death and pit falls.
4. The boss fight and level advance.
5. Checkpoint triggers and the batch builder, logging batches to the console.
6. `POST /sync` on the backend, and the three answers handled in the store.
7. The course, the ingredient and the `effects` and `unlocks` slices.

## Done when

A player can start fresh, run through Dark Forest, buy gear, unlock and use sprint, die and carry on, clear the course, eat the ingredient and see its dimension, beat the giant frog, and have their progress survive closing the app and syncing to the server.

## Open

T2 which ingredient, E2 starting balance. Numbers for the build live in [content data](../game-systems/content-data.md).
