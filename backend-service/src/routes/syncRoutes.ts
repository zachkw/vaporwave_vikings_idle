import { Router } from "express";
import { z } from "zod";
import { asyncHandler } from "../http/asyncHandler";
import { requireAuth } from "../middleware/requireAuth";
import { playerStore } from "../services/playerStore";
import { applySync, serverStateFor } from "../services/syncService";
import type { SyncRequest } from "../types/state";

const pair = z.tuple([z.number(), z.number()]);

const batchSchema = z.object({
  seq: z.number().int().positive(),
  seq_from: z.number().int().positive().optional(),
  play_seconds: z.number().nonnegative(),
  away_seconds: z.number().nonnegative().default(0),
  gold_earned: z.record(z.string(), z.number().nonnegative()),
  gold_spent: z.number().nonnegative(),
  counts: z.record(z.string(), z.number().int().nonnegative()),
  changes: z.object({
    gear: z.record(z.string(), pair).default({}),
    unlocks: z.object({
      gear_slots: z.array(z.string()).default([]),
      ingredients: z.array(z.string()).default([])
    }).default({ gear_slots: [], ingredients: [] }),
    progress: z.object({ level: pair.optional() }).default({}),
    courses_completed: z.array(z.string()).default([]),
    effects_started: z.array(z.object({ ingredient: z.string(), form: z.string() })).default([])
  })
});

const syncSchema = z.object({
  request_id: z.string().min(8).max(128),
  device_id: z.string().min(1).max(128),
  base_rev: z.number().int().nonnegative(),
  content_version: z.string(),
  batches: z.array(batchSchema).max(200)
});

export const syncRouter = Router();

syncRouter.post(
  "/sync",
  requireAuth,
  asyncHandler(async (req, res) => {
    const body = syncSchema.parse(req.body) as SyncRequest;
    const now = new Date();
    const record = playerStore.getOrCreate(req.account.accountId, now);
    const outcome = applySync(record, body, now);
    res.status(outcome.status).json(outcome.response);
  })
);

syncRouter.get(
  "/state",
  requireAuth,
  asyncHandler(async (req, res) => {
    const record = playerStore.getOrCreate(req.account.accountId, new Date());
    res.json({ rev: record.rev, server_time: new Date().toISOString(), state: serverStateFor(record) });
  })
);
