import { Router } from "express";
import { z } from "zod";
import { gameConfig } from "../data/gameConfig";
import { ApiError } from "../http/ApiError";
import { asyncHandler } from "../http/asyncHandler";
import { requireAuth } from "../middleware/requireAuth";
import { accountStore } from "../services/accountStore";
import { validateAndApplyRunReport } from "../services/runValidationService";

const startRunSchema = z.object({
  contentVersion: z.string().optional(),
  routeId: z.string().default("neon-fjord-01")
});

const runReportSchema = z.object({
  runSessionId: z.string().uuid(),
  sequence: z.number().int().positive(),
  elapsedSeconds: z.number().positive(),
  routeId: z.string(),
  goldCollected: z.number().int().nonnegative(),
  enemiesDefeated: z.number().int().nonnegative(),
  rewardGroupsCollected: z.array(z.string()).default([]),
  abilityActivations: z
    .array(
      z.object({
        abilityId: z.string(),
        usedAtSeconds: z.number().nonnegative()
      })
    )
    .default([])
});

export const runRouter = Router();

runRouter.post(
  "/start",
  requireAuth,
  asyncHandler(async (req, res) => {
    const body = startRunSchema.parse(req.body);

    if (!gameConfig.routes[body.routeId as keyof typeof gameConfig.routes]) {
      throw new ApiError(404, "route_not_found", `Route ${body.routeId} does not exist.`);
    }

    const runSession = accountStore.createRunSession({
      accountId: req.account.accountId,
      routeId: body.routeId,
      contentVersion: body.contentVersion ?? gameConfig.contentVersion
    });

    res.status(201).json({
      runSession,
      reporting: gameConfig.reporting
    });
  })
);

runRouter.post(
  "/report",
  requireAuth,
  asyncHandler(async (req, res) => {
    const report = runReportSchema.parse(req.body);
    const result = validateAndApplyRunReport(req.account, report);
    res.json(result);
  })
);

