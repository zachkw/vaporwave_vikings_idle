# Documentation

This folder is the single source of truth for Vaporwave Vikings Idle. Design and technical decisions live here, in the repo, and nowhere else is authoritative.

## Start here

1. [Decisions](decisions.md): every decision with its date, and the numbered open questions. If anything disagrees with this file, this file wins.
2. [Product vision](product-vision.md): what the game is and the pillars behind it.
3. [Game overview](game-design/overview.md): the player flow and how the systems connect.

## Game design

| Doc | Covers |
| --- | --- |
| [Game overview](game-design/overview.md) | The hook, the player flow, design principles |
| [Controls and combat](game-design/controls-and-combat.md) | Tap controls, sprint, enemy roles, death, pits, bosses, crits |
| [Biomes and dimensions](game-design/biomes-and-dimensions.md) | Biome template, level types, ingredients, dimension enemies, roster, asset checklist |
| [Courses and unlocks](game-design/courses-and-unlocks.md) | Assault courses, difficulty grid, farms, pickups |
| [Gear and artefacts](game-design/gear-and-artefacts.md) | 22 gear slots and their unlock ladder, artefacts, weapon families, materials |
| [Economy](game-design/economy.md) | Gold model, starting balance, away gold, daily rewards, ads |
| [Progression](game-design/progression.md) | Areas, bosses, World+, portals, ascension, talent web |
| [Village](game-design/village.md) | Buildings, garden and seeds |

## Game systems (build-ready specs)

| Doc | Covers |
| --- | --- |
| [Game systems index](game-systems/README.md) | Spec template, Godot project layout, coding rules |
| [Content data](game-systems/content-data.md) | Shared JSON tables and first-build placeholder values |
| [Runner](game-systems/runner.md) | Movement, jump limits, auto-jump, sprint, pit falls |
| [Level builder](game-systems/level-builder.md) | Chaining segments by seam rows, beat plans, spawning and drop-in passes, library linter |
| [Enemies and spawning](game-systems/enemies-and-spawning.md) | Roles, stop-and-fight, boss signature move, spawn tables |
| [Combat](game-systems/combat.md) | Attacks, damage, defence, crits, regen, death |
| [Dimensions](game-systems/dimensions.md) | Boxes, eating, effects, colour shifts |
| [Gear shop](game-systems/gear-shop.md) | Slots, brackets, linear costs, shop rows |
| [Courses](game-systems/courses.md) | Entering, failing, clearing, farms |
| [Level flow](game-systems/level-flow.md) | Levels, bosses, biomes, World+, portals |
| [HUD and menus](game-systems/hud-and-menus.md) | Portrait and landscape layouts, the menu panel and drawer, HUD, ability strip |
| [Backgrounds and parallax](game-systems/backgrounds.md) | Layer stack, scroll speeds, placeholder art |
| [Later systems](game-systems/later-systems.md) | What remaining systems need before they are built |

## Technical

| Doc | Covers |
| --- | --- |
| [Architecture](technical/architecture.md) | Client, backend, trust boundary, endpoints |
| [State store spec](technical/state-store-spec.md) | State tree, actions, selectors, saving, sync |
| [Validation](technical/validation.md) | Sync endpoints, the time, gold and spend checks, away gold, tests |
| [Platform authentication](technical/platform-authentication.md) | Apple, Google and Google Play sign-in |

## Production

| Doc | Covers |
| --- | --- |
| [First build](production/first-build.md) | Dark Forest scope, build order, done criteria |
| [Proof segments](production/proof-segments.md) | The built proof: five segments, level builder, parallax, tests |
| [Roadmap](production/roadmap.md) | What's done and what's next |

## Art

[Art](art/README.md) is a placeholder folder: principles so far, planned docs, and a starting [animation list](art/animations.md).

[Glossary](glossary.md) defines the shared terms.

## Elsewhere

- The [Miro board](https://miro.com/app/board/uXjVEeSYwdg=/) holds sketches, references and the "Game Design" player-flow frame. It is a working space; decisions are copied here.

## Working rules

- Record a decision in [decisions.md](decisions.md) first, with its date, then update the system doc it affects.
- Mark anything said as a "maybe" as **tentative**, and anything inferred as **Claude's reading**, until confirmed.
- Give each open question a number in decisions.md and refer to it by number elsewhere.
- Prefer a table or a short list to a paragraph when listing things.
- Easy is best for now: when a question is open, document the simplest option as the default.
