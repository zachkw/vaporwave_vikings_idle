import { Router } from "express";
import { z } from "zod";
import { getUpgrade, getUpgradeCost } from "../data/gameConfig";
import { ApiError } from "../http/ApiError";
import { asyncHandler } from "../http/asyncHandler";
import { requireAuth } from "../middleware/requireAuth";
import { accountStore } from "../services/accountStore";
import { serializeProfile } from "../services/sessionService";

const purchaseSchema = z.object({
  upgradeId: z.string()
});

export const upgradeRouter = Router();

upgradeRouter.post(
  "/purchase",
  requireAuth,
  asyncHandler(async (req, res) => {
    const body = purchaseSchema.parse(req.body);
    const upgrade = getUpgrade(body.upgradeId);

    if (!upgrade) {
      throw new ApiError(404, "upgrade_not_found", `Upgrade ${body.upgradeId} does not exist.`);
    }

    const currentLevel = req.account.profile.upgrades[body.upgradeId] ?? 0;
    if (currentLevel >= upgrade.maxLevel) {
      throw new ApiError(409, "upgrade_max_level", `${upgrade.displayName} is already max level.`);
    }

    const cost = getUpgradeCost(body.upgradeId, currentLevel);
    if (cost === null) {
      throw new ApiError(404, "upgrade_not_found", `Upgrade ${body.upgradeId} does not exist.`);
    }

    if (req.account.profile.currencies.gold < cost) {
      throw new ApiError(409, "insufficient_gold", "Not enough gold for this upgrade.", {
        requiredGold: cost,
        currentGold: req.account.profile.currencies.gold
      });
    }

    const updatedProfile = accountStore.purchaseUpgrade(req.account.accountId, body.upgradeId, cost);

    res.json({
      purchase: {
        upgradeId: body.upgradeId,
        level: updatedProfile.upgrades[body.upgradeId],
        cost
      },
      profile: serializeProfile(updatedProfile)
    });
  })
);

