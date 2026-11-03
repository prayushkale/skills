import type { IncomingMessage } from "node:http";
import { logger } from "../logger.js";
export async function requireAuth(req: IncomingMessage) {
  const token = req.headers.authorization?.replace("Bearer ", "");
  if (!token) { logger.warn("missing token"); throw new Error("unauthorized"); }
}
