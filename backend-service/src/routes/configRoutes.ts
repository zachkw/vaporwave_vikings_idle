import { Router } from "express";
import { content } from "../content/content";

export const configRouter = Router();

configRouter.get("/", (_req, res) => {
  const c = content();
  res.json({ content_version: c.version, economy: c.economy, gear: c.gear });
});
