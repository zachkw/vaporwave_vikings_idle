import cors from "cors";
import express from "express";
import helmet from "helmet";
import { env } from "./config/env";
import { notFoundHandler } from "./middleware/notFoundHandler";
import { errorHandler } from "./middleware/errorHandler";
import { apiRouter } from "./routes";

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json({ limit: "128kb" }));

  app.get("/", (_req, res) => {
    res.json({
      service: "vaporwave-vikings-backend-service",
      version: env.serviceVersion,
      apiBasePath: "/api/v1"
    });
  });

  app.get("/health", (_req, res) => {
    res.json({
      status: "ok",
      service: "vaporwave-vikings-backend-service",
      version: env.serviceVersion,
      time: new Date().toISOString()
    });
  });

  app.use("/api/v1", apiRouter);
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

