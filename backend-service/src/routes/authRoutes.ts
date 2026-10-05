import { Router } from "express";
import { z } from "zod";
import { verifyAppleIdentityToken } from "../auth/appleAuth";
import { verifyGoogleIdentityToken } from "../auth/googleAuth";
import { verifyGooglePlayServerAuthCode } from "../auth/googlePlayAuth";
import { asyncHandler } from "../http/asyncHandler";
import { accountStore } from "../services/accountStore";
import { issueAuthResponse } from "../services/sessionService";

const guestLoginSchema = z.object({
  displayName: z.string().trim().min(1).max(32).optional()
});

const appleLoginSchema = z.object({
  identityToken: z.string().min(20),
  authorizationCode: z.string().optional(),
  displayName: z.string().trim().min(1).max(64).optional()
});

const googleLoginSchema = z.object({
  idToken: z.string().min(20)
});

const googlePlayLoginSchema = z.object({
  serverAuthCode: z.string().min(20)
});

export const authRouter = Router();

authRouter.post(
  "/guest",
  asyncHandler(async (req, res) => {
    const body = guestLoginSchema.parse(req.body);
    const account = accountStore.createGuestAccount(body.displayName);
    res.status(201).json(issueAuthResponse(account));
  })
);

authRouter.post(
  "/apple",
  asyncHandler(async (req, res) => {
    const body = appleLoginSchema.parse(req.body);
    const identity = await verifyAppleIdentityToken(body.identityToken, body.displayName);
    const account = accountStore.findOrCreateProviderAccount(identity);
    res.json(issueAuthResponse(account));
  })
);

authRouter.post(
  "/google",
  asyncHandler(async (req, res) => {
    const body = googleLoginSchema.parse(req.body);
    const identity = await verifyGoogleIdentityToken(body.idToken);
    const account = accountStore.findOrCreateProviderAccount(identity);
    res.json(issueAuthResponse(account));
  })
);

authRouter.post(
  "/google-play",
  asyncHandler(async (req, res) => {
    const body = googlePlayLoginSchema.parse(req.body);
    const identity = await verifyGooglePlayServerAuthCode(body.serverAuthCode);
    const account = accountStore.findOrCreateProviderAccount(identity);
    res.json(issueAuthResponse(account));
  })
);

