/**
 * The player state tree, the same shape as the Godot device save
 * (state/initial_state.gd). The server keeps the last accepted copy.
 */
export interface GearSlotState {
  unlocked: boolean;
  level: number;
}

export interface PlayerState {
  meta: { save_format: number; player_id: string; device_id: string; content_version: string };
  wallet: { gold: number; lifetime_gold: number };
  gear: Record<string, GearSlotState>;
  artefacts: Record<string, unknown>;
  loadout: { wand: string; ranged: string };
  unlocks: { ingredients: string[]; pickups: string[]; courses: string[] };
  inventory: Record<string, unknown>;
  effects: unknown[];
  run: {
    world_level: number;
    biome: string;
    level_index: number;
    level_seed: number;
    distance_m: number;
    health: number;
    sprint_cooldown_s: number;
    play_seconds: number;
  };
  progress: { badges: string[]; bosses_beaten: number };
  stats: {
    lifetime: { kills: Record<string, number>; coins: number; metres: number; deaths: number; pit_falls: number; eats: Record<string, number> };
    run: { kills: Record<string, number>; coins: number; metres: number; deaths: number; pit_falls: number };
  };
  ascension: { level: number; points_unspent: number; talents: Record<string, unknown> };
  village: Record<string, unknown>;
  sync: { rev: number; last_seq: number; baseline: Record<string, unknown>; open: unknown; queued_batches: unknown[]; last_sync_at: string };
}

export interface Batch {
  seq: number;
  seq_from?: number;
  play_seconds: number;
  away_seconds: number;
  gold_earned: Record<string, number>;
  gold_spent: number;
  counts: Record<string, number>;
  changes: {
    gear: Record<string, [number, number]>;
    unlocks: { gear_slots: string[]; ingredients: string[] };
    progress: { level?: [number, number] };
    courses_completed: string[];
    effects_started: Array<{ ingredient: string; form: string }>;
  };
}

export interface SyncRequest {
  request_id: string;
  device_id: string;
  base_rev: number;
  content_version: string;
  batches: Batch[];
}

export type SyncResult = "accepted" | "trimmed" | "rejected" | "conflict";

export interface SyncResponse {
  result: SyncResult;
  rev: number;
  server_time: string;
  up_to_seq?: number;
  trims?: Array<{ seq: number; gold_removed: number }>;
  code?: string;
  message?: string;
}

export interface PlayerRecord {
  accountId: string;
  state: PlayerState;
  rev: number;
  last_seq: number;
  last_sync_at: string;
  last_seen_at: string;
  ledger: Array<{ source: string; amount: number; seq: number; at: string }>;
  recent_requests: Map<string, { response: SyncResponse; at: string }>;
}
