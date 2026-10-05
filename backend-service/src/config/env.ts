import dotenv from "dotenv";

dotenv.config();

function splitCsv(value: string | undefined) {
  return (value ?? "")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

function readPort(value: string | undefined) {
  const parsed = Number(value ?? "3000");
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 3000;
}

export const env = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  port: readPort(process.env.PORT),
  serviceVersion: process.env.npm_package_version ?? "0.1.0",
  appleClientIds: splitCsv(process.env.APPLE_CLIENT_IDS),
  googleClientIds: splitCsv(process.env.GOOGLE_CLIENT_IDS),
  googlePlayWebClientId: process.env.GOOGLE_PLAY_WEB_CLIENT_ID ?? "",
  googlePlayWebClientSecret: process.env.GOOGLE_PLAY_WEB_CLIENT_SECRET ?? ""
};

