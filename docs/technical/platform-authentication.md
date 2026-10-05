# Platform Authentication

## Goal

The backend should support low-friction mobile login while keeping durable progression tied to verified platform identity where possible.

The first backend skeleton supports:

- Guest accounts for immediate play.
- Sign in with Apple identity token verification.
- Google ID token verification.
- Google Play Games Services server auth code exchange.

## Guest Login

Guest login creates a server-side account with a generated provider identity. This is useful for early development and first-session testing.

Guest accounts should eventually be linkable to Apple or Google identity so players can recover progression across devices.

## Sign in with Apple

The iOS client should use Sign in with Apple and send the resulting identity token to the backend. The backend verifies the token against Apple's public keys, checks issuer and audience, then uses the token subject as the Apple provider user id.

Required backend configuration:

- `APPLE_CLIENT_IDS` - comma-separated accepted audiences, usually the bundle id and/or Services ID depending on the client flow.

Relevant Apple docs:

- [Authenticating users with Sign in with Apple](https://developer.apple.com/documentation/signinwithapple/authenticating-users-with-sign-in-with-apple)
- [Fetch Apple's public key for verifying token signatures](https://developer.apple.com/documentation/signinwithapplerestapi/fetch-apple%27s-public-key-for-verifying-token-signature)

## Generic Google Sign-In

The backend can verify Google ID tokens for flows that produce an OpenID Connect ID token. The backend checks the token audience against configured Google OAuth client ids and uses the token subject as the provider user id.

Required backend configuration:

- `GOOGLE_CLIENT_IDS` - comma-separated accepted Google OAuth client ids.

Relevant Google docs:

- [Verify the Google ID token on your server side](https://developers.google.com/identity/gsi/web/guides/verify-google-id-token)
- [Authenticate with a backend server](https://developers.google.com/identity/sign-in/android/backend-auth)

## Google Play Games Services

For Android game identity, Play Games Services v2 recommends requesting a server auth code from the client and sending it to the backend. The backend exchanges that code for OAuth tokens, then calls the Play Games Services REST API to retrieve the authenticated player.

Required backend configuration:

- `GOOGLE_PLAY_WEB_CLIENT_ID`
- `GOOGLE_PLAY_WEB_CLIENT_SECRET`

Relevant Google docs:

- [Server-side access to Google Play Games Services](https://developer.android.com/games/pgs/android/server-access)
- [Play Games Services players.get REST method](https://developer.android.com/games/services/web/api/rest/v1/players/get)

## Account Linking

The first skeleton creates or resumes accounts by provider identity. A later account-linking flow should allow a guest account to attach an Apple, Google, or Google Play identity.

Important linking rules:

- Require an authenticated current account before linking.
- Verify the platform token before linking.
- Prevent linking the same platform identity to multiple accounts.
- Preserve the existing player profile when upgrading from guest to platform identity.

