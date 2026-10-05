# Documentation Index

This folder is the project memory for Vaporwave Vikings, Idle. It captures the game design, technical architecture, backend validation model, and production planning before the Godot and backend projects are scaffolded.

## Core Docs

- [Product Vision](product-vision.md) - what the game is, who it is for, and the pillars that should guide decisions.
- [Core Gameplay Overview](game-design/core-loop.md) - primary gameplay document covering running, jumping, combat, rewards, shop upgrades, worlds, challenges, ascension, and prototype scope.
- [Progression and Economy](game-design/progression-and-economy.md) - gold, upgrades, gear, multipliers, and resource planning.
- [Gear Progression](game-design/gear-progression.md) - repeatable gear purchases, bonuses by income source, combat stats, wealth unlocks, and cost scaling.
- [Ascension Progression](game-design/ascension-progression.md) - prestige reset rules, ascension point formula, and MVP permanent upgrade.
- [Abilities and Powerups](game-design/abilities-and-powerups.md) - speed boost, magnetism, temporary effects, shop states, and validation notes.
- [Level Design](game-design/level-design.md) - one-zone level structure, tile roles, enemies, secret routes, rewards, and boss gate.
- [Routes, Enemies, and Rewards](game-design/routes-enemies-and-rewards.md) - side-scrolling routes, platform choices, enemy rewards, and pickup constraints.
- [Tile Map Generation](game-design/tile-map-generation.md) - authored tile assembly, connector rows, server-issued seeds, and deterministic route generation.
- [Challenge Courses and Ability Unlocks](game-design/challenge-courses-and-ability-unlocks.md) - secret routes, challenge rooms, immediate special-ability rewards, and mushroom discoveries that unlock future drops.
- [Technical Architecture](technical/architecture.md) - planned Godot client, Node.js backend, data flow, and trust boundaries.
- [Godot Client](technical/godot-client.md) - client responsibilities, game systems, networking, and local state.
- [Client State Store](technical/client-state-store.md) - Redux-inspired client store, actions, reducers, subscribers, action log, and delta generation.
- [Backend Service](technical/backend-service.md) - service responsibilities, API surface, persistence model, and server-owned progression.
- [Platform Authentication](technical/platform-authentication.md) - initial Apple, Google, and Google Play login notes.
- [Progression Validation](technical/progression-validation.md) - how reported player progress can be checked against possible outcomes.
- [Validation Service](technical/validation-service.md) - short connection grace, checkpoints, buffered deltas, closed-app gold, reward validation, and trust score model.
- [MVP Scope](production/mvp-scope.md) - one-zone vertical slice scope including tiles, enemies, boss, gear, secret routes, backend, validation, UI, and ascension.
- [Production Roadmap](production/roadmap.md) - suggested build phases and near-term documentation tasks.
- [Glossary](glossary.md) - shared terms for design and engineering.

## Documentation Principles

- Keep design intent and implementation notes close together.
- Record assumptions early, then replace them with measured values as prototypes exist.
- Treat server validation, economy tuning, and client feel as connected systems.
- Prefer concrete examples over abstract rules when documenting mechanics.

## Near-Term Next Docs

- Economy balance sheet or table for early upgrade costs and multipliers.
- First-pass persistent database schema for auth, profile, run start, run report, and purchases.
- Godot scene/system breakdown once the client folder is created.
- Backend persistence schema once the service stack is chosen.
