import { Router } from "express";
import { gameConfig } from "../data/gameConfig";

export const configRouter = Router();

configRouter.get("/", (_req, res) => {
  res.json({ config: gameConfig });
});

