import { gameConfig, getRoute } from "../data/gameConfig";
import { ApiError } from "../http/ApiError";
import type { Account, PlayerProfile, RunReport } from "../types/domain";
import { accountStore } from "./accountStore";
import { serializeProfile } from "./sessionService";

function getEffectiveStats(profile: PlayerProfile) {
  const powerLevel = profile.upgrades["power.training"] ?? 0;
  const goldLevel = profile.upgrades["gold.magnetism"] ?? 0;

  return {
    powerMultiplier: 1 + powerLevel * gameConfig.upgrades["power.training"].powerMultiplierPerLevel,
    goldMultiplier: 1 + goldLevel * gameConfig.upgrades["gold.magnetism"].goldMultiplierPerLevel
  };
}

function findExclusiveRewardViolations(routeId: string, collectedGroups: string[]) {
  const route = getRoute(routeId);
  if (!route) {
    return [];
  }

  const collected = new Set(collectedGroups);
  return route.mutuallyExclusiveRewardGroups
    .map((group) => group.filter((rewardGroup) => collected.has(rewardGroup)))
    .filter((matches) => matches.length > 1);
}

export function validateAndApplyRunReport(account: Account, report: RunReport) {
  const session = accountStore.getRunSession(report.runSessionId);

  if (session.accountId !== account.accountId) {
    throw new ApiError(403, "run_session_account_mismatch", "Run session does not belong to this account.");
  }

  if (session.status !== "active") {
    throw new ApiError(409, "run_session_not_active", "Run session is not active.");
  }

  if (report.sequence !== session.lastSequence + 1) {
    throw new ApiError(409, "run_report_sequence_mismatch", "Run report sequence was not the next expected value.", {
      expectedSequence: session.lastSequence + 1,
      receivedSequence: report.sequence
    });
  }

  if (report.routeId !== session.routeId) {
    throw new ApiError(409, "run_route_mismatch", "Run report route did not match the run session route.");
  }

  const route = getRoute(report.routeId);
  if (!route) {
    throw new ApiError(404, "route_not_found", `Route ${report.routeId} does not exist.`);
  }

  const { minSegmentSeconds, maxSegmentSeconds, clampTolerance } = gameConfig.reporting;
  if (report.elapsedSeconds < minSegmentSeconds || report.elapsedSeconds > maxSegmentSeconds) {
    throw new ApiError(422, "run_report_duration_out_of_bounds", "Run report duration is outside accepted bounds.", {
      minSegmentSeconds,
      maxSegmentSeconds,
      elapsedSeconds: report.elapsedSeconds
    });
  }

  const stats = getEffectiveStats(account.profile);
  const segmentMinutes = report.elapsedSeconds / 60;
  const maxGold = Math.ceil(route.maxGoldPerMinute * stats.goldMultiplier * segmentMinutes);
  const maxEnemyKills = Math.ceil(route.maxEnemyKillsPerMinute * stats.powerMultiplier * segmentMinutes);
  const exclusiveViolations = findExclusiveRewardViolations(report.routeId, report.rewardGroupsCollected);

  const violations: string[] = [];
  if (report.goldCollected > maxGold) {
    violations.push("gold_collected_above_maximum");
  }
  if (report.enemiesDefeated > maxEnemyKills) {
    violations.push("enemy_kills_above_maximum");
  }
  if (exclusiveViolations.length > 0) {
    violations.push("mutually_exclusive_reward_groups");
  }

  const goldClampLimit = Math.ceil(maxGold * (1 + clampTolerance));
  const canClamp =
    violations.length === 1 &&
    violations[0] === "gold_collected_above_maximum" &&
    report.goldCollected <= goldClampLimit;

  if (violations.length > 0 && !canClamp) {
    return {
      outcome: "reject",
      accepted: {
        gold: 0,
        enemiesDefeated: 0,
        elapsedSeconds: 0
      },
      limits: {
        maxGold,
        maxEnemyKills
      },
      violations,
      profile: serializeProfile(account.profile)
    };
  }

  const acceptedGold = canClamp ? maxGold : report.goldCollected;
  const acceptedEnemies = Math.min(report.enemiesDefeated, maxEnemyKills);
  const updatedProfile = accountStore.applyAcceptedRunReport({
    accountId: account.accountId,
    runSessionId: report.runSessionId,
    sequence: report.sequence,
    gold: acceptedGold,
    enemiesDefeated: acceptedEnemies,
    elapsedSeconds: report.elapsedSeconds,
    reason: `run:${report.runSessionId}:${report.sequence}`
  });

  return {
    outcome: canClamp ? "clamp" : "accept",
    accepted: {
      gold: acceptedGold,
      enemiesDefeated: acceptedEnemies,
      elapsedSeconds: report.elapsedSeconds
    },
    limits: {
      maxGold,
      maxEnemyKills
    },
    violations,
    profile: serializeProfile(updatedProfile)
  };
}

