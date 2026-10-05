import type { Account, PlayerProfile } from "../types/domain";
import { accountStore } from "./accountStore";

export function serializeProfile(profile: PlayerProfile) {
  return {
    playerId: profile.playerId,
    displayName: profile.displayName,
    currencies: profile.currencies,
    upgrades: profile.upgrades,
    gear: profile.gear,
    stats: profile.stats,
    createdAt: profile.createdAt,
    updatedAt: profile.updatedAt
  };
}

export function serializeAccount(account: Account) {
  return {
    accountId: account.accountId,
    providers: account.identities.map((identity) => identity.provider),
    createdAt: account.createdAt,
    updatedAt: account.updatedAt
  };
}

export function issueAuthResponse(account: Account) {
  const session = accountStore.createSession(account.accountId);

  return {
    accessToken: session.accessToken,
    tokenType: "Bearer",
    expiresAt: session.expiresAt,
    account: serializeAccount(account),
    profile: serializeProfile(account.profile)
  };
}

