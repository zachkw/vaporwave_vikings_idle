export class ApiError extends Error {
  readonly statusCode: number;
  readonly code: string;
  readonly details?: unknown;

  constructor(statusCode: number, code: string, message: string, details?: unknown) {
    super(message);
    this.name = "ApiError";
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

export function providerNotConfigured(provider: string, requiredEnvVars: string[]) {
  return new ApiError(
    501,
    "provider_not_configured",
    `${provider} authentication is not configured for this environment.`,
    { requiredEnvVars }
  );
}

