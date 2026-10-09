# Validation

The server keeps a validated copy of each player and checks every sync with three ideas: no one can play more seconds than have passed, no one can earn more gold than their gear allows in that time, and every purchase must add up. That is the whole model (decided 7 to 8 October 2026). June's stricter anti-cheat layer was deleted.

Related: [State store spec](state-store-spec.md) for how batches are built on the device, [Economy](../game-design/economy.md) for the gold model.

Built 9 Oct 2026: `backend-service/src/services/syncService.ts` (the checks), `playerStore.ts` (the server copy), `content/formulas.ts` (shared maths) and `routes/syncRoutes.ts`; the game side is the `Sync` autoload (`autoload/sync.gd`). Checks 1 to 5 are in; away gold, ascension and talents are not yet.

## What the server stores per player

| Field | Meaning |
| --- | --- |
| `state` | The last accepted copy of the full state tree (same shape as the device save) |
| `rev` | Revision number, +1 on every accepted or trimmed sync |
| `last_seq` | Highest batch number accepted |
| `last_sync_at` | Server time of the last accepted sync |
| `last_seen_at` | Server time the player was last known to be playing (end of the last accepted batch) |
| `ledger` | One entry per gold change: source, amount, batch, time |
| `recent_requests` | Request ids and their answers for the last day, for idempotent retries |

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/api/v1/sync` | Send queued batches; get Accepted, Trimmed, Rejected or Conflict |
| `GET` | `/api/v1/state` | Fetch the server copy (after Rejected or Conflict, or on a new device) |
| `POST` | `/api/v1/away/claim` | Claim away gold on launch; the server measures the time |
| `POST` | `/api/v1/away/double` | Double a claimed away payout once (rewarded ad watched) |
| `POST` | `/api/v1/ascend` | Ascend; only after a successful sync in the same session |
| `POST` | `/api/v1/talents/buy` | Spend ascension points; only after a successful sync |

All require a session token from sign-in.

### `POST /api/v1/sync`

Request:

```json
{
  "request_id": "b1f0c2e4-7a1d-4c55-9a0e-2f3f1a9c8d11",
  "device_id": "dev-4821",
  "base_rev": 57,
  "content_version": "2026-10-08.1",
  "batches": [
    {
      "seq": 118,
      "play_seconds": 60,
      "away_seconds": 0,
      "gold_earned": { "distance": 3100, "coins": 9400, "basic": 7600,
                       "elite": 4500, "boss": 0, "dimensional": 4800, "course": 0 },
      "gold_spent": 21000,
      "counts": { "metres": 310, "coins": 152, "kills_basic": 31, "kills_elite": 3,
                  "kills_boss": 0, "kills_dimensional": 12, "deaths": 1, "pit_falls": 2 },
      "changes": {
        "gear": { "sword": [42, 45] },
        "unlocks": { "gear_slots": ["gloves"] },
        "progress": { "level": [3, 4] },
        "courses_completed": [],
        "effects_started": [{ "ingredient": "spirit_leaf", "form": "raw" }]
      }
    }
  ]
}
```

Response:

```json
{
  "result": "trimmed",
  "rev": 58,
  "server_time": "2026-10-08T14:03:11Z",
  "trims": [{ "seq": 118, "gold_removed": 12500 }]
}
```

`result` is one of:

| Result | When | Client does |
| --- | --- | --- |
| `accepted` | Every check passed | Drop the sent batches, store `rev` |
| `trimmed` | Only the gold bound failed, on one or more batches | Same, and subtract `gold_removed` from the wallet, never below zero |
| `rejected` | Order, time, spend or progress checks failed | `GET /state` and replace the device state |
| `conflict` | `base_rev` is not the server's current `rev` (another device synced) | Ask the player which save to keep (T4) |

A retried request with the same `request_id` returns the stored answer and changes nothing.

## The checks

Batches are checked one at a time, in order, against the server copy as it stands after the previous batch was applied.

### 1. Revision and order

- `base_rev` must equal the stored `rev`, else `conflict`.
- Batch numbers must start at `last_seq + 1` and have no gaps, else `rejected`. A merged batch carries `seq_from` as well as `seq` and covers that whole range.
- `content_version` must be one the server knows, else `rejected` with code `content_version`.

### 2. Time

```latex
\sum (\text{play seconds} + \text{away seconds}) \le (\text{now} - \text{last sync at}) \times 1.05 + 60
```

The 5 percent and 60 seconds cover clock drift and requests in flight (proposed). Failing this is `rejected` with code `time`: nobody can have played more seconds than have passed, whatever their device clock says.

### 3. Gold earned (the bound)

```latex
\text{allowed} = r \times \text{play seconds} \times m + \text{away gold allowed} + \text{boss gold} + \text{course gold}
```

- **r** is `expected_gold_per_second` for the server copy with this batch's gear, unlock and effect changes already applied, so mid-batch purchases get the benefit of the doubt.
- **m** is the margin, 2 to start (T6). It covers pickups, crit luck, sky coins, sprint and farm courses.
- **Boss gold** is the content-table reward for each `kills_boss`, allowed only if the progress check passes.
- **Course gold** is the content-table reward for each completed course.
- **Away gold allowed** is zero in a sync batch unless an offline away claim was recorded (see Away gold below).

If the sum of `gold_earned` is above `allowed`, the batch's gold is cut to `allowed` and the answer is `trimmed`. The cut comes off the largest source first, so the ledger stays readable.

### 4. Gold spent

- For each gear change `[from, to]`, the cost is the linear sum from the content table: `(to − from) × base + step × (from + ... + (to − 1))`.
- The total must equal `gold_spent` within a relative tolerance of 0.0001 (float rounding), else `rejected` with code `spend`.
- Wallet after the batch = wallet before + earned (after any trim) − spent. It must not go below zero, else `rejected` with code `wallet`.

### 5. Unlocks and progress

| Change | Rule |
| --- | --- |
| Gear slot unlocked | The wallet could have reached the slot's bracket during the batch: wallet before + earned ≥ bracket |
| Gear level bought | The slot is unlocked |
| Level advanced | One level per boss killed in the batch, and the next level must follow the current one |
| Course completed | The course exists in the current biome |
| Effect started | The ingredient is unlocked, or came from a box in a biome where it is found |

Failing any rule is `rejected` with code `progress`.

### Ascension points

The server always computes ascension points from its own `lifetime_gold`. Any value the client sends is ignored.

## Away gold

1. On launch the client syncs any queued batches, then calls `POST /api/v1/away/claim` with a `claim_id`.
2. The server takes `away_seconds = now − last_seen_at` and pays the bands in [Economy](../game-design/economy.md) at the reference rate: `expected_gold_per_second` for the stored state.
3. The claim is stored; `last_seen_at` moves to now, which resets the bands.
4. `POST /api/v1/away/double` with the same `claim_id` pays the same amount again, once. There is no ad verification (decided 8 Oct).

If the game starts offline, the client estimates away gold from the device clock and records it as `away_seconds` in a batch. On the next sync the server recomputes it from `last_seen_at` and trims anything above its own figure.

## Ascension and talents

- `POST /api/v1/ascend` is only accepted when the request's `base_rev` equals the stored `rev`, which means the latest batches are already synced. Otherwise `conflict` or `rejected` with code `sync_first`.
- The server banks points from `lifetime_gold`, rebuilds the state with the keep rules from the [state store spec](state-store-spec.md), and returns the new state and `rev`.
- `POST /api/v1/talents/buy` follows the same rule and checks points against the talent's cost.

## Error codes

| Code | Meaning |
| --- | --- |
| `order` | Batch numbers out of order or with gaps |
| `content_version` | Unknown content version |
| `time` | More seconds claimed than have passed |
| `spend` | Gold spent does not match the reported purchases |
| `wallet` | Wallet would go below zero |
| `progress` | An unlock or progress change is not possible |
| `sync_first` | Ascension or talent purchase without a current sync |

## Shared maths

The client (GDScript) and the server (TypeScript) each implement `expected_gold_per_second`, level costs and away bands. They must agree exactly. The content folder ships **test vectors** (`content/test_vectors.json`, generated by `tools/gen_test_vectors.tscn` from the GDScript side): sample states with the expected outputs. The backend tests check every vector, so a formula change on one side fails the other side's tests until the vectors are regenerated and both agree.

`expected_gold_per_second` = run speed x speed multiplier x (gold per metre + expected coins per metre x coin value + expected basic kills per metre x basic gold + expected elite kills per metre x elite gold + expected dimensional kills per metre x average dimensional gold), with the per-metre expectations in `economy.json` (`expected_per_metre`). A fresh Viking in Dark Forest rates at 26.5 gold per second against a measured 20 or so, so the margin of 2 leaves real room for sprint, drop-in coins and luck.

## Tests

| Case | Expected |
| --- | --- |
| Normal 60 s batch within bound | `accepted`, `rev` + 1 |
| Gold 3 times the bound | `trimmed`, gold cut to the bound |
| Same request sent twice | Second call returns the first answer, no double gold |
| Batch seq skips a number | `rejected`, `order` |
| 600 play seconds claimed 120 s after the last sync | `rejected`, `time` |
| Device clock moved forward a day, offline | Away gold recomputed from the server clock and trimmed |
| Sword bought 42 to 45 with the wrong gold spent | `rejected`, `spend` |
| Gloves unlocked with a wallet that never reached 10^4 | `rejected`, `progress` |
| Two levels advanced with one boss kill | `rejected`, `progress` |
| Second device syncs on an old `base_rev` | `conflict` |
| Ascend with unsynced batches | `sync_first` |
| Away double called twice | Second call pays nothing |

## What this does not do

It caps totals. It cannot tell a player earning at the maximum rate from a script doing the same, and it does not check individual coins or kills. That is fine while there are no leaderboards or purchases to protect. If that changes, design hardening fresh.

## Open

T4 two devices, T5 trimming already-spent gold, T6 margin, T7 offline cap. See [decisions](../decisions.md).
