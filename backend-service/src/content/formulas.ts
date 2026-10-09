/**
 * The shared maths. Each function here has a twin in the Godot client
 * (state/selectors.gd) and content/test_vectors.json pins both to the same
 * numbers. Change one side, regenerate the vectors, and the other side's
 * tests tell you if it disagrees.
 */
import type { Content, EnemyData } from "./content";
import type { PlayerState } from "../types/state";

export function gearLevel(state: PlayerState, slot: string) {
  return Math.trunc(state.gear[slot]?.level ?? 0);
}

export function gearStat(c: Content, state: PlayerState, key: string) {
  let total = 0;
  for (const item of c.gear) {
    total += (item.per_level[key] ?? 0) * gearLevel(state, item.id);
  }
  return total;
}

export function goldPerMetre(c: Content, state: PlayerState) {
  return (c.economy.gold_per_metre + gearStat(c, state, "gold_per_metre")) * (1 + gearStat(c, state, "gold_all_pct") / 100);
}

export function coinValue(c: Content, state: PlayerState) {
  return c.economy.coin_value * (1 + gearStat(c, state, "gold_coin_pct") / 100) * (1 + gearStat(c, state, "gold_all_pct") / 100);
}

export function enemyGold(c: Content, state: PlayerState, enemy: EnemyData) {
  const roleKey = enemy.dimension ? "gold_dimensional_pct" : `gold_${enemy.role}_pct`;
  return enemy.gold * (1 + gearStat(c, state, roleKey) / 100) * (1 + gearStat(c, state, "gold_all_pct") / 100);
}

export function runSpeedMult(c: Content, state: PlayerState) {
  return 1 + gearStat(c, state, "run_speed_pct") / 100;
}

/** Reference earning rate for the gold bound. Twin: Selectors.expected_gold_per_second. */
export function expectedGoldPerSecond(c: Content, state: PlayerState, biomeId = state.run.biome) {
  const perM = c.economy.expected_per_metre;
  const biome = c.biomes.get(biomeId);
  let perMetre = goldPerMetre(c, state) + perM.coins * coinValue(c, state);
  if (biome) {
    const basic = c.enemies.get(biome.basic[0]);
    const elite = c.enemies.get(biome.elite[0]);
    if (basic) perMetre += perM.basic_kills * enemyGold(c, state, basic);
    if (elite) perMetre += perM.elite_kills * enemyGold(c, state, elite);
    let dimGold = 0;
    let dimCount = 0;
    for (const ingId of biome.ingredients) {
      for (const enemyId of c.ingredients.get(ingId)?.reveals ?? []) {
        const e = c.enemies.get(enemyId);
        if (e) {
          dimGold += enemyGold(c, state, e);
          dimCount += 1;
        }
      }
    }
    if (dimCount > 0) perMetre += (perM.dimensional_kills * dimGold) / dimCount;
  }
  return perMetre * c.economy.run_speed_mps * runSpeedMult(c, state);
}

/** Gold for `count` levels of a slot from `fromLevel`: linear base + step x level. Twin: Selectors.level_cost_sum. */
export function levelCostSum(c: Content, slot: string, fromLevel: number, count: number) {
  const item = c.gearById.get(slot);
  if (!item || count <= 0) return 0;
  let total = 0;
  for (let i = 0; i < count; i += 1) {
    total += item.base_cost + item.step * (fromLevel + i);
  }
  return total;
}

/** Away gold for a gap, paid by the economy's bands at the reference rate. */
export function awayGold(c: Content, state: PlayerState, awaySeconds: number) {
  const rate = expectedGoldPerSecond(c, state);
  let total = 0;
  for (const band of c.economy.away_bands) {
    const from = band.from_h * 3600;
    const to = band.to_h == null ? Number.POSITIVE_INFINITY : band.to_h * 3600;
    const seconds = Math.max(0, Math.min(awaySeconds, to) - from);
    total += seconds * rate * band.rate;
  }
  return total;
}
