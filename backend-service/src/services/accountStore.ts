import { randomUUID } from "node:crypto";
import { ApiError } from "../http/ApiError";
import type {
  Account,
  EconomyLedgerEntry,
  PlayerProfile,
  ProviderIdentity,
  RunSession,
  SessionRecord
} from "../types/domain";

const SESSION_TTL_MS = 1000 * 60 * 60 * 24 * 30;

function now() {
  return new Date().toISOString();
}

function identityKey(identity: ProviderIdentity) {
  return `${identity.provider}:${identity.providerUserId}`;
}

function createStarterProfile(displayName?: string): PlayerProfile {
  const timestamp = now();
  return {
    playerId: randomUUID(),
    displayName: displayName ?? "Vapor Raider",
    currencies: {
      gold: 0,
      runes: 0,
      shards: 0
    },
    upgrades: {},
    gear: {
      owned: [],
      equipped: {}
    },
    stats: {
      totalGoldEarned: 0,
      totalEnemiesDefeated: 0,
      totalRunSeconds: 0
    },
    createdAt: timestamp,
    updatedAt: timestamp
  };
}

export class AccountStore {
  private readonly accounts = new Map<string, Account>();
  private readonly providerIndex = new Map<string, string>();
  private readonly sessions = new Map<string, SessionRecord>();
  private readonly runSessions = new Map<string, RunSession>();
  private readonly ledger: EconomyLedgerEntry[] = [];

  createGuestAccount(displayName?: string) {
    const identity: ProviderIdentity = {
      provider: "guest",
      providerUserId: randomUUID(),
      displayName
    };

    return this.createAccount(identity);
  }

  findOrCreateProviderAccount(identity: ProviderIdentity) {
    const key = identityKey(identity);
    const existingAccountId = this.providerIndex.get(key);

    if (existingAccountId) {
      const existing = this.accounts.get(existingAccountId);
      if (existing) {
        return existing;
      }
    }

    return this.createAccount(identity);
  }

  createSession(accountId: string) {
    const account = this.getAccount(accountId);
    const accessToken = randomUUID();
    const expiresAt = new Date(Date.now() + SESSION_TTL_MS).toISOString();
    const session: SessionRecord = {
      accessToken,
      accountId: account.accountId,
      expiresAt,
      createdAt: now()
    };

    this.sessions.set(accessToken, session);
    return session;
  }

  getAccountByAccessToken(accessToken: string) {
    const session = this.sessions.get(accessToken);
    if (!session) {
      throw new ApiError(401, "invalid_access_token", "The access token is not valid.");
    }

    if (Date.parse(session.expiresAt) <= Date.now()) {
      this.sessions.delete(accessToken);
      throw new ApiError(401, "expired_access_token", "The access token has expired.");
    }

    return this.getAccount(session.accountId);
  }

  getAccount(accountId: string) {
    const account = this.accounts.get(accountId);
    if (!account) {
      throw new ApiError(404, "account_not_found", "Account was not found.");
    }

    return account;
  }

  createRunSession(input: { accountId: string; routeId: string; contentVersion: string }) {
    const account = this.getAccount(input.accountId);
    const timestamp = now();
    const runSession: RunSession = {
      runSessionId: randomUUID(),
      accountId: account.accountId,
      routeId: input.routeId,
      contentVersion: input.contentVersion,
      status: "active",
      lastSequence: 0,
      acceptedGold: 0,
      acceptedEnemyKills: 0,
      acceptedSeconds: 0,
      startedAt: timestamp,
      updatedAt: timestamp
    };

    this.runSessions.set(runSession.runSessionId, runSession);
    return runSession;
  }

  getRunSession(runSessionId: string) {
    const session = this.runSessions.get(runSessionId);
    if (!session) {
      throw new ApiError(404, "run_session_not_found", "Run session was not found.");
    }

    return session;
  }

  applyAcceptedRunReport(input: {
    accountId: string;
    runSessionId: string;
    sequence: number;
    gold: number;
    enemiesDefeated: number;
    elapsedSeconds: number;
    reason: string;
  }) {
    const account = this.getAccount(input.accountId);
    const session = this.getRunSession(input.runSessionId);
    const timestamp = now();

    account.profile.currencies.gold += input.gold;
    account.profile.stats.totalGoldEarned += input.gold;
    account.profile.stats.totalEnemiesDefeated += input.enemiesDefeated;
    account.profile.stats.totalRunSeconds += input.elapsedSeconds;
    account.profile.updatedAt = timestamp;
    account.updatedAt = timestamp;

    session.lastSequence = input.sequence;
    session.acceptedGold += input.gold;
    session.acceptedEnemyKills += input.enemiesDefeated;
    session.acceptedSeconds += input.elapsedSeconds;
    session.updatedAt = timestamp;

    if (input.gold > 0) {
      this.ledger.push({
        ledgerEntryId: randomUUID(),
        accountId: account.accountId,
        currency: "gold",
        amount: input.gold,
        reason: input.reason,
        createdAt: timestamp
      });
    }

    return account.profile;
  }

  purchaseUpgrade(accountId: string, upgradeId: string, cost: number) {
    const account = this.getAccount(accountId);
    const timestamp = now();
    const currentLevel = account.profile.upgrades[upgradeId] ?? 0;

    account.profile.currencies.gold -= cost;
    account.profile.upgrades[upgradeId] = currentLevel + 1;
    account.profile.updatedAt = timestamp;
    account.updatedAt = timestamp;

    this.ledger.push({
      ledgerEntryId: randomUUID(),
      accountId: account.accountId,
      currency: "gold",
      amount: -cost,
      reason: `upgrade:${upgradeId}`,
      createdAt: timestamp
    });

    return account.profile;
  }

  resetForTests() {
    this.accounts.clear();
    this.providerIndex.clear();
    this.sessions.clear();
    this.runSessions.clear();
    this.ledger.splice(0, this.ledger.length);
  }

  private createAccount(identity: ProviderIdentity) {
    const timestamp = now();
    const account: Account = {
      accountId: randomUUID(),
      identities: [identity],
      profile: createStarterProfile(identity.displayName),
      createdAt: timestamp,
      updatedAt: timestamp
    };

    this.accounts.set(account.accountId, account);
    this.providerIndex.set(identityKey(identity), account.accountId);
    return account;
  }
}

export const accountStore = new AccountStore();

