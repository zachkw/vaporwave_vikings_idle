import { Router } from "express";
import { requireAuth } from "../middleware/requireAuth";
import { serializeAccount, serializeProfile } from "../services/sessionService";

export const profileRouter = Router();

profileRouter.get("/", requireAuth, (req, res) => {
  res.json({
    account: serializeAccount(req.account),
    profile: serializeProfile(req.account.profile)
  });
});

