# Production Roadmap

## Phase 0: Documentation Foundation

- Capture the product vision.
- Define the core loop.
- Define the first economy model.
- Define client and backend responsibilities.
- Define first-pass validation boundaries.
- List open design and technical questions.

## Phase 1: Godot Prototype

- Create the Godot project.
- Build a basic auto-running side-scroller.
- Add coin pickup collection.
- Add two enemy types and basic combat resolution.
- Add gold rewards.
- Add deterministic tile generation with a server-compatible seed model.
- Add two basic ground tiles and a small MVP tile library.
- Add a simple persistent tabbed menu.
- Add shop UI for the three core choices: Viking Axe, Chest, and Helmet.
- Add speed boost and magnetism unlock hooks.
- Export a local progress report payload for inspection.

## Phase 2: Backend Foundation

- Create the Node.js service.
- Add login or guest account flow.
- Add profile storage.
- Add run session creation.
- Issue server-owned map seeds.
- Add run report submission.
- Add basic validation and reward commits.
- Add upgrade purchase endpoint.
- Add ascension endpoint and repeatable ascension upgrade purchase.

## Phase 3: Vertical Slice

- Connect the Godot client to the backend.
- Run a complete session from login to reward commit.
- Add the core gear progression and define the first later wealth-bracket unlocks.
- Add server-side economy ledger entries.
- Add route exclusivity metadata.
- Add two secret routes: speed boost and magnetism.
- Add one boss gate.
- Add starting ascension loop.
- Add basic suspicious activity flags.

## Phase 4: Mobile Readiness

- Handle app pause, resume, and network loss.
- Add platform login support.
- Implement server-backed daily return rewards, optional rewarded-ad doubling for away gold, and separate optional challenge-retry ads; choose an ad provider and completion verification contract, with each reward granted once for its intended purpose.
- Add analytics and crash reporting.
- Build device performance checks.
- Prepare test builds for iOS and Android.
- Begin economy tuning with real session data.

## Immediate Next Steps

- Decide Godot version.
- Decide Node.js framework and language style.
- Create first economy tuning table.
- Draft initial API schemas.
- Define the one-zone MVP content set.
- Tune the three opening gear pieces and the widening wealth-bracket ladder for later items.
- Define the initial tile library.
- Define the two secret routes.
