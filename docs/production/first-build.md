# First build

The first playable build is one biome, Dark Forest, with a light backend. Its job is to prove that running, earning, buying and the hallucination hook feel good, and that the store and sync hold together.

## Content

| Area | In the first build |
| --- | --- |
| Biome | Dark Forest: dark grass, moss stone, water, stumps, tree bridges; night moonlight, dense trees |
| Enemies | Vine plants (basic, chip damage only, cannot kill), moss golem (elite, stops the Viking, can kill), giant frog (boss, tongue-grab instant kill when far too weak) |
| Start | 0 gold; coins along the floor from the first screen so the 1-gold Sword is bought within seconds |
| Dimension | Spirit leaf, eaten from surface boxes, with its colour shift and forest spirits |
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
- Done: batch builder and queue; `POST /api/v1/sync` on the backend with the revision, time, gold-earned, gold-spent and progress checks.
- Done: guest sign-in (the session token is kept on the device).

## Build order

Each step is playable or testable on its own.

1. Done: `Store` autoload with the `wallet`, `gear` and `run` reducers, their selectors, and the device save.
2. Done: shop rows reading `next_level_cost` and `can_afford`, dispatching `GEAR_LEVEL_BOUGHT`.
3. Done: running, coins and enemies in Dark Forest dispatching the run actions; death and pit falls.
4. Done: the boss fight and level advance.
5. Done: checkpoint triggers (level end, boss death, course end, purchase burst) and the batch builder, with the queue, merging of old batches, the request body and the three server answers handled in the store; batches print to the console in debug builds.
6. Done: `POST /api/v1/sync` and `GET /api/v1/state` in `backend-service/`, with the order, time, gold-bound, spend and progress checks reading the game's own content tables; a `Sync` autoload in the game that signs in as a guest, sends the queue at checkpoints (at most every two minutes), on launch and on background, and feeds the three answers into the Store; shared maths pinned by `content/test_vectors.json` on both sides.
7. Done (ahead of 5 and 6): the Triple Jump Cave, the spirit leaf and the `effects` and `unlocks` slices.

Every step is built; what remains for "done when" is the balance pass (E2) and real art. See the [Dark Forest proof](proof-segments.md).

## Done when

A player can start fresh, run through Dark Forest, buy gear, unlock and use sprint, die and carry on, clear the course, eat the ingredient and see its dimension, beat the giant frog, and have their progress survive closing the app and syncing to the server.

## Open

E2 balance of sources. Numbers for the build live in [content data](../game-systems/content-data.md).
