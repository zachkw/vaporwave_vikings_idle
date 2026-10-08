# Game systems

Build-ready specs: one per system, detailed enough to generate code from. The design docs in [game-design](../game-design/) say what and why; these say exactly how.

Every spec uses the same sections: **Purpose, Rules, Content data, State and actions, Godot, Numbers, Acceptance, Open.** Numbers marked *placeholder* are there so the first build runs; real values come from the economy simulation.

## Systems

| Spec | System | First build |
| --- | --- | --- |
| [Content data](content-data.md) | The JSON tables every system reads, shared with the server | Yes |
| [Runner](runner.md) | Movement, jumping, auto-jump, sprint, drop-ins after death and pit falls | Yes |
| [Level builder](level-builder.md) | Chaining hand-made segments into surface levels, and the spawning passes | Yes |
| [Enemies and spawning](enemies-and-spawning.md) | Enemy definitions, roles, spawn tables, elites, bosses | Yes |
| [Combat](combat.md) | Sword, ranged, wand, damage, defence, health, crits, death | Yes |
| [Dimensions](dimensions.md) | Ingredient boxes, eating, effects, colour shifts, overlay spawns | Yes |
| [Gear shop](gear-shop.md) | Slots, brackets, linear costs, stats, shop rows | Yes |
| [Courses](courses.md) | Entering, playing and failing assault courses; rewards; farms | Yes (one course) |
| [Level flow](level-flow.md) | Level start, boss, advance, badges, World+, portals | Partly |
| [HUD and menus](hud-and-menus.md) | What is on screen and in the menus | Partly |
| [Later systems](later-systems.md) | Artefacts and weapons, pickups, ascension, Village, away gold | No |

Saving, sync and validation are specified in [State store spec](../technical/state-store-spec.md) and [Validation](../technical/validation.md).

## Godot project layout (proposed)

```text
vaporwave-vikings-idle/
  autoload/
    store.gd            # state, dispatch, select, changed signal
    content.gd          # loads content/*.json once at start
    save.gd             # device save at checkpoints
    sync.gd             # batch queue and POST /sync
  state/
    actions.gd          # action type constants and constructors
    reducers/           # one script per slice: wallet.gd, gear.gd, run.gd ...
    selectors.gd
    batch_builder.gd
  systems/
    runner.gd  level_builder.gd  spawner.gd  combat.gd  dimensions.gd  courses.gd  level_flow.gd
  scenes/
    run/run.tscn        # the surface run
    viking/viking.tscn
    enemies/<enemy_id>.tscn
    segments/<biome>/<segment_id>.tscn
    courses/<course_id>.tscn
    ui/hud.tscn  ui/shop.tscn  ui/menus.tscn
  content/              # JSON tables, also read by backend-service
  tests/                # unit tests for reducers, selectors, level builder, test vectors
```

Rules for generated code:

- Systems and scenes never change state directly; they call `Store.dispatch(...)`.
- Anything random (crits, segment picks, spawns) uses a seeded `RandomNumberGenerator` owned by the system, never the global one.
- Reducers and selectors have no scene dependencies and are unit-tested.
- Content is data: no gold values, health or costs hard-coded in scripts.
