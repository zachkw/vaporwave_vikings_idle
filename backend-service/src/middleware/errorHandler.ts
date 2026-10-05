import type { ErrorRequestHandler } from "express";
import { ZodError } from "zod";
import { ApiError } from "../http/ApiError";
import { env } from "../config/env";

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof ZodError) {
    res.status(400).json({
      error: {
        code: "invalid_request",
        message: "Request body did not match the expected shape.",
        details: err.flatten()
      }
    });
    return;
  }

  if (err instanceof ApiError) {
    res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details
      }
    });
    return;
  }

  res.status(500).json({
    error: {
      code: "internal_server_error",
      message: "Something went wrong.",
      details: env.nodeEnv === "production" ? undefined : String(err)
    }
  });
};

