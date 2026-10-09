/**
 * The server's copy of each player: the last accepted state tree and the
 * sync bookkeeping from docs/technical/validation.md. In memory for now.
 */
import { content, type Content } from "../content/content";
import type { PlayerRecord, PlayerState, SyncResponse } from "../types/state";

const SAVE_FORMAT = 1;
const RECENT_REQUEST_TTL_MS = 24 * 60 * 60 * 1000;

/** Twin of InitialState.make() in the client. */
export function initialState(c: Content = content()): PlayerState {
  const gear: PlayerState["gear"] = {};
  for (const item of c.gear) {
    gear[item.id] = { unlocked: item.bracket <= 0, level: 0 };
  }
  return {
    meta: { save_format: SAVE_FORMAT, player_id: "", device_id: "", content_version: c.version },
    wallet: { gold: 0, lifetime_gold: 0 },
    gear,
    artefacts: {},
    loadout: { wand: "", ranged: "" },
    unlocks: { ingredients: [], pickups: [], courses: [] },
    inventory: {},
    effects: [],
    run: {
      world_level: 1,
      biome: "dark_forest",
      level_index: 0,
      level_seed: 0,
      distance_m: 0,
      health: c.viking.health,
      sprint_cooldown_s: 0,
      play_seconds: 0
    },
    progress: { badges: [], bosses_beaten: 0 },
    stats: {
      lifetime: { kills: {}, coins: 0, metres: 0, deaths: 0, pit_falls: 0, eats: {} },
      run: { kills: {}, coins: 0, metres: 0, deaths: 0, pit_falls: 0 }
    },
    ascension: { level: 0, points_unspent: 0, talents: {} },
    village: {},
    sync: { rev: 0, last_seq: 0, baseline: {}, open: null, queued_batches: [], last_sync_at: "" }
  };
}

export class PlayerStore {
  private readonly players = new Map<string, PlayerRecord>();

  getOrCreate(accountId: string, now: Date): PlayerRecord {
    let record = this.players.get(accountId);
    if (!record) {
      const state = initialState();
      state.meta.player_id = accountId;
      record = {
        accountId,
        state,
        rev: 0,
        last_seq: 0,
        last_sync_at: now.toISOString(),
        last_seen_at: now.toISOString(),
        ledger: [],
        recent_requests: new Map()
      };
      this.players.set(accountId, record);
    }
    return record;
  }

  rememberRequest(record: PlayerRecord, requestId: string, response: SyncResponse, now: Date) {
    for (const [id, entry] of record.recent_requests) {
      if (now.getTime() - Date.parse(entry.at) > RECENT_REQUEST_TTL_MS) {
        record.recent_requests.delete(id);
      }
    }
    record.recent_requests.set(requestId, { response, at: now.toISOString() });
  }

  resetForTests() {
    this.players.clear();
  }
}

export const playerStore = new PlayerStore();
