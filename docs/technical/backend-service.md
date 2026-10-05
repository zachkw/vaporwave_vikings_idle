# Backend Service

## Role

The backend service authorizes player progression. It stores the authoritative profile, validates run reports, commits accepted rewards, and processes purchases and upgrades.

The initial service is a standard Node.js REST API using Express and TypeScript. Storage is in-memory for now, with service boundaries shaped so a database can replace it later.

The client will maintain a Redux-inspired state store and submit deltas derived from its action log. The backend validates those deltas and returns authoritative reconciliation responses.

## Core Responsibilities

- Login and account identity.
- Player profile storage.
- Inventory, gear, and upgrade state.
- Gear level purchases, costs, and stat calculations.
- Ability grants from validated content rewards and ownership state.
- Ascension state and permanent upgrade purchases.
- Run session creation.
- Server-issued map seed creation.
- Seed lease creation and refresh.
- Delta sync validation.
- Progress report validation.
- Reward commits.
- Daily return reward eligibility and retry-safe claims.
- Validated rewarded-ad bonuses tied to individual away-gold payouts, each doubled at most once.
- Economy ledger tracking.
- Content version management.
- Basic telemetry and suspicious activity flags.

## Candidate API Surface

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/api/v1/auth/guest` | Create a guest account and session. |
| `POST` | `/api/v1/auth/apple` | Verify Sign in with Apple identity token and create or resume an account. |
| `POST` | `/api/v1/auth/google` | Verify Google ID token and create or resume an account. |
| `POST` | `/api/v1/auth/google-play` | Exchange Play Games Services server auth code and create or resume an account. |
| `GET` | `/api/v1/profile` | Load the authoritative player profile. |
| `GET` | `/api/v1/config` | Fetch content and economy configuration for the current app version. |
| `POST` | `/api/v1/run/start` | Create a server-known run session. |
| `POST` | `/api/v1/run/handshake` | Submit a delta, reconcile profile state, and refresh seed lease when online. |
| `POST` | `/api/v1/run/report` | Submit a progress segment for validation and reward commit. |
| `POST` | `/api/v1/upgrade/purchase` | Buy or level an upgrade with gold. |
| `POST` | `/api/v1/ascension/perform` | Reset run-level progress and award ascension points. |
| `POST` | `/api/v1/ascension/upgrade` | Buy the repeatable ascension upgrade with ascension points. |

## Persistence Model

Candidate entities:

- Account
- PlayerProfile
- CurrencyBalance
- UpgradeState
- GearInventory
- EquippedGear
- AbilityState
- AscensionState
- RunSession
- RunReport
- MapSeed
- SeedLease
- ReturnRewardClaim
- DailyRewardClaim
- AdBonusEntitlement
- ProfileVersion
- GenerationAlgorithmVersion
- EconomyLedgerEntry
- ContentVersion
- SuspiciousActivityFlag

The economy ledger is important. Every gold-changing operation should leave a record that can be audited later.

## Login Flows

The game will need standard mobile login and profile flows. The exact provider is to be decided, but the system should support:

- Anonymous or guest start.
- Account linking.
- Platform identity where appropriate.
- Token refresh.
- Profile recovery across devices.

Auth should be practical for mobile players. The game should not block the first experience with unnecessary account friction unless platform requirements demand it.

## Server-Owned Purchases

Upgrade and gear purchases should be server-authoritative. The client can request a purchase, but the backend should verify:

- The player has enough gold.
- The upgrade or gear slot exists in the active content version.
- Prerequisites are met.
- The required wealth bracket has made the item available for purchase.
- The next gear cost is computed from the authoritative current level.
- The purchase has not already been applied.
- The resulting state is valid.

The gear model starts with three repeatable choices (Viking Axe, Chest, Helmet) and expands through data-defined wealth brackets. The backend must compute each piece's global gold bonus, source/attack-specific income, melee and thrown-axe damage, health, and defence from authoritative gear levels and content. Repeated effects on different pieces are allowed, with stacking rules still to be defined.

Entering a wealth bracket only grants purchase eligibility; the first paid level grants the item's effect. Discovered special abilities are instead granted through validated boss/world reward events and can be used immediately in predicted client state. No initial ability-purchase endpoint is needed for this flow.

The planned ladder reaches roughly `10^30` gold. Currency arithmetic, rounding, and client/server serialization need an explicit shared representation before that scale is implemented; the existing numeric scaffold is not a completed large-number economy contract.

The MVP ascension model should support one repeatable permanent upgrade that grants `+5%` global gold/CPS per level.

## Current Foundation

The first backend skeleton lives in `backend-service/` and includes:

- Health and config endpoints.
- Guest account creation.
- Apple, Google, and Google Play auth verification modules.
- Bearer session middleware.
- In-memory account, profile, run session, and economy ledger storage.
- Run report validation with duration, gold, enemy kill, and route exclusivity checks.
- Upgrade purchasing with server-side gold verification.

## Map Seed Ownership

The backend owns map seeds. When a run starts, the service should create and store the run session with a map seed, content version, generation algorithm version, starting route context, and starting connector row.

The client uses that seed to generate the visible route. The backend uses the same seed and tile metadata to reconstruct the tile sequence for validation.

For MVP, normal active play requires internet with a confirmed two-minute routine checkpoint interval to limit operating costs. Batch ordinary purchases, boss results, and discoveries into ordered deltas. The proposed grace policy adds a 1-2-minute retry allowance after a checkpoint is due, giving an absolute limit of 3-4 minutes of provisional progress after the last accepted state; the recommended allowance is two minutes and remains a proposal. This replaces the earlier deadline measured only 1-2 minutes from the last checkpoint. Checkpoints reconcile buffered actions and renew the server-issued allowance. Preserve seed/content context for pending progress and make checkpoint retries idempotent. The current report-duration cap of 90 seconds must change before implementing this cadence, together with server-time accounting and bounded catch-up support.

Closed-app income initially grants gold only, at reduced rates validated against real-world elapsed time when the player returns. There is no accumulation cap; rates decline across the working bands 0-12, 12-24, 24-48, 48-168, and 168+ hours. Exact percentages remain provisional. A server-validated return and reward claim resets the schedule to its first band without requiring a minimum play session. Claims must use server time and accepted state, avoid overlap with active-play rewards, and commit the award and reset together with retry-safe identity. Later automation of bosses or discoveries is expected through additional upgrades, most likely ascension.

The detailed validation model lives in [Validation Service](validation-service.md).

## Open Questions

- Which database should store player profiles?
- Do we need Redis or another cache for sessions and rate limiting?
- How should content versions be deployed and rolled back?
- Which deterministic RNG algorithm should the backend share with Godot?
