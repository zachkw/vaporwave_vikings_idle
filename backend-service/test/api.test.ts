import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createApp } from "../src/app";
import { content } from "../src/content/content";
import { expectedGoldPerSecond, levelCostSum, goldPerMetre, coinValue, enemyGold, runSpeedMult } from "../src/content/formulas";
import { accountStore } from "../src/services/accountStore";
import { initialState, playerStore } from "../src/services/playerStore";
import { applySync } from "../src/services/syncService";
import type { Batch, PlayerRecord, SyncRequest } from "../src/types/state";

const app = createApp();
const c = content();

function batch(seq: number, over: Partial<Batch> = {}): Batch {
  return {
    seq,
    play_seconds: 60,
    away_seconds: 0,
    gold_earned: { distance: 300, coins: 300, basic: 300, elite: 150, boss: 0, dimensional: 0, course: 0 },
    gold_spent: 0,
    counts: { metres: 300, coins: 50, kills_basic: 12, kills_elite: 1, kills_boss: 0, kills_dimensional: 0, deaths: 0, pit_falls: 0 },
    changes: { gear: {}, unlocks: { gear_slots: [], ingredients: [] }, progress: {}, courses_completed: [], effects_started: [] },
    ...over
  };
}

function req(batches: Batch[], over: Partial<SyncRequest> = {}): SyncRequest {
  return { request_id: `req-${Math.random()}`, device_id: "dev-test", base_rev: 0, content_version: c.version, batches, ...over };
}

function fresh(): { record: PlayerRecord; t0: Date } {
  playerStore.resetForTests();
  const t0 = new Date("2026-10-09T10:00:00Z");
  return { record: playerStore.getOrCreate("acc-1", t0), t0 };
}

const later = (t0: Date, seconds: number) => new Date(t0.getTime() + seconds * 1000);

describe("shared maths matches the client's test vectors", () => {
  const vectors = c.testVectors as {
    content_version: string;
    states: Array<{ name: string; gear: Record<string, number>; gold_per_metre: number; coin_value: number; run_speed_mult: number;
      expected_gold_per_second: Record<string, number>; enemy_gold: Record<string, number> }>;
    level_costs: Array<{ slot: string; from_level: number; count: number; cost: number }>;
  };

  it("vectors are for this content version", () => {
    expect(vectors.content_version).toBe(c.version);
  });

  for (const v of vectors.states) {
    it(`state "${v.name}"`, () => {
      const state = initialState(c);
      for (const [slot, level] of Object.entries(v.gear)) state.gear[slot] = { unlocked: true, level };
      expect(goldPerMetre(c, state)).toBeCloseTo(v.gold_per_metre, 6);
      expect(coinValue(c, state)).toBeCloseTo(v.coin_value, 6);
      expect(runSpeedMult(c, state)).toBeCloseTo(v.run_speed_mult, 9);
      for (const [biome, rate] of Object.entries(v.expected_gold_per_second)) {
        expect(expectedGoldPerSecond(c, state, biome) / rate).toBeCloseTo(1, 9);
      }
      for (const [enemy, gold] of Object.entries(v.enemy_gold)) {
        expect(enemyGold(c, state, c.enemies.get(enemy)!)).toBeCloseTo(gold, 6);
      }
    });
  }

  it("level costs", () => {
    for (const lc of vectors.level_costs) {
      expect(levelCostSum(c, lc.slot, lc.from_level, lc.count) / Math.max(1, lc.cost)).toBeCloseTo(lc.cost / Math.max(1, lc.cost), 9);
    }
  });
});

describe("sync checks", () => {
  it("accepts a normal 60 s batch within the bound", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(1)]), later(t0, 65), c);
    expect(out.response.result).toBe("accepted");
    expect(out.response.rev).toBe(1);
    expect(record.state.wallet.gold).toBe(1050);
    expect(record.state.wallet.lifetime_gold).toBe(1050);
    expect(record.state.stats.lifetime.kills.basic).toBe(12);
    expect(record.last_seq).toBe(1);
  });

  it("trims gold three times the bound down to the bound", () => {
    const { record, t0 } = fresh();
    const allowed = expectedGoldPerSecond(c, record.state) * 60 * c.economy.sync_margin;
    const out = applySync(record, req([batch(1, { gold_earned: { distance: allowed * 3 } })]), later(t0, 65), c);
    expect(out.response.result).toBe("trimmed");
    expect(out.response.trims?.[0].gold_removed).toBeCloseTo(allowed * 2, 6);
    expect(record.state.wallet.gold).toBeCloseTo(allowed, 6);
    expect(record.rev).toBe(1);
  });

  it("returns the stored answer for a repeated request id, with no double gold", () => {
    const { record, t0 } = fresh();
    const r = req([batch(1)]);
    const first = applySync(record, r, later(t0, 65), c);
    const second = applySync(record, r, later(t0, 70), c);
    expect(second.response).toEqual(first.response);
    expect(record.state.wallet.gold).toBe(1050);
    expect(record.rev).toBe(1);
  });

  it("rejects a batch sequence that skips a number", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(2)]), later(t0, 65), c);
    expect(out.response.result).toBe("rejected");
    expect(out.response.code).toBe("order");
    expect(record.rev).toBe(0);
  });

  it("accepts a merged batch that covers the sequence with seq_from", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(5, { seq_from: 1, play_seconds: 300 })]), later(t0, 400), c);
    expect(out.response.result).toBe("accepted");
    expect(record.last_seq).toBe(5);
  });

  it("rejects 600 play seconds claimed 120 s after the last sync", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(1, { play_seconds: 600 })]), later(t0, 120), c);
    expect(out.response.result).toBe("rejected");
    expect(out.response.code).toBe("time");
  });

  it("rejects a sword bought 42 to 45 with the wrong gold spent", () => {
    const { record, t0 } = fresh();
    record.state.gear.sword.level = 42;
    record.state.wallet.gold = 1_000_000;
    const out = applySync(record, req([batch(1, { gold_spent: 100, changes: { ...batch(1).changes, gear: { sword: [42, 45] } } })]), later(t0, 65), c);
    expect(out.response.result).toBe("rejected");
    expect(out.response.code).toBe("spend");
    const ok = applySync(record, req([batch(1, { gold_spent: levelCostSum(c, "sword", 42, 3), changes: { ...batch(1).changes, gear: { sword: [42, 45] } } })]), later(t0, 65), c);
    expect(ok.response.result).toBe("accepted");
    expect(record.state.gear.sword.level).toBe(45);
    expect(record.state.wallet.gold).toBe(1_000_000 + 1050 - levelCostSum(c, "sword", 42, 3));
  });

  it("rejects gloves unlocked with a wallet that never reached its bracket", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(1, { changes: { ...batch(1).changes, unlocks: { gear_slots: ["gloves"], ingredients: [] } } })]), later(t0, 65), c);
    expect(out.response.result).toBe("rejected");
    expect(out.response.code).toBe("progress");
  });

  it("accepts legs unlocked once the wallet plus earnings reach the bracket", () => {
    const { record, t0 } = fresh();
    record.state.wallet.gold = 2000;
    const out = applySync(record, req([batch(1, { changes: { ...batch(1).changes, unlocks: { gear_slots: ["legs"], ingredients: [] } } })]), later(t0, 65), c);
    expect(out.response.result).toBe("accepted");
    expect(record.state.gear.legs.unlocked).toBe(true);
  });

  it("rejects buying a level in a locked slot", () => {
    const { record, t0 } = fresh();
    record.state.wallet.gold = 1e6;
    const out = applySync(record, req([batch(1, { gold_spent: 5300, changes: { ...batch(1).changes, gear: { legs: [0, 1] } } })]), later(t0, 65), c);
    expect(out.response.result).toBe("rejected");
    expect(out.response.code).toBe("progress");
  });

  it("rejects two levels advanced with one boss kill, accepts one", () => {
    const { record, t0 } = fresh();
    const counts = { ...batch(1).counts, kills_boss: 1 };
    const bad = applySync(record, req([batch(1, { counts, gold_earned: { boss: 500 }, changes: { ...batch(1).changes, progress: { level: [0, 2] } } })]), later(t0, 65), c);
    expect(bad.response.result).toBe("rejected");
    expect(bad.response.code).toBe("progress");
    const good = applySync(record, req([batch(1, { counts, gold_earned: { boss: 500 }, changes: { ...batch(1).changes, progress: { level: [0, 1] } } })]), later(t0, 65), c);
    expect(good.response.result).toBe("accepted");
    expect(record.state.run.level_index).toBe(1);
    expect(record.state.progress.bosses_beaten).toBe(1);
    expect(record.state.wallet.gold).toBe(500);
  });

  it("boss gold sits outside the rate bound", () => {
    const { record, t0 } = fresh();
    const counts = { ...batch(1).counts, kills_boss: 1 };
    const out = applySync(record, req([batch(1, { play_seconds: 1, counts, gold_earned: { boss: 500 } })]), later(t0, 65), c);
    expect(out.response.result).toBe("accepted");
  });

  it("rejects a wallet that would go below zero", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(1, { gold_earned: { distance: 0 }, gold_spent: 2, changes: { ...batch(1).changes, gear: { sword: [0, 1] } } })]), later(t0, 65), c);
    expect(out.response.result).toBe("rejected");
    expect(out.response.code).toBe("wallet");
  });

  it("answers conflict when a second device syncs on an old base_rev", () => {
    const { record, t0 } = fresh();
    applySync(record, req([batch(1)]), later(t0, 65), c);
    const out = applySync(record, req([batch(2)], { base_rev: 0, device_id: "dev-other" }), later(t0, 130), c);
    expect(out.response.result).toBe("conflict");
    expect(out.status).toBe(409);
    expect(record.rev).toBe(1);
  });

  it("rejects an unknown content version", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(1)], { content_version: "1999-01-01.1" }), later(t0, 65), c);
    expect(out.response.code).toBe("content_version");
  });

  it("completing the course unlocks the ingredient; effects need an unlocked or local ingredient", () => {
    const { record, t0 } = fresh();
    const out = applySync(record, req([batch(1, { changes: { ...batch(1).changes, courses_completed: ["df_cave_a1"], effects_started: [{ ingredient: "spirit_leaf", form: "raw" }] } })]), later(t0, 65), c);
    expect(out.response.result).toBe("accepted");
    expect(record.state.unlocks.courses).toEqual(["df_cave_a1"]);
    expect(record.state.unlocks.ingredients).toEqual(["spirit_leaf"]);
    expect(record.state.stats.lifetime.eats.spirit_leaf).toBe(1);
  });

  it("applies several batches in order and rates each at its own gear", () => {
    const { record, t0 } = fresh();
    const b1 = batch(1, { gold_earned: { distance: 500 } });
    const b2 = batch(2, { gold_spent: 9, changes: { ...batch(2).changes, gear: { sword: [0, 3] } } });
    const out = applySync(record, req([b1, b2]), later(t0, 130), c);
    expect(out.response.result).toBe("accepted");
    expect(out.response.up_to_seq).toBe(2);
    expect(record.state.gear.sword.level).toBe(3);
    expect(record.state.wallet.gold).toBe(500 + 1050 - 9);
    expect(record.state.run.play_seconds).toBe(120);
  });
});

describe("http api", () => {
  beforeEach(() => {
    accountStore.resetForTests();
    playerStore.resetForTests();
  });

  it("returns health and config", async () => {
    const health = await request(app).get("/health").expect(200);
    expect(health.body.status).toBe("ok");
    const config = await request(app).get("/api/v1/config").expect(200);
    expect(config.body.content_version).toBe(c.version);
  });

  it("guest signs in, syncs, reads the server state", async () => {
    const login = await request(app).post("/api/v1/auth/guest").send({ displayName: "Zach" }).expect(201);
    const token = login.body.accessToken as string;
    const sync = await request(app)
      .post("/api/v1/sync")
      .set("Authorization", `Bearer ${token}`)
      .send(req([batch(1, { play_seconds: 10, gold_earned: { distance: 50 }, counts: { metres: 50 } })]))
      .expect(200);
    expect(sync.body.result).toBe("accepted");
    expect(sync.body.rev).toBe(1);
    const state = await request(app).get("/api/v1/state").set("Authorization", `Bearer ${token}`).expect(200);
    expect(state.body.rev).toBe(1);
    expect(state.body.state.wallet.gold).toBe(50);
    expect(state.body.state.sync.rev).toBe(1);
    expect(state.body.state.gear.sword).toEqual({ unlocked: true, level: 0 });
  });

  it("rejects a malformed batch with 400 and an unauthenticated sync with 401", async () => {
    await request(app).post("/api/v1/sync").send({}).expect(401);
    const login = await request(app).post("/api/v1/auth/guest").send({}).expect(201);
    const token = login.body.accessToken as string;
    await request(app).post("/api/v1/sync").set("Authorization", `Bearer ${token}`).send({ request_id: "x" }).expect(400);
  });

  it("returns 422 with a code for a rejected sync and 409 for a conflict", async () => {
    const login = await request(app).post("/api/v1/auth/guest").send({}).expect(201);
    const token = login.body.accessToken as string;
    const bad = await request(app).post("/api/v1/sync").set("Authorization", `Bearer ${token}`).send(req([batch(3)])).expect(422);
    expect(bad.body.result).toBe("rejected");
    expect(bad.body.code).toBe("order");
    const conflict = await request(app).post("/api/v1/sync").set("Authorization", `Bearer ${token}`).send(req([batch(1)], { base_rev: 7 })).expect(409);
    expect(conflict.body.result).toBe("conflict");
  });
});
