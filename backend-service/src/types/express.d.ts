import type { Account } from "./domain";

declare global {
  namespace Express {
    interface Request {
      account: Account;
    }
  }
}

