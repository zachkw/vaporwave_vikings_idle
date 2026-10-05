# Vaporwave Vikings Backend Service

This is the first REST backend foundation for Vaporwave Vikings, Idle. It is intentionally small: Express, TypeScript, in-memory storage, auth endpoints, profile endpoints, run session reporting, and rudimentary validation.

## Scripts

```bash
npm install
npm run dev
npm run build
npm test
```

The dev server defaults to `http://localhost:3000`.

## Current API

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/health` | No | Service health check. |
| `GET` | `/api/v1/config` | No | Current content and economy config. |
| `POST` | `/api/v1/auth/guest` | No | Create a guest account and session. |
| `POST` | `/api/v1/auth/apple` | No | Verify a Sign in with Apple identity token and create or resume an account. |
| `POST` | `/api/v1/auth/google` | No | Verify a Google ID token and create or resume an account. |
| `POST` | `/api/v1/auth/google-play` | No | Exchange a Play Games Services server auth code and create or resume an account. |
| `GET` | `/api/v1/profile` | Bearer | Load the authoritative profile. |
| `POST` | `/api/v1/run/start` | Bearer | Create a server-known run session. |
| `POST` | `/api/v1/run/report` | Bearer | Submit a progress segment for validation. |
| `POST` | `/api/v1/upgrade/purchase` | Bearer | Buy an upgrade with gold. |

## Notes

- Storage is in-memory and resets when the process restarts.
- Guest login works immediately.
- Apple, Google, and Google Play auth require real platform credentials in environment variables.
- Progress validation currently uses upper bounds from `src/data/gameConfig.ts`; it is designed to become data-driven as route and enemy content matures.

