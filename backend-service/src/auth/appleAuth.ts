import { env } from "../config/env";
import { ApiError, providerNotConfigured } from "../http/ApiError";
import type { ProviderIdentity } from "../types/domain";

let appleKeys: any;

async function getAppleKeys() {
  const { createRemoteJWKSet } = await import("jose");
  appleKeys ??= createRemoteJWKSet(new URL("https://appleid.apple.com/auth/keys"));
  return appleKeys;
}

export async function verifyAppleIdentityToken(
  identityToken: string,
  displayName?: string
): Promise<ProviderIdentity> {
  if (env.appleClientIds.length === 0) {
    throw providerNotConfigured("Apple", ["APPLE_CLIENT_IDS"]);
  }

  try {
    const { jwtVerify } = await import("jose");
    const { payload } = await jwtVerify(identityToken, await getAppleKeys(), {
      issuer: "https://appleid.apple.com",
      audience: env.appleClientIds
    });

    if (!payload.sub) {
      throw new ApiError(401, "invalid_apple_token", "Apple identity token did not include a subject.");
    }

    return {
      provider: "apple",
      providerUserId: payload.sub,
      email: typeof payload.email === "string" ? payload.email : undefined,
      displayName
    };
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw new ApiError(401, "invalid_apple_token", "Apple identity token could not be verified.");
  }
}
