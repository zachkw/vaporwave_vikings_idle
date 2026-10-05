import { OAuth2Client } from "google-auth-library";
import { env } from "../config/env";
import { ApiError, providerNotConfigured } from "../http/ApiError";
import type { ProviderIdentity } from "../types/domain";

const googleClient = new OAuth2Client();

export async function verifyGoogleIdentityToken(idToken: string): Promise<ProviderIdentity> {
  if (env.googleClientIds.length === 0) {
    throw providerNotConfigured("Google", ["GOOGLE_CLIENT_IDS"]);
  }

  try {
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: env.googleClientIds
    });
    const payload = ticket.getPayload();

    if (!payload?.sub) {
      throw new ApiError(401, "invalid_google_token", "Google ID token did not include a subject.");
    }

    return {
      provider: "google",
      providerUserId: payload.sub,
      email: payload.email,
      displayName: payload.name
    };
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw new ApiError(401, "invalid_google_token", "Google ID token could not be verified.");
  }
}

