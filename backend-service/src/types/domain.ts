export type AuthProvider = "guest" | "apple" | "google" | "google_play";
export type Currency = "gold" | "runes" | "shards";

export interface ProviderIdentity {
  provider: AuthProvider;
  providerUserId: string;
  email?: string;
  displayName?: string;
}

export interface PlayerProfile {
  playerId: string;
  displayName: string;
  currencies: Record<Currency, number>;
  upgrades: Record<string, number>;
  gear: {
    owned: Array<{
      gearId: string;
      level: number;
    }>;
    equipped: Record<string, string | null>;
  };
  stats: {
    totalGoldEarned: number;
    totalEnemiesDefeated: number;
    totalRunSeconds: number;
  };
  createdAt: string;
  updatedAt: string;
}

export interface Account {
  accountId: string;
  identities: ProviderIdentity[];
  profile: PlayerProfile;
  createdAt: string;
  updatedAt: string;
}

export interface SessionRecord {
  accessToken: string;
  accountId: string;
  expiresAt: string;
  createdAt: string;
}

export interface RunSession {
  runSessionId: string;
  accountId: string;
  routeId: string;
  contentVersion: string;
  status: "active" | "closed";
  lastSequence: number;
  acceptedGold: number;
  acceptedEnemyKills: number;
  acceptedSeconds: number;
  startedAt: string;
  updatedAt: string;
}

export interface RunReport {
  runSessionId: string;
  sequence: number;
  elapsedSeconds: number;
  routeId: string;
  goldCollected: number;
  enemiesDefeated: number;
  rewardGroupsCollected: string[];
  abilityActivations: Array<{
    abilityId: string;
    usedAtSeconds: number;
  }>;
}

export interface EconomyLedgerEntry {
  ledgerEntryId: string;
  accountId: string;
  currency: Currency;
  amount: number;
  reason: string;
  createdAt: string;
}

