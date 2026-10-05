import type { RequestHandler } from "express";
import { ApiError } from "../http/ApiError";
import { accountStore } from "../services/accountStore";

export const requireAuth: RequestHandler = (req, _res, next) => {
  const header = req.header("authorization") ?? "";
  const token = header.startsWith("Bearer ") ? header.slice("Bearer ".length).trim() : "";

  if (!token) {
    next(new ApiError(401, "missing_access_token", "A Bearer access token is required."));
    return;
  }

  const account = accountStore.getAccountByAccessToken(token);
  req.account = account;
  next();
};

