/**
 * Content tables shared with the game. The server reads the same JSON files
 * the Godot client ships (vaporwave-vikings-idle/content), so bounds and
 * costs come from one place. Set CONTENT_DIR to point somewhere else.
 */
import { readFileSync } from "node:fs";
import path from "node:path";

export interface GearItem {
  id: string;
  name: string;
  order: number;
  bracket: number;
  base_cost: number;
  step: number;
  per_level: Record<string, number>;
  grants?: string[];
}

export interface EnemyData {
  id: string;
  role: "basic" | "elite" | "boss";
  gold: number;
  dimension?: string;
}

export interface BiomeData {
  id: string;
  basic: string[];
  elite: string[];
  boss: string;
  ingredients: string[];
  levels: number;
}

export interface IngredientData {
  id: string;
  found_in: string[];
  reveals: string[];
}

export interface CourseData {
  id: string;
  biome: string;
  reward: { type: string; id: string; gold?: number };
}

export interface Economy {
  run_speed_mps: number;
  gold_per_metre: number;
  coin_value: number;
  sync_margin: number;
  expected_per_metre: { coins: number; basic_kills: number; elite_kills: number; dimensional_kills: number };
  sync_time_slack: { ratio: number; seconds: number };
  away_bands: Array<{ from_h: number; to_h: number | null; rate: number }>;
}

export interface Content {
  dir: string;
  version: string;
  gear: GearItem[];
  gearById: Map<string, GearItem>;
  enemies: Map<string, EnemyData>;
  biomes: Map<string, BiomeData>;
  ingredients: Map<string, IngredientData>;
  courses: Map<string, CourseData>;
  economy: Economy;
  viking: { health: number };
  testVectors: unknown;
}

function defaultDir() {
  return process.env.CONTENT_DIR ?? path.resolve(process.cwd(), "..", "vaporwave-vikings-idle", "content");
}

function readJson<T>(dir: string, name: string): T {
  return JSON.parse(readFileSync(path.join(dir, name), "utf8")) as T;
}

function byId<T extends { id: string }>(items: T[]) {
  return new Map(items.map((item) => [item.id, item] as const));
}

export function loadContent(dir = defaultDir()): Content {
  const gear = readJson<GearItem[]>(dir, "gear.json").slice().sort((a, b) => a.order - b.order);
  return {
    dir,
    version: readJson<{ content_version: string }>(dir, "meta.json").content_version,
    gear,
    gearById: byId(gear),
    enemies: byId(readJson<EnemyData[]>(dir, "enemies.json")),
    biomes: byId(readJson<BiomeData[]>(dir, "biomes.json")),
    ingredients: byId(readJson<IngredientData[]>(dir, "ingredients.json")),
    courses: byId(readJson<CourseData[]>(dir, "courses.json")),
    economy: readJson<Economy>(dir, "economy.json"),
    viking: readJson<{ health: number }>(dir, "viking.json"),
    testVectors: readJson<unknown>(dir, "test_vectors.json")
  };
}

let cached: Content | undefined;

export function content() {
  if (!cached) {
    cached = loadContent();
  }
  return cached;
}
