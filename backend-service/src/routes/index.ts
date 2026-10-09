import { Router } from "express";
import { authRouter } from "./authRoutes";
import { configRouter } from "./configRoutes";
import { profileRouter } from "./profileRoutes";
import { syncRouter } from "./syncRoutes";

export const apiRouter = Router();

apiRouter.use("/auth", authRouter);
apiRouter.use("/config", configRouter);
apiRouter.use("/profile", profileRouter);
apiRouter.use("/", syncRouter);
