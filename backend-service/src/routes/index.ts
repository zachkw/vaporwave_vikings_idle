import { Router } from "express";
import { authRouter } from "./authRoutes";
import { configRouter } from "./configRoutes";
import { profileRouter } from "./profileRoutes";
import { runRouter } from "./runRoutes";
import { upgradeRouter } from "./upgradeRoutes";

export const apiRouter = Router();

apiRouter.use("/auth", authRouter);
apiRouter.use("/config", configRouter);
apiRouter.use("/profile", profileRouter);
apiRouter.use("/run", runRouter);
apiRouter.use("/upgrade", upgradeRouter);

