/**
 * POST /api/v1/sync: the checks from docs/technical/validation.md, applied
 * batch by batch against the server copy. Three ideas: no one can play more
 * seconds than have passed, no one can earn more gold than their gear allows
 * in that time, and every purchase must add up.
 */
import { content, type Content } from "../content/content";
import { expectedGoldPerSecond, levelCostSum } from "../content/formulas";
import { playerStore } from "./playerStore";
import type { Batch, PlayerRecord, PlayerState, SyncRequest, SyncResponse } from "../types/state";

const SPEND_TOLERANCE = 1e-4;

class Reject extends Error {
  readonly code: string;

  constructor(code: string, message: string) {
    super(message);
    this.code = code;
  }
}

function sumEarned(batch: Batch) {
  let total = 0;
  for (const v of Object.values(batch.gold_earned)) total += v;
  return total;
}

function clone<T>(value: T): T {
  return structuredClone(value);
}

/** Apply the batch's gear, unlock and progress changes to a copy of the state (check 5 lives here too). */
function applyChanges(c: Content, state: PlayerState, batch: Batch, earned: number) {
  const walletBefore = state.wallet.gold;
  for (const slot of batch.changes.unlocks.gear_slots) {
    const item = c.gearById.get(slot);
    if (!item) throw new Reject("progress", `Unknown gear slot ${slot}.`);
    if (walletBefore + earned < item.bracket) {
      throw new Reject("progress", `Slot ${slot} unlocks at ${item.bracket} gold; the wallet could not have reached it.`);
    }
    state.gear[slot] = { ...(state.gear[slot] ?? { level: 0, unlocked: false }), unlocked: true };
  }
  let spent = 0;
  for (const [slot, range] of Object.entries(batch.changes.gear)) {
    const [from, to] = range;
    const item = c.gearById.get(slot);
    if (!item) throw new Reject("progress", `Unknown gear slot ${slot}.`);
    const slotState = state.gear[slot] ?? { level: 0, unlocked: false };
    if (!slotState.unlocked) throw new Reject("progress", `Slot ${slot} is locked.`);
    if (from !== slotState.level) throw new Reject("progress", `Slot ${slot} is at level ${slotState.level}, not ${from}.`);
    if (to < from) throw new Reject("progress", `Slot ${slot} cannot go down.`);
    spent += levelCostSum(c, slot, from, to - from);
    state.gear[slot] = { ...slotState, level: to };
  }
  const relative = Math.abs(spent - batch.gold_spent) / Math.max(1, Math.abs(spent), Math.abs(batch.gold_spent));
  if (relative > SPEND_TOLERANCE) {
    throw new Reject("spend", `Purchases cost ${spent} but ${batch.gold_spent} was reported.`);
  }
  for (const ing of batch.changes.unlocks.ingredients) {
    if (!c.ingredients.has(ing)) throw new Reject("progress", `Unknown ingredient ${ing}.`);
    if (!state.unlocks.ingredients.includes(ing)) state.unlocks.ingredients.push(ing);
  }
  for (const courseId of batch.changes.courses_completed) {
    const course = c.courses.get(courseId);
    if (!course || course.biome !== state.run.biome) throw new Reject("progress", `Course ${courseId} is not in this biome.`);
    if (!state.unlocks.courses.includes(courseId)) state.unlocks.courses.push(courseId);
    if (course.reward.type === "ingredient" && !state.unlocks.ingredients.includes(course.reward.id)) {
      state.unlocks.ingredients.push(course.reward.id);
    }
  }
  for (const effect of batch.changes.effects_started) {
    const ing = c.ingredients.get(effect.ingredient);
    if (!ing) throw new Reject("progress", `Unknown ingredient ${effect.ingredient}.`);
    if (!state.unlocks.ingredients.includes(ing.id) && !ing.found_in.includes(state.run.biome)) {
      throw new Reject("progress", `Ingredient ${ing.id} is neither unlocked nor found here.`);
    }
  }
  const bossKills = batch.counts.kills_boss ?? 0;
  if (batch.changes.progress.level) {
    const [from, to] = batch.changes.progress.level;
    if (from !== state.run.level_index) throw new Reject("progress", `Level is ${state.run.level_index}, not ${from}.`);
    if (to - from > bossKills) throw new Reject("progress", `${to - from} levels advanced with ${bossKills} boss kills.`);
    if (to < from) throw new Reject("progress", "Level cannot go back.");
    state.run.level_index = to;
  }
  state.progress.bosses_beaten += bossKills;
  return spent;
}

function applyCounts(state: PlayerState, batch: Batch) {
  const l = state.stats.lifetime;
  l.metres += batch.counts.metres ?? 0;
  l.coins += batch.counts.coins ?? 0;
  l.deaths += batch.counts.deaths ?? 0;
  l.pit_falls += batch.counts.pit_falls ?? 0;
  for (const role of ["basic", "elite", "boss", "dimensional"]) {
    const n = batch.counts[`kills_${role}`] ?? 0;
    if (n) l.kills[role] = (l.kills[role] ?? 0) + n;
  }
  for (const e of batch.changes.effects_started) {
    l.eats[e.ingredient] = (l.eats[e.ingredient] ?? 0) + 1;
  }
  state.run.play_seconds += batch.play_seconds;
}

export interface SyncOutcome {
  response: SyncResponse;
  status: number;
}

export function applySync(record: PlayerRecord, request: SyncRequest, now: Date, c: Content = content()): SyncOutcome {
  const remembered = record.recent_requests.get(request.request_id);
  if (remembered) {
    return { response: remembered.response, status: 200 };
  }
  const serverTime = now.toISOString();
  const finish = (response: SyncResponse, status: number): SyncOutcome => {
    playerStore.rememberRequest(record, request.request_id, response, now);
    return { response, status };
  };

  if (request.base_rev !== record.rev) {
    return finish({ result: "conflict", rev: record.rev, server_time: serverTime, code: "conflict",
      message: `Request built on revision ${request.base_rev}; the server is at ${record.rev}.` }, 409);
  }
  if (request.content_version !== c.version) {
    return finish({ result: "rejected", rev: record.rev, server_time: serverTime, code: "content_version",
      message: `Unknown content version ${request.content_version}.` }, 422);
  }
  if (request.batches.length === 0) {
    return finish({ result: "accepted", rev: record.rev, server_time: serverTime, up_to_seq: record.last_seq }, 200);
  }

  // 1. Order.
  let expected = record.last_seq + 1;
  for (const b of request.batches) {
    const from = b.seq_from ?? b.seq;
    if (from !== expected || b.seq < from) {
      return finish({ result: "rejected", rev: record.rev, server_time: serverTime, code: "order",
        message: `Expected batch ${expected}, got ${from}.` }, 422);
    }
    expected = b.seq + 1;
  }

  // 2. Time.
  const claimed = request.batches.reduce((t, b) => t + b.play_seconds + b.away_seconds, 0);
  const elapsed = Math.max(0, (now.getTime() - Date.parse(record.last_sync_at)) / 1000);
  const slack = c.economy.sync_time_slack;
  if (claimed > elapsed * slack.ratio + slack.seconds) {
    return finish({ result: "rejected", rev: record.rev, server_time: serverTime, code: "time",
      message: `${Math.round(claimed)} seconds claimed but only ${Math.round(elapsed)} have passed.` }, 422);
  }

  // 3, 4 and 5, batch by batch on a working copy.
  const working = clone(record.state);
  const trims: Array<{ seq: number; gold_removed: number }> = [];
  const ledger: PlayerRecord["ledger"] = [];
  try {
    for (const batch of request.batches) {
      const earnedClaimed = sumEarned(batch);
      const before = clone(working);
      const spent = applyChanges(c, working, batch, earnedClaimed);
      // Gold bound at the batch's own gear, so mid-batch purchases get the benefit of the doubt.
      const rate = expectedGoldPerSecond(c, working);
      const bossGold = (batch.counts.kills_boss ?? 0) * (c.enemies.get(c.biomes.get(working.run.biome)?.boss ?? "")?.gold ?? 0);
      let courseGold = 0;
      for (const id of batch.changes.courses_completed) courseGold += c.courses.get(id)?.reward.gold ?? 0;
      const allowed = rate * batch.play_seconds * c.economy.sync_margin + bossGold + courseGold;
      let earned = earnedClaimed;
      if (earnedClaimed > allowed) {
        trims.push({ seq: batch.seq, gold_removed: earnedClaimed - allowed });
        earned = allowed;
      }
      const wallet = before.wallet.gold + earned - spent;
      if (wallet < -1e-6) {
        throw new Reject("wallet", `Wallet would be ${wallet} after batch ${batch.seq}.`);
      }
      working.wallet.gold = Math.max(0, wallet);
      working.wallet.lifetime_gold = before.wallet.lifetime_gold + earned;
      applyCounts(working, batch);
      for (const [source, amount] of Object.entries(batch.gold_earned)) {
        if (amount > 0) ledger.push({ source, amount, seq: batch.seq, at: serverTime });
      }
      if (spent > 0) ledger.push({ source: "spent", amount: -spent, seq: batch.seq, at: serverTime });
    }
  } catch (err) {
    if (err instanceof Reject) {
      return finish({ result: "rejected", rev: record.rev, server_time: serverTime, code: err.code, message: err.message }, 422);
    }
    throw err;
  }

  // Commit.
  const last = request.batches[request.batches.length - 1];
  record.state = working;
  record.state.meta.device_id = request.device_id;
  record.rev += 1;
  record.state.sync.rev = record.rev;
  record.last_seq = last.seq;
  record.state.sync.last_seq = record.last_seq;
  record.last_sync_at = serverTime;
  record.state.sync.last_sync_at = serverTime;
  record.last_seen_at = serverTime;
  record.ledger.push(...ledger);
  const response: SyncResponse = trims.length > 0
    ? { result: "trimmed", rev: record.rev, server_time: serverTime, up_to_seq: record.last_seq, trims }
    : { result: "accepted", rev: record.rev, server_time: serverTime, up_to_seq: record.last_seq };
  return finish(response, 200);
}

/** The server copy as the client should store it after rejected or conflict. */
export function serverStateFor(record: PlayerRecord): PlayerState {
  const state = clone(record.state);
  state.sync = { rev: record.rev, last_seq: record.last_seq, baseline: {}, open: null, queued_batches: [], last_sync_at: record.last_sync_at };
  return state;
}
