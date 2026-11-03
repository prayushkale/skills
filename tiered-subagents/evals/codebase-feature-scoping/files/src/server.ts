import { createServer, IncomingMessage, ServerResponse } from "node:http";
import { logger } from "./logger.js";
import { requireAuth } from "./middleware/auth.js";
import { listUsers } from "./routes/users.js";
import { createOrder, listOrders } from "./routes/orders.js";

type Handler = (req: IncomingMessage, res: ServerResponse) => Promise<void>;
const routes: Record<string, Handler> = {
  "GET /users": listUsers,
  "GET /orders": listOrders,
  "POST /orders": createOrder,
};

async function handle(req: IncomingMessage, res: ServerResponse) {
  const start = Date.now();
  const key = `${req.method} ${req.url?.split("?")[0]}`;
  const route = routes[key];
  try {
    if (!route) { res.writeHead(404).end(); return; }
    await requireAuth(req);
    await route(req, res);
  } catch (err) {
    logger.error("request failed", { key, err: String(err) });
    if (!res.headersSent) res.writeHead(500).end();
  } finally {
    logger.info("request", { key, status: res.statusCode, ms: Date.now() - start });
  }
}

createServer((req, res) => void handle(req, res)).listen(3000, () => logger.info("listening", { port: 3000 }));
