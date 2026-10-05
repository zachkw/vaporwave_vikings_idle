import { OAuth2Client } from "google-auth-library";
import { z } from "zod";
import { env } from "../config/env";
import { ApiError, providerNotConfigured } from "../http/ApiError";
import type { ProviderIdentity } from "../types/domain";

const googlePlayPlayerSchema = z
  .object({
    playerId: z.string(),
    displayName: z.string().optional()
  })
  .passthrough();

export async function verifyGooglePlayServerAuthCode(serverAuthCode: string): Promise<ProviderIdentity> {
  if (!env.googlePlayWebClientId || !env.googlePlayWebClientSecret) {
    throw providerNotConfigured("Google Play Games", [
      "GOOGLE_PLAY_WEB_CLIENT_ID",
      "GOOGLE_PLAY_WEB_CLIENT_SECRET"
    ]);
  }

  try {
    const oauthClient = new OAuth2Client(
      env.googlePlayWebClientId,
      env.googlePlayWebClientSecret,
      "postmessage"
    );

    const { tokens } = await oauthClient.getToken(serverAuthCode);
    if (!tokens.access_token) {
      throw new ApiError(
        401,
        "invalid_google_play_auth_code",
        "Google Play server auth code did not produce an access token."
      );
    }

    const response = await fetch("https://games.googleapis.com/games/v1/players/me", {
      headers: {
        authorization: `Bearer ${tokens.access_token}`,
        accept: "application/json"
      }
    });

    if (!response.ok) {
      throw new ApiError(
        401,
        "invalid_google_play_auth_code",
        "Google Play player identity could not be retrieved.",
        { status: response.status }
      );
    }

    const player = googlePlayPlayerSchema.parse(await response.json());

    return {
      provider: "google_play",
      providerUserId: player.playerId,
      displayName: player.displayName
    };
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw new ApiError(
      401,
      "invalid_google_play_auth_code",
      "Google Play server auth code could not be verified."
    );
  }
}

