export const gameConfig = {
  contentVersion: "dev-0",
  reporting: {
    targetSegmentSeconds: 60,
    minSegmentSeconds: 5,
    maxSegmentSeconds: 90,
    clampTolerance: 0.1
  },
  routes: {
    "neon-fjord-01": {
      routeId: "neon-fjord-01",
      displayName: "Neon Fjord",
      maxGoldPerMinute: 900,
      maxEnemyKillsPerMinute: 45,
      mutuallyExclusiveRewardGroups: [
        ["high-platform", "low-platform"],
        ["left-cache", "right-cache"]
      ]
    }
  },
  upgrades: {
    "power.training": {
      upgradeId: "power.training",
      displayName: "Raid Training",
      maxLevel: 50,
      baseCost: 25,
      costMultiplier: 1.16,
      powerMultiplierPerLevel: 0.05,
      goldMultiplierPerLevel: 0
    },
    "gold.magnetism": {
      upgradeId: "gold.magnetism",
      displayName: "Neon Hoard Magnet",
      maxLevel: 50,
      baseCost: 40,
      costMultiplier: 1.18,
      powerMultiplierPerLevel: 0,
      goldMultiplierPerLevel: 0.04
    }
  }
} as const;

export type RouteId = keyof typeof gameConfig.routes;
export type UpgradeId = keyof typeof gameConfig.upgrades;

export function getRoute(routeId: string) {
  return gameConfig.routes[routeId as RouteId];
}

export function getUpgrade(upgradeId: string) {
  return gameConfig.upgrades[upgradeId as UpgradeId];
}

export function getUpgradeCost(upgradeId: string, currentLevel: number) {
  const upgrade = getUpgrade(upgradeId);
  if (!upgrade) {
    return null;
  }

  return Math.ceil(upgrade.baseCost * Math.pow(upgrade.costMultiplier, currentLevel));
}

